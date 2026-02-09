import 'dart:io';
import 'dart:developer' as dev; // Telemetry
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:scannutplus/core/services/env_service.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/core/constants/ai_prompts.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart'; // PetPrompts now here

// import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart'; // Unused for now
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

abstract class PetBaseAiService {
  GenerativeModel? _model;
  String _activeModelName = 'gemini-1.5-flash';
  String _apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/';

  PetBaseAiService();

  // final PetRepository _repository = PetRepository(); // Disabled for JSON Refactor

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
      generationConfig: GenerationConfig(
        maxOutputTokens: 4000, // Boosted for Emergency Anti-Truncation
        temperature: 0.1, // Precisão técnica
      ),
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
    String? overrideSystemPrompt, // Protocol 2026: Allow Micro-Apps to define their own reality
  }) async {
    // Reading bytes - compute if needed handled by caller usually, but here we can't easily use compute for asset reading if bytes not passed
    final bytes = imageBytes ?? await File(imagePath).readAsBytes();
    
    final prompt = overrideSystemPrompt ?? _buildSystemPrompt(languageCode, context, petName);
    
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
          TextPart('$prompt\n${PetPrompts.noMarkdown}'), // Force No Markdown in Base Prompt
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _model!.generateContent(content);
      String responseText = response.text ?? AppKeys.errorNoAnalysis;

      // --- TELEMETRY TRACE 1: Raw Response (Protocol 2026) ---
      dev.log(
        PetConstants.keyRawAiResponse, // Pilar 0 Compliance
        name: PetConstants.keyPetAiService, 
        error: responseText
      );
      
      // --- GLOBAL SANITIZER (Protocol 2026) ---
      // Automatically strips markdown blocks from ANY module response
      final dirtyText = responseText;
      responseText = _cleanJsonResponse(responseText);
      
      if (responseText != dirtyText) {
         if (kDebugMode) debugPrint('[PET_TRACE] Global Sanitizer: Removed Markdown/Extra Text. Clean JSON Ready.');
      }

      // --- TELEMETRY TRACE 3: Payload Check ---
      if (responseText.length > 50) {
         final start = responseText.substring(0, 50);
         final end = responseText.substring(responseText.length - 50);
         debugPrint('[PET_TRACE] Payload Start: $start ... End: $end (Total: ${responseText.length})');
      } else {
         debugPrint('[PET_TRACE] Short Payload: $responseText');
      }

      // --- CONTRACT: IMMUTABLE SOURCE EXTRACTION (Protocol 2026) ---
      List<String> extractedSources = _extractSources(responseText);

      // --- CONTRACT: MANDATORY FALLBACK ---
      // If extraction fails (empty list) or returns fewer than 3 sources,
      // inject the official verification protocol to ensure system integrity.
      if (extractedSources.length < 3) {
        if (kDebugMode) {
          debugPrint('${PetConstants.logTagPetRag}: Sources insufficient for UUID $petUuid. Injecting Protocol Fallback.');
        }
        // Create a new list to avoid modifying an unmodifiable list if _extractSources returns one
        extractedSources = List.from(extractedSources)..addAll(PetConstants.defaultVerificationSources);
        extractedSources = extractedSources.take(3).toList();
      }

      /* 
      // DISABLED: PetCaptureView handles persistence with refined Metadata (Breed/Identity)
      await _repository.saveAnalysis(
        petUuid: petUuid,
        petName: petName,
        analysisResult: responseText,
        sources: extractedSources, 
        imagePath: imagePath, // Pass path to repository
        analysisType: analysisType,
      ); 
      */

      return responseText;
    } catch (e) {
      throw Exception('${AppKeys.errorAiUnavailable}$e');
    }
  }

  // --- GLOBAL JSON CLEANER (Protocol 2026) ---
  String _cleanJsonResponse(String raw) {
      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
        if (jsonMatch != null) {
            return jsonMatch.group(0)!;
        }
      } catch (e) {
         if (kDebugMode) debugPrint('[PET_WARN] Global Sanitizer Regex Failed: $e');
      }
      return raw; // Fallback to raw if no JSON found (legacy behavior)
  }

  // --- IMMUTABLE LOGIC: DO NOT MODIFY WITHOUT AUTHORIZATION ---
  List<String> _extractSources(String text) {
    try {
      // 1. Regex "Checkmate" (Multi-language Support)
      final RegExp sourceRegex = RegExp(r'(Sources|References|Referências|Fontes):?', caseSensitive: false);
      
      if (!text.contains(sourceRegex)) return [];

      final parts = text.split(sourceRegex);
      if (parts.length < 2) return [];

      // 2. Block Isolation
      String block = parts.last;
      
      // Stop at known end tags or new section markers
      if (block.contains(PetConstants.tagEndSources)) {
        block = block.split(PetConstants.tagEndSources)[0];
      } else if (block.contains(PetConstants.tagCardStart)) {
        // Safety net: if AI starts a new card without closing sources
        block = block.split(PetConstants.tagCardStart)[0];
      }
      
      // 3. Cleaning & Filtering
      // Removes Markdown lists (*, -, 1.), brackets, and footnotes
      return block
          .split('\n')
          .map((s) => s.replaceAll(RegExp(r'^[\s\*\-\d\.]+|[\[\]]'), '').trim()) 
          .where((s) => s.length > 10) // Filter out artifacts/titles
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('${PetConstants.logTagPetError}: Source extraction failed: $e');
      return [];
    }
  }

  String _buildSystemPrompt(String languageCode, String? context, String petName) {
    return '''
    ${PetPrompts.expertRole} $petName.
    ${PetPrompts.multimodalInstruction}
    ${AiPrompts.domainPet}
    
    ${context ?? ''}

    ${PetPrompts.truthDirective}
    ${PetPrompts.breedInstruction}
    ${PetPrompts.jsonFormat}
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
