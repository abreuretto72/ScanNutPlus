import 'dart:async';
import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale; // For Locale
import 'package:scannutplus/l10n/app_localizations.dart'; // For l10n

import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/modules/gastro/pet_gastro_prompts.dart';

class PetGastroService extends PetBaseAiService {
  Future<(String, Duration, String)> analyzeGastro(
    String imagePath, String languageCode, {required String petName, required String petUuid}) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (!File(imagePath).existsSync()) throw Exception('${AppKeys.errorImageNotFound}$imagePath');
      
      final l10n = lookupAppLocalizations(Locale(languageCode));
      debugPrint('[LANG_TRACE] Idioma detetado no telemóvel: $languageCode | Enviando para a IA: $languageCode');
      
      final systemPrompt = PetGastroPrompts.buildSystemPrompt(
        languageCode, 
        petName,
        l10n.ai_feedback_invalid_gastro
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
