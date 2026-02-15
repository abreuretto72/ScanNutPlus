import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale; // For Locale
import 'package:scannutplus/l10n/app_localizations.dart'; // For l10n

import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/modules/lab/pet_lab_prompts.dart';

class PetLabService extends PetBaseAiService {
  Future<(String, Duration, String)> analyzeLab(
    String imagePath, String languageCode, {required String petName, required String petUuid}) async {
    final stopwatch = Stopwatch()..start();
    
    // Timeline trace
    dev.Timeline.startSync(PetConstants.traceLabAnalysis, arguments: {
      AppKeys.logImage: imagePath, 
      AppKeys.logLang: languageCode,
    });
    
    try {
      if (!File(imagePath).existsSync()) throw Exception('${AppKeys.errorImageNotFound}$imagePath');
      
      final l10n = lookupAppLocalizations(Locale(languageCode));
      debugPrint('[LANG_TRACE] Idioma detetado no telemóvel: $languageCode | Enviando para a IA: $languageCode');

      final systemPrompt = PetLabPrompts.buildSystemPrompt(
        languageCode, 
        petName,
        l10n.ai_feedback_invalid_lab
      );
      
      final result = await analyzePetImageBase(
        imagePath: imagePath,
        languageCode: languageCode,
        petName: petName,
        petUuid: petUuid, 
        analysisType: PetConstants.typeLab,
        overrideSystemPrompt: systemPrompt,
      );
      stopwatch.stop();
      return (result, stopwatch.elapsed, petName);
    } catch (e) {
      rethrow;
    }
  }
}
