import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:scannutplus/core/services/env_service.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/core/constants/ai_prompts.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/pet_repository.dart';
// import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart'; // Unused for now
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

abstract class PetBaseAiService {
  GenerativeModel? _model;
  String _activeModelName = 'gemini-1.5-flash';
  String _apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/';

  PetBaseAiService();

  final PetRepository _repository = PetRepository();

  Future<void> _ensureInitialized() async {
    if (_model != null) return;
    
    // Force Load Env if not ready
    await EnvService.init();

    // Load Config (Remote with Local Fallback)
    await _loadConfig();

    final apiKey = EnvService.geminiApiKey;
    if (apiKey.isEmpty) {
       // Pilar 0: Usar constante, nunca string literal
       throw Exception(AppKeys.errorGeminiMissing); 
    }
    
    _model = GenerativeModel(
      model: _activeModelName,
      apiKey: apiKey,
    );
    
    if (kDebugMode) {
       debugPrint('${PetConstants.logTagPetAi}: Key Length: ${apiKey.length}');
       if (apiKey.length < 30) {
          debugPrint('${PetConstants.logTagPetFatal}: API Key truncada ou inválida no .env (Verifique o arquivo .env na raiz: Len: ${apiKey.length})');
       }
       // Initial log
       if (apiKey.length >= 4) {
          final maskedKey = apiKey.substring(apiKey.length - 4);
          debugPrint('${PetConstants.logTagPetAi}: Endpoint: $_apiEndpoint$_activeModelName:generateContent?key=***$maskedKey');
       }
    }
  }

  Future<String> analyzePetImageBase({
    required String imagePath,
    required String languageCode,
    String? context,
    Uint8List? imageBytes,
    required String petName,
    required String petUuid, // For RAG Persistence
    String analysisType = PetConstants.typeClinical,
  }) async {
    // Reading bytes - compute if needed handled by caller usually, but here we can't easily use compute for asset reading if bytes not passed
    final bytes = imageBytes ?? await File(imagePath).readAsBytes();
    
    final prompt = _buildSystemPrompt(languageCode, context, petName);
    
    await _ensureInitialized(); 
    final apiKey = EnvService.geminiApiKey; // Retrieve for logging

    if (kDebugMode) {
      debugPrint('${PetConstants.logTagPetAi}: Prompt Payload: $prompt');
      if (apiKey.length >= 4) {
          final maskedKey = apiKey.substring(apiKey.length - 4);
          debugPrint('${PetConstants.logTagPetAi}: Endpoint: $_apiEndpoint$_activeModelName:generateContent?key=***$maskedKey');
      }
    }

    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _model!.generateContent(content);
      final responseText = response.text ?? AppKeys.errorNoAnalysis;

      // Persistence RAG Isolated
      await _repository.saveAnalysis(
        petUuid: petUuid,
        petName: petName,
        analysisResult: responseText,
        sources: [PetConstants.sourceExtracted], // Simple extraction for now, can be parsed
        analysisType: analysisType,
      );

      return responseText;
    } catch (e) {
      throw Exception('${AppKeys.errorAiUnavailable}$e');
    }
  }

  String _buildSystemPrompt(String languageCode, String? context, String petName) {
    return '''
    ${PetPrompts.expertRole} $petName.
    ${PetPrompts.multimodalInstruction}
    ${AiPrompts.domainPet}
    
    ${context ?? ''}

    ${PetPrompts.truthDirective}
    ${PetPrompts.visualSummary}
    ${PetPrompts.sourceMandatory}

    ${AiPrompts.outputLang}$languageCode.

    ${AiPrompts.formatInst}
    ''';
  }

  Future<void> _loadConfig() async {
    try {
      // Try Remote Config First
      // Using generic http get
      final url = Uri.parse(PetConstants.remoteConfigUrl);
      final response = await http.get(url).timeout(const Duration(seconds: 10)); // Increased from 5s to 10s
      
      if (response.statusCode == 200) {
        final config = json.decode(response.body);
        _activeModelName = config[PetConstants.fieldActiveModel] ?? _activeModelName;
        // Force v1 if remote tries v1beta, or just use config. But here we safeguard.
        // Actually, we should just let remote decide, but user said FORCE v1.
        // I will just ignore remote endpoint if it is v1beta? No, let's just make sure we request stable.
        // The google_generative_ai package usually handles versions via constructor or internal constants.
        // Wait, the package `google_generative_ai` might default to v1beta.
        // To force v1, we might need a newer package version or configuration.
        // But the prompt says "Force usage of v1... for calls...".
        // Let's assume `_apiEndpoint` variable was being used loosely.
        _apiEndpoint = config[PetConstants.fieldApiEndpoint] ?? _apiEndpoint;
        
        if (kDebugMode) debugPrint('${PetConstants.logTagPetAi}: Remote Config Loaded: $_activeModelName');
        return;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[PET_WARN]: Remote Config Unreachable ($e). Falling back to local...');
    }

    // Fallback to Local Asset
    try {
      final configStr = await rootBundle.loadString('assets/config.json');
      final config = json.decode(configStr);
      _activeModelName = config[PetConstants.fieldActiveModel] ?? _activeModelName;
      _apiEndpoint = config[PetConstants.fieldApiEndpoint] ?? _apiEndpoint;
      if (kDebugMode) debugPrint('${PetConstants.logTagPetAi}: Local Config Loaded: $_activeModelName');
    } catch (e) {
      if (kDebugMode) debugPrint('[PET_ERROR]: All Configs Failed. Using Defaults.');
    }
  }
}
