import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/modules/dentistry/pet_dentistry_prompts.dart';

import 'package:flutter/material.dart' show Locale; // For Locale
import 'package:scannutplus/l10n/app_localizations.dart'; // For l10n

class PetDentistryService extends PetBaseAiService {
  
  Future<(String, Duration, String)> analyzeDentistry(
    String imagePath, 
    String languageCode, 
    {
      required String petName,
      required String petUuid,
    }
  ) async {
    final stopwatch = Stopwatch()..start();
    
    // Timeline trace
    dev.Timeline.startSync(PetConstants.traceMouthAnalysis, arguments: {
      AppKeys.logImage: imagePath, 
      AppKeys.logLang: languageCode,
    });
    
    if (kDebugMode) {
      debugPrint('[DENTISTRY_MODULE]: Starting analysis for $petName');
    }

    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('${AppKeys.errorImageNotFound}$imagePath');
      }

      // Localized Feedback
      final l10n = lookupAppLocalizations(Locale(languageCode));
      debugPrint('[LANG_TRACE] Idioma detetado no telemóvel: $languageCode | Enviando para a IA: $languageCode');
      
      // Construct specialized prompt
      final systemPrompt = PetDentistryPrompts.buildSystemPrompt(
        languageCode, 
        petName,
        l10n.ai_feedback_no_oral_layout
      );
      
      // Use Base Service with Override
      final result = await analyzePetImageBase(
        imagePath: imagePath,
        languageCode: languageCode,
        petName: petName,
        petUuid: petUuid, 
        analysisType: PetConstants.typeClinical, // Dentistry falls under clinical
        overrideSystemPrompt: systemPrompt, // Inject Micro-App Reality
      ).timeout(const Duration(seconds: 60), onTimeout: () {
         if (kDebugMode) debugPrint('[DENTISTRY_MODULE] Timeout.');
         throw TimeoutException(AppKeys.petErrorTimeout); 
      });

      stopwatch.stop();
      dev.Timeline.finishSync();

      if (kDebugMode) {
        final durationSec = (stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
        debugPrint('[DENTISTRY_MODULE]: Success in ${durationSec}s');
      }

      return (result, stopwatch.elapsed, petName);

    } catch (e) {
      stopwatch.stop();
      dev.Timeline.finishSync();
      rethrow;
    }
  }
}
