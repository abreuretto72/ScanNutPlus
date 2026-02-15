import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scannutplus/core/services/env_service.dart';

/// MOTOR 2: UNIVERSAL OCR SERVICE (Extração de Dados)
/// Responsável por: Exames Laboratoriais, Receitas, Rótulos e Laudos.
class UniversalOcrService {
  static final UniversalOcrService _instance = UniversalOcrService._internal();
  factory UniversalOcrService() => _instance;
  UniversalOcrService._internal();

  GenerativeModel? _model;
  String? _activeModelName;
  String? _lastUsedModel; // Track manually since GenerativeModel doesn't expose it

  /// Método Principal de OCR
  Future<String> processOcr({
    required File documentImage,
    required String expertise,
    required String languageCode,
    String? targetFields,
  }) async {
    try {
      // 1. Sincroniza modelo com o servidor
      await _syncConfigFromServer();

      final targetModel = _activeModelName ?? 'gemini-1.5-flash';
      debugPrint('[UNIVERSAL_OCR_LOG] Active Model: $targetModel');
      
      // 2. Inicializa o motor Gemini 2.5 Pro (Temperature 0.0 para precisão total)
      if (_model == null || _lastUsedModel != targetModel) {
        _model = GenerativeModel(
          model: targetModel,
          apiKey: EnvService.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.0, // Fidelidade total aos dados do papel
            maxOutputTokens: 4096, 
          ),
        );
        _lastUsedModel = targetModel;
      }

      // 3. PROMPT DE OCR INTERNACIONALIZADO
      final String systemPrompt = '''
        ROLE: You are an expert in Veterinary Medical Document Digitization and Analysis ($expertise).
        TASK: Extract all technical data from the image with 100% fidelity.

        STRICT EXTRACTION RULES:
        1. DATA FIDELITY: Transcribe values, units (mg/dL, UI/L), and notes exactly as printed.
        2. REFERENCE VALUES: For each parameter, extract the 'Measured Value' and the 'Reference Range' (Min/Max).
        3. SCIENTIFIC TRUTH: Do not invent data. If a value is unreadable, mark it as "UNREADABLE".
        
        STRUCTURE:
        PART 1: VISUAL SUMMARY (Mandatory for User UI)
        - Generate exactly 3 to 5 interpretive cards using these markers:
          [CARD_START]
          TITLE: (Exam Name/Category, e.g., "Hemograma")
          ICON: (Related Emoji)
          CONTENT: (Brief summary of key findings, e.g., "Hemácias normal, Leucócitos elevados.")
          [CARD_END]

        PART 2: RAW DATA (For Database)
        - Format the technical data in a clean JSON object.
        
        [SOURCES]
        (Cite scientific sources that validate these reference ranges, e.g., Merck Manual).

        IMPORTANT:
        - Your entire response and JSON keys must be generated in: $languageCode.
        - No Markdown code blocks. No 'ICON:' or 'CONTENT:' tags inside the CONTENT block.

        FINAL COMMAND: Output strictly in $languageCode.
      ''';

      final imageBytes = await documentImage.readAsBytes();
      final content = [
        Content.multi([
          TextPart(systemPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model!.generateContent(content);
      return _sanitizeOutput(response.text ?? "{}");

    } catch (e) {
      debugPrint('[UNIVERSAL_OCR_ERROR]: $e');
      return "{}";
    }
  }

  /// Limpa a resposta de blocos de código e etiquetas de sistema
  String _sanitizeOutput(String text) {
    return text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
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
      debugPrint('[OCR_CONFIG_WARN]: Server offline.');
    }
  }
}