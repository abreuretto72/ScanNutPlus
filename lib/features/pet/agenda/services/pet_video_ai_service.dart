import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/core/services/env_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PetVideoAiService extends PetBaseAiService {
  
  static final PetVideoAiService _instance = PetVideoAiService._internal();
  factory PetVideoAiService() => _instance;
  PetVideoAiService._internal();

  String _buildVideoPrompt(String name, String? notes, String lang) {
    return '''
    Role: Veterinary Physiotherapist and Ethologist.
    Analyze the movement and behavior of the pet: $name.
    User/Tutor notes: ${notes ?? PetConstants.defaultNoNotes}.
    
    FORMAT GUIDELINES:
    1. URGENCY: [GREEN|YELLOW|RED]
    2. [VISUAL_SUMMARY] 3-line summary. [END_SUMMARY]
    3. [CARD_START] TITLE: Posture & Gait Analysis ICON: videocam [CARD_END]
    4. [CARD_START] TITLE: Behavioral Etogram ICON: psychology [CARD_END]
    5. [SOURCES] Veterinary Manuals [END_SOURCES]
    
    Output Language: $lang.
    ''';
  }

  Future<String> analyzeVideo({
    required File videoFile,
    required String petName,
    String? notes,
    String? lang,
  }) async {
    try {
      final apiKey = EnvService.geminiApiKey;
      if (apiKey.isEmpty) throw Exception(PetConstants.errApiKeyMissing);

      // --- INÍCIO DA COLETA REAL VIA CONFIG REMOTO ---
      String modelName = 'gemini-1.5-flash'; // Fallback apenas se a rede falhar
      
      try {
        final baseUrl = dotenv.env['SITE_BASE_URL'] ?? '';
        // Correção da URL: concatenando o caminho do arquivo json
        final fullConfigUrl = '${baseUrl}config/food_config.json';
        
        debugPrint('[CONFIG_TRACE] Coletando config em: $fullConfigUrl');
        
        if (baseUrl.isNotEmpty) {
           final response = await http.get(Uri.parse(fullConfigUrl)).timeout(const Duration(seconds: 8));
           if (response.statusCode == 200) {
              final jsonConfig = jsonDecode(response.body);
              if (jsonConfig['model_id'] != null) {
                 // RESPEITO AO SERVIDOR: Coleta o que está no JSON sem overrides
                 modelName = jsonConfig['model_id'];
                 debugPrint('[CONFIG_TRACE] Modelo aplicado com sucesso do servidor: $modelName');
              }
           }
        }
      } catch (e) {
         debugPrint('[CONFIG_TRACE] Erro ao acessar servidor. Usando fallback Flash: $e');
      }
      // --- FIM DA COLETA ---

      debugPrint('[AI_TRACE] Executando análise com o modelo: $modelName');

      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        ],
        generationConfig: GenerationConfig(
            temperature: 0.1, 
            maxOutputTokens: 2000,
        ),
      );

      final prompt = _buildVideoPrompt(petName, notes, lang ?? 'pt_BR'); 
      final videoBytes = await videoFile.readAsBytes();
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(PetConstants.mimeMp4, videoBytes),
        ])
      ];

      final response = await model.generateContent(content);
      return response.text ?? PetConstants.errNoAnalysisReturned;

    } catch (e) {
      debugPrint('[VIDEO_TRACE] Erro na análise: $e');
      return "${PetConstants.errVideoAnalysis}$e"; 
    }
  }
}