import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scannutplus/core/services/env_service.dart';
import 'package:path/path.dart' as p;

class UniversalAiService {
  static final UniversalAiService _instance = UniversalAiService._internal();
  factory UniversalAiService() => _instance;
  UniversalAiService._internal();

  GenerativeModel? _model;
  String? _activeModelName;
  String? _lastInitializedModelName;

  /// MÉTODO MESTRE: Analisa Imagem, Vídeo ou Áudio (Vocalização)
  Future<String> analyze({
    required File file,
    required String expertise,
    required String context,
    required String languageCode,
    String? petName,
  }) async {
    try {
      // Sincroniza configuração com o servidor de controle
      await _syncConfigFromServer();
      
      final targetModel = _activeModelName ?? 'gemini-1.5-flash'; // Reverted to Flash (fast & default)

      // Log de rastreio para o fluxo de análise
      debugPrint('[AI_FLOW_TRACE] Expertise: $expertise | Language: $languageCode');
      debugPrint('[AI_FLOW_TRACE] Target Model: $targetModel');

      if (_model == null || targetModel != _lastInitializedModelName) {
        _model = GenerativeModel(
          model: targetModel,
          apiKey: EnvService.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 4096, 
          ),
        );
        _lastInitializedModelName = targetModel;
      }

      // 1. DETECÇÃO MULTIMODAL REFINADA (MimeTypes Específicos)
      final String extension = p.extension(file.path).toLowerCase();
      String mimeType = 'image/jpeg'; 
      String mediaTypeTask = 'IMAGE. Observe clinical signs, lesions, or physical characteristics.';

      if (['.mp4', '.mov', '.avi', '.wmv'].contains(extension)) {
        if (extension == '.mov') mimeType = 'video/quicktime';
        else if (extension == '.avi') mimeType = 'video/x-msvideo';
        else mimeType = 'video/mp4';
        
        // [SMART DETECT]
        if (context.contains('Behavior') || context.contains('Comportamento')) {
             mediaTypeTask = 'VIDEO (DUAL FOCUS). PRIORITY: Analyze BOTH visual movement (gait, posture, head pressing) AND audio (barks, whines, breathing). Correlate them.';
        } else if (context.contains('Audio') || context.contains('Vocalization') || context.contains('Vocal')) {
            mediaTypeTask = 'VIDEO (AUDIO FOCUS). PRIORITY: Listen to the audio track. Identify coughs, breathing, barks, or vocalization anomalies. Visuals are secondary context.';
        } else {
            mediaTypeTask = 'VIDEO. Observe movements, gait, behavior, and any visible clinical signs over time.';
        }
      } else if (['.mp3', '.wav', '.m4a', '.aac', '.ogg'].contains(extension)) {
        if (extension == '.wav') mimeType = 'audio/wav';
        else if (extension == '.m4a') mimeType = 'audio/mp4'; // m4a is audio/mp4 often accepted
        else if (extension == '.ogg') mimeType = 'audio/ogg';
        else mimeType = 'audio/mpeg';
        mediaTypeTask = 'AUDIO/VOCALIZATION. Listen carefully to coughs, breathing patterns, barks, or meows. Identify frequency and clinical respiratory sounds.';
      }

      // 2. PROMPT INTERNACIONALIZADO E ADAPTATIVO
      final String systemPrompt = '''
        ROLE: You are a Senior Veterinary Specialist in $expertise.
        CONTEXT: Analyzing a pet named ${petName ?? 'Patient'} with the following details: "$context".
        TASK: You are analyzing a $mediaTypeTask

        STRICT RESPONSE GUIDELINES:
        1. SCIENTIFIC TRUTH: Base your analysis on clinical facts. Cite real scientific sources (e.g., Merck Manual, WSAVA).
        2. STRUCTURE: Use the exact markers below:
           
           [VISUAL_SUMMARY]
           (3-line summary about breed, state, and findings from the provided media).

           [CARD_START]
           TITLE: (Section Title - New Line)
           ICON: (Material Icon name or Emoji - New Line)
           CONTENT: (Detailed technical report. Do NOT use 'ICON:' or 'CONTENT:' inside this block).
           [CARD_END]

           [SOURCES]
           (Bibliographic references).

        3. OUTPUT LANGUAGE: You must generate the entire response strictly in the language: $languageCode.
        
        IMPORTANT: No Markdown code blocks. Output language is $languageCode.
        FINAL COMMAND: Strictly use the markers [CARD_START] and [CARD_END].
      ''';

      final fileBytes = await file.readAsBytes();
      final fileSizeMb = fileBytes.lengthInBytes / (1024 * 1024);

      debugPrint('[AI_DEBUG] ----------------------------------------------------------------');
      debugPrint('[AI_DEBUG] Analyzing File: ${file.path}');
      debugPrint('[AI_DEBUG] Size: ${fileSizeMb.toStringAsFixed(2)} MB');
      debugPrint('[AI_DEBUG] MimeType sent to API: $mimeType');
      debugPrint('[AI_DEBUG] Model Info: $_activeModelName (Target: $targetModel)');
      debugPrint('[AI_DEBUG] ----------------------------------------------------------------');

      if (fileSizeMb > 20.0) {
         debugPrint('[AI_WARNING] File size > 20MB. API might reject inline data.');
      }

      final content = [Content.multi([TextPart(systemPrompt), DataPart(mimeType, fileBytes)])];

      // Chamada com Log de Resposta Raw para Debug
      final response = await _model!.generateContent(content);
      final rawText = response.text ?? "Error generating report.";
      
      debugPrint('[AI_RAW_RESPONSE_START]\n$rawText\n[AI_RAW_RESPONSE_END]');
      
      return _sanitizeOutput(rawText);
      
    } catch (e) {
      debugPrint('[UNIVERSAL_AI_ERROR]: $e');
      return "Technical error during analysis: $e";
    }
  }

  /// MÉTODO RAG: Análise Textual (Histórico/Contexto)
  Future<String> analyzeText({
    required String systemPrompt,
    required String userPrompt,
    String? modelName,
  }) async {
    try {
      await _syncConfigFromServer();
      final targetModel = modelName ?? _activeModelName ?? 'gemini-1.5-flash';

      if (_model == null || targetModel != _lastInitializedModelName) {
        _model = GenerativeModel(
          model: targetModel,
          apiKey: EnvService.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.2, // Slightly higher for creative but grounded text
            maxOutputTokens: 8192,
          ),
        );
        _lastInitializedModelName = targetModel;
      }

      final content = [Content.multi([TextPart(systemPrompt), TextPart(userPrompt)])];

      debugPrint('[AI_RAG_TRACE] Sending Text Request to $targetModel');
      final response = await _model!.generateContent(content);
      return _sanitizeOutput(response.text ?? "Error generating text report.");

    } catch (e) {
      debugPrint('[UNIVERSAL_AI_ERROR] RAG Failed: $e');
      return "Technical error during text analysis: $e";
    }
  }


  String _sanitizeOutput(String text) {
    return text.replaceAll('```json', '').replaceAll('```', '').trim();
  }

  Future<void> _syncConfigFromServer() async {
    try {
      final baseUrl = dotenv.env['SITE_BASE_URL'];
      if (baseUrl == null) return;
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final config = json.decode(response.body);
        _activeModelName = config['active_model'];
      }
    } catch (e) {
      debugPrint('[AI_CONFIG_WARN]: Server offline or timeout.');
    }
  }
}