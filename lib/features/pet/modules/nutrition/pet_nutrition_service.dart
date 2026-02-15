import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;


import 'package:flutter/foundation.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/modules/nutrition/pet_nutrition_prompts.dart';

class PetNutritionService extends PetBaseAiService {
  Future<(String, Duration, String)> analyzeNutrition(
    String imagePath, String languageCode, {required String petName, required String petUuid}) async {
    final stopwatch = Stopwatch()..start();
    
    // Timeline trace
    dev.Timeline.startSync(PetConstants.traceNutritionAnalysis, arguments: {
      AppKeys.logImage: imagePath, 
      AppKeys.logLang: languageCode,
    });

    try {
      if (!File(imagePath).existsSync()) throw Exception('${AppKeys.errorImageNotFound}$imagePath');
      debugPrint('[LANG_TRACE] Idioma detetado no telemóvel: $languageCode | Enviando para a IA: $languageCode');
      
      final systemPrompt = PetNutritionPrompts.buildSystemPrompt(languageCode, petName);
      
      final result = await analyzePetImageBase(
        imagePath: imagePath,
        languageCode: languageCode,
        petName: petName,
        petUuid: petUuid, 
        analysisType: PetConstants.typeNutrition,
        overrideSystemPrompt: systemPrompt,
      );
      stopwatch.stop();
      dev.Timeline.finishSync();
      return (result, stopwatch.elapsed, petName);
    } catch (e) {
      stopwatch.stop();
      dev.Timeline.finishSync();
      rethrow;
    }
  }
}
