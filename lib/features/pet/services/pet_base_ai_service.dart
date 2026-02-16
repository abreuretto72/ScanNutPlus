import 'dart:io';
import 'dart:developer' as dev; // Telemetry
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:scannutplus/core/services/env_service.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/core/constants/ai_prompts.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class PetAiOverloadException implements Exception {
  final String message;
  PetAiOverloadException([this.message = PetConstants.msgAiOverloaded]);
  @override
  String toString() => message;
}

abstract class PetBaseAiService {
  GenerativeModel? _model;
  
  // CORREÇÃO: Removido o modelo fixo 'gemini-2.5-pro'. 
  // O modelo agora é inicializado como nulo para forçar a carga do servidor.
  String? _activeModelName;
  
  String _apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/';

  PetBaseAiService();

  Future<void> _ensureInitialized() async {
    // Pilar: Garantir que o EnvService esteja pronto
    await EnvService.init();

    // 1. Coleta a configuração remota ANTES de verificar o modelo
    final String? modelBeforeConfig = _activeModelName;
    await _loadConfig();

    final apiKey = EnvService.geminiApiKey;
    if (apiKey.isEmpty) {
       throw Exception(AppKeys.errorGeminiMissing); 
    }
    
    // 2. Só inicializa ou recria o modelo se ele for nulo ou se o nome mudou no servidor
    if (_model == null || modelBeforeConfig != _activeModelName) {
      if (_activeModelName == null) {
        debugPrint('[CONFIG_FATAL] Falha ao obter model_id do servidor.');
        throw Exception("Configuração de IA não encontrada no servidor.");
      }
      
      debugPrint('[CONFIG_TRACE] Modelo antigo: $modelBeforeConfig -> Novo modelo: $_activeModelName. Reiniciando engine.');

      _model = GenerativeModel(
        model: _activeModelName!,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 4000,
          temperature: 0.1, 
        ),
      );
    }
  }



  Future<String> analyzePetImageBase({
    required String imagePath,
    required String languageCode,
    String? context,
    Uint8List? imageBytes,
    required String petName,
    required String petUuid, 
    String analysisType = PetConstants.typeClinical,
    String? overrideSystemPrompt,
    String? mimeType, 
  }) async {
    final bytes = imageBytes ?? await File(imagePath).readAsBytes();
    final prompt = overrideSystemPrompt ?? _buildSystemPrompt(languageCode, context, petName);
    
    // Auto-detect MimeType if not provided
    final String finalMimeType = mimeType ?? _detectMimeType(imagePath);

    await _ensureInitialized(); 

    try {
      final content = [
        Content.multi([
          TextPart('$prompt\n${PetPrompts.noMarkdown}'), 
          DataPart(finalMimeType, bytes),
        ])
      ];

      final response = await _model!.generateContent(content);
      String responseText = response.text ?? AppKeys.errorNoAnalysis;

      // --- TELEMETRIA TRACE: Raw Response ---
      dev.log(
        PetConstants.keyRawAiResponse,
        name: PetConstants.keyPetAiService, 
        error: responseText
      );
      
      // --- GLOBAL SANITIZER: Remove Markdown Blocks & Tags ---
      responseText = _cleanJsonResponse(responseText);
      
      if (kDebugMode) {
        debugPrint('[SANITIZER_TRACE] Removendo tags residuais da resposta final.');
        debugPrint('[PET_TRACE] Resposta Sanitizada enviada para processamento.');
      }

      return responseText;
    } catch (e) {
      if (kDebugMode) debugPrint('[PET_ERROR_RAW] $e');
      if (e.toString().contains('500') || e.toString().contains('overload')) {
         throw PetAiOverloadException();
      }
      throw Exception('${AppKeys.errorAiUnavailable}$e');
    }
  }

  // --- GLOBAL JSON CLEANER ---
  String _cleanJsonResponse(String raw) {
      String clean = raw;
      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
        if (jsonMatch != null) {
            clean = jsonMatch.group(0)!;
        } else {
            // Se não for JSON, mantém o texto original para que o parser de Cards funcione
            // A limpeza de tags visuais será feita na Camada de View (PetAnalysisResultView/PetAiCardsRenderer)
            // clean = clean.replaceAll(RegExp(r'(ICON:|CONTENT:)', caseSensitive: false), '').trim();
        }
      } catch (e) {
         if (kDebugMode) debugPrint('[PET_WARN] Global Sanitizer Regex Failed: $e');
      }
      return clean; 
  }

  // ... (sources extraction remains same)

  String _buildSystemPrompt(String languageCode, String? context, String petName) {
    debugPrint('[PROMPT_TRACE] Enviando diretrizes de Raça e Saúde para o modelo $_activeModelName.');

    return '''
    ${PetPrompts.expertRole} $petName.
    ${PetPrompts.multimodalInstruction}
    ${AiPrompts.domainPet}
    ${context ?? ''}
    
    COMPREHENSIVE ANALYSIS PRIORITY:
    1. BREED/GENETICS: Identify breed, mixtures, or phenotype (Mandatory).
    2. BEHAVIOR/POSTURE: Analyze stance, expression, and potential emotional state.
    3. CLINICAL/HEALTH: Dermatological, orthopedic, or general health observations.

    ${PetPrompts.truthDirective}
    ${PetPrompts.breedInstruction}
    ${PetPrompts.visualSummary}
    ${PetPrompts.sourceMandatory}
    ${PetPrompts.jsonFormat}

    CRITICAL: 'ICON:' and 'CONTENT:' are internal structural delimiters for your logic. 
    Use them ONLY inside [CARD] blocks if strictly required by format, but NEVER output them as visible text in the description.
    
    ${AiPrompts.outputLang}$languageCode.
    ''';
  }

  // --- CARGA DE CONFIGURAÇÃO (CORRIGIDA) ---
  Future<void> _loadConfig() async {
    try {
      // Coleta a URL completa definida no seu .env
      final targetUrl = dotenv.env['SITE_BASE_URL'];
      
      if (targetUrl != null && targetUrl.isNotEmpty) {
        debugPrint('[CONFIG_TRACE] Lendo config remota em: $targetUrl');
        
        final url = Uri.parse(targetUrl);
        final response = await http.get(url).timeout(const Duration(seconds: 10)); 
        
        if (response.statusCode == 200) {
          final config = json.decode(response.body);
          
          // Prioriza o active_model do seu JSON
          if (config['active_model'] != null) {
             _activeModelName = config['active_model'];
             debugPrint('[CONFIG_TRACE] Modelo atualizado via Servidor: $_activeModelName');
             return;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[PET_WARN]: Servidor remoto inacessível. Tentando Local...');
    }

    // Fallback para Local Asset se o remoto falhar
    try {
      final configStr = await rootBundle.loadString('assets/config.json');
      final config = json.decode(configStr);
      _activeModelName = config['active_model'] ?? 'gemini-2.5-pro';
    } catch (e) {
      _activeModelName = 'gemini-2.5-pro'; // Strict Fallback (Rule 3)
    }
  }

  String _detectMimeType(String path) {
    try {
      final extension = path.split('.').last.toLowerCase();
      
      if (['mp4', 'mov', 'avi', 'wmv', 'mpeg4', 'webm'].contains(extension)) {
        if (extension == 'mov') return 'video/quicktime';
        if (extension == 'avi') return 'video/x-msvideo';
        if (extension == 'webm') return 'video/webm';
        return 'video/mp4';
      }
      
      if (['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'].contains(extension)) {
         if (extension == 'wav') return 'audio/wav';
         if (extension == 'mp3') return 'audio/mpeg';
         if (extension == 'm4a') return 'audio/mp4';
         if (extension == 'aac') return 'audio/aac';
         if (extension == 'ogg') return 'audio/ogg';
         return 'audio/mpeg';
      }
      
      if (extension == 'png') return 'image/png';
      if (extension == 'webp') return 'image/webp';
      if (extension == 'heic') return 'image/heic';
      if (extension == 'gif') return 'image/gif';
      return 'image/jpeg';
    } catch (e) {
      if (kDebugMode) debugPrint('[PET_WARN] MimeType detection failed: $e. Defaulting to jpeg.');
      return 'image/jpeg';
    }
  }
}