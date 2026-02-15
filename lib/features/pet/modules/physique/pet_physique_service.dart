import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/modules/physique/pet_physique_prompts.dart';

class PetPhysiqueService extends PetBaseAiService {
  Future<(String, Duration, String)> analyzePhysique(
    String imagePath, String languageCode, {required String petName, required String petUuid}) async {
    final stopwatch = Stopwatch()..start();
    
    // Timeline trace
    dev.Timeline.startSync(PetConstants.tracePhysiqueAnalysis, arguments: {
      AppKeys.logImage: imagePath, 
      AppKeys.logLang: languageCode,
    });

    try {
      if (!File(imagePath).existsSync()) throw Exception('${AppKeys.errorImageNotFound}$imagePath');
      debugPrint('[LANG_TRACE] Idioma detetado no telemóvel: $languageCode | Enviando para a IA: $languageCode');
      
      
      final systemPrompt = PetPhysiquePrompts.buildSystemPrompt(
        languageCode, 
        petName,

      );
      
      final result = await analyzePetImageBase(
        imagePath: imagePath,
        languageCode: languageCode,
        petName: petName,
        petUuid: petUuid, 
        analysisType: PetConstants.typeClinical,
        overrideSystemPrompt: systemPrompt,
      );
      stopwatch.stop();
      return (result, stopwatch.elapsed, petName);
    } catch (e) {
      rethrow;
    }
  }
}
