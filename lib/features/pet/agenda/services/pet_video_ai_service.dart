import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/core/services/env_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PetVideoAiService extends PetBaseAiService {
  
  // Singleton pattern
  static final PetVideoAiService _instance = PetVideoAiService._internal();
  factory PetVideoAiService() => _instance;
  PetVideoAiService._internal();

  /// Dedicated prompts for Veterinary Physiotherapy & Ethology
  String _buildVideoPrompt(String name, String? notes, String lang) {
    return '''
    Role: Veterinary Physiotherapist and Ethologist (Behavioral Specialist).
    Analyze the movement and behavior of the pet: $name.
    User/Tutor notes: ${notes ?? PetConstants.defaultNoNotes}.
    
    Task: Provide a detailed technical report based on the video clip (max 5s).
    
    FORMAT GUIDELINES:
    1. URGENCY: [GREEN|YELLOW|RED]
    
    2. [VISUAL_SUMMARY]
       Provide a concise 3-line summary of the movement/behavior.
    [END_SUMMARY]
    
    3. [CARD_START]
       TITLE: Posture & Gait Analysis
       ICON: videocam
       CONTENT: Analyze gait pattern, joint angulation, lameness (claudication), and spinal curvature. Mention any signs of pain or stiffness.
    [CARD_END]
    
    4. [CARD_START]
       TITLE: Behavioral Etogram
       ICON: psychology
       CONTENT: Identify behaviors (e.g., circling, head pressing, tremors, interaction with objects). Assess energy level (lethargy vs agitation).
    [CARD_END]

    5. [SOURCES]
       Canine Rehabilitation and Physical Therapy (Edge-Hughes)
       BSAVA Manual of Canine and Feline Rehabilitation
       Journal of Veterinary Behavior
    [END_SOURCES]
    
    Requirement: Use veterinary medical terminology. Do NOT use Markdown code blocks.
    Output Language: $lang.
    ''';
  }

  /// Override to support efficient video processing (Short Clip Strategy)
  Future<String> analyzeVideo({
    required File videoFile,
    required String petName,
    String? notes,
    String? lang,
  }) async {
    try {
      final apiKey = EnvService.geminiApiKey;
      if (apiKey.isEmpty) throw Exception(PetConstants.errApiKeyMissing);

      // Dynamic Model Config (Reuse logic from Base/Vocal)
      String modelName = 'gemini-1.5-pro'; // Default for Video
      // Note: In a real implementation, we would fetch this from remote config like in VocalService
      
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
            temperature: 0.2, // Low temp for technical accuracy
            maxOutputTokens: 2000,
        ),
      );

      // Use localized language for prompt output
      // We need a way to pass this if the service is singleton and context-unaware.
      // For now, we'll rely on the caller or a default. 
      // Ideally, the 'lang' should be passed in analyzeVideo, but the signature doesn't have it.
      // Refactoring signature to include lang is safer, but for now let's default to PT if not provided.
      // Wait, analyzeVideo is called from UI, so we can pass it.
      // Updating analyzeVideo signature below.
      
      final prompt = _buildVideoPrompt(petName, notes, lang ?? 'pt_BR'); 
      
      final videoBytes = await videoFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(PetConstants.mimeMp4, videoBytes), // Assuming ImagePicker produces mp4/mov
        ])
      ];

      final response = await model.generateContent(content);
      final result = response.text ?? PetConstants.errNoAnalysisReturned;
      
      return result;

    } catch (e) {
      debugPrint('[VIDEO_TRACE] Falha crítica na análise de vídeo: $e');
      return "${PetConstants.errVideoAnalysis}$e"; 
    }
  }
}
