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

      final targetModel = _activeModelName ?? 'gemini-2.5-pro';
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

      // 3. PROMPT DE OCR INTERNACIONALIZADO (PROTOCOLO MASTER 2026)
      // 3. PROMPT DE OCR INTERNACIONALIZADO (PROTOCOLO MASTER 2026)
      String systemPrompt;

      if (expertise.contains('Botanist')) {
         // --- MODO BOTÂNICO (PLANTS) ---
         systemPrompt = '''
          PROTOCOLO MASTER SCANNUT - MODO BOTÂNICO 2026
          OBJETIVO: Identificação de espécie e diagnóstico de saúde vegetal via imagem.
          EXPERTISE: $expertise

          DIRETRIZES DE ANÁLISE:
          1. IDENTIFICAÇÃO: Nome científico, nome popular e família botânica.
          2. SAÚDE: Analisar manchas, bordas secas ou pragas (Cochonilha, Ácaro, Fungos).
          3. TOXICIDADE: Verificar obrigatoriamente se a planta é tóxica para PETS (Cães/Gatos) ou CRIANÇAS.
          4. MANUTENÇÃO: Necessidade de luz (Sol/Sombra), frequência de rega e tipo de solo.

          SAÍDA OBRIGATÓRIA:
          
          PART 1: MOBILE CARDS (UI OPTIMIZED)
          - Generate exactly 3 to 6 interpretive cards using these markers:
            [CARD_START]
            TITLE: [Name in $languageCode]
            ICON: [Emoji or 'local_florist'/'warning']
            CONTENT: [Summary using 🟢 (Seguro/Saudável) or 🔴 (Tóxico/Doente). Keep it direct.]
            [CARD_END]

          PART 2: RAW DATA
          - Format the technical data in a clean JSON object.

          [SOURCES]
          - MANDATORY: Generate a list of sources using exactly this structure:
            1. "Base Botânica ScanNut": Cruzamento com catálogo técnico.
            2. "Análise Visual": Diagnóstico morfologico.
          - Format: Use bullet points.
          
          IMPORTANT STRUCTURE RULES:
          - DO NOT TRANSLATE THE KEYS: 'TITLE', 'ICON', 'CONTENT'. 
          - KEEP THEM EXACTLY AS SHOWN IN ENGLISH.
          - ONLY TRANSLATE THE VALUES.
          - No Markdown code blocks explicitly around the cards (just text).
          
          FINAL COMMAND: Output strictly in $languageCode.
        ''';
      } else {
         // --- MODO PADRÃO (LABELS / EXAMS) ---
         systemPrompt = '''
          PROTOCOLO MASTER SCANNUT - MODO MULTIMODAL 2026
          OBJETIVO: Extração técnica de dados de Rótulos de Nutrição ou Exames Laboratoriais.
          EXPERTISE: $expertise

          DIRETRIZES DE EXTRAÇÃO (RULES):
          1. SE RÓTULO (LABEL): Extrair Proteína, Gordura, Cálcio, Fósforo, Kcal/kg e Tabela de Consumo (g/dia).
          2. SE EXAME (LAB): Extrair Analito, Valor Encontrado, Unidade de Medida e Valor de Referência.
          3. IDENTIFICAÇÃO: Localizar nome do fabricante/marca ou nome do paciente/laboratório.
          4. ALERTAS: Destacar componentes fora do padrão (ex: excesso de fósforo em ração ou valores alterados em exames).
          5. SCIENTIFIC TRUTH: Do not invent data. If a value is unreadable, mark it as "UNREADABLE".

          STRUCTURE (MANDATORY OUTPUT):
          
          PART 1: MOBILE CARDS (UI OPTIMIZED)
          - Generate exactly 3 to 6 interpretive cards using these markers:
            [CARD_START]
            TITLE: [Name in $languageCode]
            ICON: [Emoji or 'biotech'/'description']
            CONTENT: [Summary using 🟢 for normal/success and 🔴 for alerts/errors. Keep it direct.]
            [CARD_END]

          PART 2: RAW DATA
          - Format the technical data in a clean JSON object.

          [SOURCES]
          - MANDATORY: Generate a list of sources using exactly this structure:
            1. "Dados Primários (Rótulo/Laudo)": Leitura direta dos níveis de garantia/analitos.
            2. "Base de Dados ScanNut": Cruzamento com catálogo técnico e literatura veterinária.
            3. "Regulação Internacional": Conformidade com diretrizes da FEDIAF e AAFCO.
          - Format: Use bullet points.
          
          IMPORTANT STRUCTURE RULES:
          - DO NOT TRANSLATE THE KEYS: 'TITLE', 'ICON', 'CONTENT'. 
          - KEEP THEM EXACTLY AS SHOWN IN ENGLISH.
          - ONLY TRANSLATE THE VALUES.
          - No Markdown code blocks explicitly around the cards (just text).
          
          FINAL COMMAND: Output strictly in $languageCode.
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
      
      // [FIX SDK ERROR]: Safely extract text avoiding 'Unhandled format' exception
      String extractedText;
      try {
        if (response.candidates.isNotEmpty && 
            response.candidates.first.content.parts.isNotEmpty) {
           final part = response.candidates.first.content.parts.first;
           if (part is TextPart) {
              extractedText = part.text;
           } else {
              extractedText = response.text ?? ""; 
           }
        } else {
           extractedText = response.text ?? "";
        }
      } catch (e) {
         debugPrint('[UNIVERSAL_OCR_WARN] SDK .text access failed: $e. Using fallback.');
         // Fallback: Dump candidates to see what's happening
         extractedText = response.candidates.map((c) => c.content.parts.map((p) => p is TextPart ? p.text : '').join()).join('\n');
      }

      if (extractedText.isEmpty) {
         debugPrint('[UNIVERSAL_OCR_ERROR] Empty response from Gemini.');
         return "{}";
      }

      return _sanitizeOutput(extractedText);

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
        .replaceAll(RegExp(r'(?:ICON|ÍCONE|ICONE|Ícone|Icone):'), '')
        .replaceAll(RegExp(r'(?:CONTENT|CONTEÚDO|CONTEUDO|Conteúdo|Conteudo):'), '')
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