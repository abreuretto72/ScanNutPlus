import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:scannutplus/core/services/env_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

/// SERVIÇO EXCLUSIVO PARA ANÁLISE VOCAL (MODULO AGENDA)
/// Este arquivo resolve o erro de versão de API (v1beta) forçando v1 estável.
class PetVocalAiService {
  String _vocalModelName = 'gemini-2.5-pro';

  /// Método principal acionado pela Agenda
  Future<String> analyzeBarking({
    required File audioFile,
    required String languageCode,
    required String petName,
    String? tutorNotes,
  }) async {
    try {
      // 1. Sincroniza configuração remota do multiversodigital
      await _syncRemoteConfig();

      final apiKey = EnvService.geminiApiKey;
      if (apiKey.isEmpty) throw Exception(PetConstants.errApiKeyMissing);

      // 2. Inicializa o modelo FORÇANDO A VERSÃO ESTÁVEL (V1)
      // O SDK google_generative_ai sem parâmetros de base_url usa o endpoint estável.
      final model = GenerativeModel(
        model: _vocalModelName, // Valor vindo do JSON remoto
        apiKey: apiKey,
        generationConfig: GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 2000, // Increased for deeper analysis
        ),
      );

      if (kDebugMode) {
        debugPrint('[AGENDA_TRACE] Iniciando Análise Vocal: $petName');
        debugPrint('[AGENDA_TRACE] Arquivo: ${audioFile.path}');
        debugPrint('[AGENDA_TRACE] Modelo Ativo: $_vocalModelName');
      }

      // 3. Prepara o Payload (Prompt + Áudio)
      final audioBytes = await audioFile.readAsBytes();
      final prompt = _buildVocalPrompt(languageCode, petName, tutorNotes);
      
      // Determine mime type strictly for Gemini 1.5 Flash
      // Supports: wav, mp3, aiff, aac, ogg, flac.
      String mimeType = PetConstants.mimeMp3; 
      final lowerPath = audioFile.path.toLowerCase();
      
      if (lowerPath.endsWith('.m4a') || lowerPath.endsWith('.mp4')) {
          mimeType = PetConstants.mimeMp4; 
      } else if (lowerPath.endsWith('.wav')) {
          mimeType = PetConstants.mimeWav;
      } else if (lowerPath.endsWith('.aac')) {
          mimeType = PetConstants.mimeAac;
      } else if (lowerPath.endsWith('.ogg')) {
          mimeType = PetConstants.mimeOgg;
      }
      
      if (kDebugMode) debugPrint('[AGENDA_TRACE] Mime Type: $mimeType');

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, audioBytes),
        ])
      ];

      // 4. Executa a chamada
      final response = await model.generateContent(content);
      final result = response.text ?? PetConstants.errNoAnalysisReturned;

      if (kDebugMode) {
          debugPrint('[AGENDA_TRACE] Sucesso na análise vocal.');
          debugPrint('[AGENDA_TRACE] Resposta Completa: $result'); // Full log for validation
      }
      return result;

    } catch (e) {
      debugPrint('[AGENDA_TRACE] Falha crítica na análise vocal: $e');
      return "${PetConstants.errVocalAnalysis}$e"; // Será traduzido na UI se necessário ou exibido como feedback técnico
    }
  }

  /// Busca o modelo no JSON do multiversodigital
  Future<void> _syncRemoteConfig() async {
    try {
      final url = Uri.parse(PetConstants.remoteConfigUrl);
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final config = json.decode(response.body);
        _vocalModelName = config[PetConstants.fieldActiveModel] ?? _vocalModelName;
        
        // Sanitização: Se o JSON trouxer "models/", removemos para evitar erro de endpoint
        _vocalModelName = _vocalModelName.replaceAll('models/', '');
        
        if (kDebugMode) debugPrint('[AGENDA_TRACE] Config Remota Sincronizada: $_vocalModelName');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[AGENDA_TRACE] Usando modelo padrão devido a erro de rede.');
    }
  }

  String _buildVocalPrompt(String lang, String name, String? notes) {
    return '''
    Role: Veterinary Bioacoustics Specialist and Senior Animal Behaviorist.
    Analyze the audio of the pet: $name.
    User/Tutor notes: ${notes ?? PetConstants.defaultNoNotes}.
    
    Task: Provide a detailed technical report using the following STRICT format.
    
    FORMAT GUIDELINES:
    1. URGENCY: [GREEN|YELLOW|RED]
    
    2. [VISUAL_SUMMARY]
       Provide a concise 3-line summary of the acoustic findings.
    [END_SUMMARY]
    
    3. [CARD_START]
       TITLE: Acoustic Analysis
       ICON: waveform
       CONTENT: Detailed breakdown of Frequency, Pattern, and Modulation. Minimum 1 paragraph.
    [CARD_END]
    
    4. [CARD_START]
       TITLE: Differential Diagnosis
       ICON: stethoscope
       CONTENT: List potential medical or behavioral causes (e.g., Cardiac Cough vs Reverse Sneezing).
    [CARD_END]

    5. [SOURCES]
       Merck Veterinary Manual
       Journal of Veterinary Behavior
       WSAVA Guidelines
    [END_SOURCES]
    
    Requirement: Use veterinary medical terminology. Do NOT use Markdown code blocks.
    Output Language: $lang.
    ''';
  }
}
