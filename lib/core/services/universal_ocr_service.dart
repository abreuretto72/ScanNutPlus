import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scannutplus/core/services/env_service.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

/// MOTOR 2: UNIVERSAL OCR SERVICE (Data Extraction)
/// Responsible for: Lab Exams, Prescriptions, Labels, and Botanical Reports.
class UniversalOcrService {
  static final UniversalOcrService _instance = UniversalOcrService._internal();
  factory UniversalOcrService() => _instance;
  UniversalOcrService._internal();

  GenerativeModel? _model;
  String? _activeModelName;
  String? _lastUsedModel;

  /// Main OCR Processing Method
  Future<String> processOcr({
    required File documentImage,
    required String expertise,
    required String languageCode,
    String? targetFields,
    required AppLocalizations l10n,
  }) async {
    try {
      await _syncConfigFromServer();

      final targetModel = _activeModelName ?? 'gemini-2.5-pro';
      debugPrint('[UNIVERSAL_OCR_LOG] Active Model: $targetModel');
      
      if (_model == null || _lastUsedModel != targetModel) {
        _model = GenerativeModel(
          model: targetModel,
          apiKey: EnvService.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.0, // Precision lock for technical data
            maxOutputTokens: 4096, 
          ),
        );
        _lastUsedModel = targetModel;
      }

      String systemPrompt;

      if (expertise.contains('Botanist')) {
        // --- BOTANICAL MODE (PLANTS) ---
        systemPrompt = '''
          SCANNUT MASTER PROTOCOL - BOTANICAL MODE 2026
          OBJECTIVE: Species identification and plant health diagnosis via image.
          EXPERTISE: $expertise

          ANALYSIS GUIDELINES:
          1. IDENTIFICATION: Scientific name, common name, and botanical family.
          2. HEALTH: Analyze spots, dry edges, or pests (Mealybugs, Mites, Fungi).
          3. TOXICITY: Mandatory check if the plant is toxic to PETS (Dogs/Cats) or CHILDREN.
          4. MAINTENANCE: Light needs (Sun/Shade), watering frequency, and soil type.

          MANDATORY OUTPUT STRUCTURE:
          
          PART 1: MOBILE CARDS (MANDATORY)
          - Generate exactly 3 to 6 interpretive cards using these markers:
            [CARD_START]
            TITLE: [Name in $languageCode]
            ICON: [Emoji or Material Icon name like 'local_florist'/'warning']
            CONTENT: [Summary in $languageCode using 🟢 (Safe/Healthy) or 🔴 (Toxic/Sick). Keep it direct.]
            [CARD_END]

          [SOURCES]
          - MANDATORY: Generate a list of sources using exactly this structure:
            1. "ScanNut Botanical Database": Cross-referenced with technical catalog.
            2. "Visual Morphological Analysis": Direct diagnostic from image.
          - Format: Use bullet points.
          
          IMPORTANT RULES:
          - DO NOT TRANSLATE KEYS: 'TITLE', 'ICON', 'CONTENT'.
          - ONLY TRANSLATE THE VALUES to $languageCode.
          - Output strictly in $languageCode.
        ''';
      } else {
        // --- DEFAULT MODE (LABELS / EXAMS) ---
        systemPrompt = '''
          SCANNUT MASTER PROTOCOL - MULTIMODAL MODE 2026
          OBJECTIVE: Technical data extraction from Nutrition Labels or Lab Exams.
          EXPERTISE: $expertise

          EXTRACTION RULES:
          1. STRUCTURED DATA: Use strict Markdown Tables for ANY quantitative data.
             - Table Format MUST include leading and trailing pipes:
             | Parameter | Value | Reference | Status |
          2. IF EXAM (LAB): 
             - SPLIT complex exams into separate cards (e.g., [CARD] Erythrogram, [CARD] Leukogram).
             - Extract: Analyte, Value, Unit, Reference Range.
             - ALERTS: Use 🔴 for OUT of range, 🟢 for Normal.
          3. IF LABEL (NUTRITION): 
             - Extract Protein, Fat, Calcium, Phosphorus as a strict Markdown Table.
          4. IDENTIFICATION: Locate Manufacturer/Brand or Patient/Lab name.
          5. SCIENTIFIC TRUTH: Do not hallucinate. If unreadable, mark as "-".

          MANDATORY OUTPUT STRUCTURE:
          
          PART 1: MOBILE CARDS (MANDATORY)
          - Generate exactly 3 to 6 interpretive cards using these markers:
            [CARD_START]
            TITLE: [Section Name in $languageCode e.g., "Hemogram - Red Series"]
            ICON: [Emoji or 'biotech'/'description'/'warning']
            CONTENT: 
            [Brief summary line in $languageCode]
            
            | Parameter | Value | Ref | Status |
            | :--- | :--- | :--- | :---: |
            | Exemplo | 12.5 | 10-15 | 🟢 |
            (Populate with extracted data)
            
            [Add brief interpretation in $languageCode if needed]
            [CARD_END]

          [SOURCES]
          - MANDATORY: Generate a list of sources:
            - "Primary Data (Label/Exam)": Direct reading of analytes.
            - "ScanNut Database": Cross-referenced with veterinary literature.
            - "International Regulations": Compliance with FEDIAF/AAFCO guidelines.
          
          IMPORTANT RULES:
          - DO NOT TRANSLATE KEYS: 'TITLE', 'ICON', 'CONTENT'.
          - ONLY TRANSLATE THE VALUES to $languageCode.
          - FINAL COMMAND: Output strictly in $languageCode.
        ''';
      }

      final imageBytes = await documentImage.readAsBytes();
      final content = [
        Content.multi([
          TextPart(systemPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model!.generateContent(content);
      String extractedText = response.text ?? "";
      
      debugPrint('[UNIVERSAL_OCR_TRACE] Raw AI Response:\n$extractedText');

      if (extractedText.isEmpty) {
        debugPrint('[UNIVERSAL_OCR_ERROR] AI returned an empty response.');
        return "[CARD_START]\nTITLE: Analysis Error\nICON: error\nCONTENT: AI returned an empty response. Verify your API Key and internet connection.\n[CARD_END]";
      }
      return _sanitizeOutput(extractedText);

    } catch (e) {
      debugPrint('[UNIVERSAL_OCR_ERROR]: $e');
      final errorStr = e.toString();
      
      if (errorStr.contains('Unhandled format') || errorStr.contains('Google Generative AI SDK')) {
           return "[CARD_START]\nTITLE: ${l10n.pet_label_info}\nICON: info\nCONTENT: ${l10n.pet_error_ai_unhandled_format}\n[CARD_END]";
      }
      
      return "[CARD_START]\nTITLE: System Error\nICON: error\nCONTENT: Exception during OCR Analysis:\n$e\n[CARD_END]";
    }
  }

  String _sanitizeOutput(String text) {
    return text
        .replaceAll('```json', '')
        .replaceAll('```markdown', '')
        .replaceAll('```', '')
        .trim();
  }

  Future<void> _syncConfigFromServer() async {
    try {
      final baseUrl = dotenv.env['SITE_BASE_URL'];
      if (baseUrl == null) return;
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'User-Agent': 'ScanNutApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final config = json.decode(response.body);
        _activeModelName = config['active_model'];
      }
    } catch (e) {
      debugPrint('[OCR_CONFIG_WARN]: Server offline.');
    }
  }
}