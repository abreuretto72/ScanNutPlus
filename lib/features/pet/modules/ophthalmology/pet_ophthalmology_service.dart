import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/material.dart' show Locale; // For Locale
import 'package:scannutplus/l10n/app_localizations.dart'; // For l10n

import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/modules/ophthalmology/pet_ophthalmology_prompts.dart';

class PetOphthalmologyService extends PetBaseAiService {
  Future<(String, Duration, String)> analyzeOphthalmology(
    String imagePath, String languageCode, {required String petName, required String petUuid}) async {
    final stopwatch = Stopwatch()..start();
    
    // Timeline trace
    dev.Timeline.startSync(PetConstants.traceEyesAnalysis, arguments: {
      AppKeys.logImage: imagePath, 
      AppKeys.logLang: languageCode,
    });

    try {
      if (!File(imagePath).existsSync()) throw Exception('${AppKeys.errorImageNotFound}$imagePath');
      
      final l10n = lookupAppLocalizations(Locale(languageCode));
      final systemPrompt = PetOphthalmologyPrompts.buildSystemPrompt(
        languageCode, 
        petName,
        l10n.ai_feedback_eyes_not_visible
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
