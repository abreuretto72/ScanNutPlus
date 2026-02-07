import 'dart:io';
import 'dart:async';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/core/constants/ai_prompts.dart';
import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/core/services/env_service.dart'; // Added for EnvService
import 'package:scannutplus/features/pet/data/pet_rag_service.dart'; // Added
import 'package:scannutplus/features/pet/data/pet_repository.dart'; // Added

class PetIdentityException implements Exception {
  final String message;
  PetIdentityException(this.message);
}

enum PetImageType {
  general,
  wound,
  stool,
  mouth,
  eyes,
  skin,
  label,
  lab, // Added
}

class PetAiService extends PetBaseAiService {
  
  /// Wrapper with Telemetry and Logging
  Future<(String, Duration, String)> analyzePetImage(
    String imagePath, 
    String languageCode, 
    {
      PetImageType type = PetImageType.general,
      String petName = PetConstants.defaultPetName,
      String petUuid = PetConstants.defaultPetUuid, // Should be provided by caller
    }
  ) async {
    final stopwatch = Stopwatch()..start();
    String finalPath = imagePath;
    
    // Timeline trace
    dev.Timeline.startSync(AppKeys.petAiAnalysis, arguments: {
      AppKeys.logImage: imagePath, 
      AppKeys.logLang: languageCode,
      AppKeys.logTraceContext: type.toString()
    });
    
    if (kDebugMode) {
      debugPrint('[PET_STEP_4]: Entering analyzePetImage. Path: $imagePath. Type: ${type.name}');
    }

    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('${AppKeys.errorImageNotFound}$imagePath');
      }

      int sizeInBytes = await file.length();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      if (kDebugMode) {
        // Pre-flight Log
        final keyLen = EnvService.geminiApiKey.length; // Use EnvService
        debugPrint('[PET_STEP_5]: API Key verified. Len: $keyLen');
        debugPrint('${AppKeys.logColorGreen}${AppKeys.logPrefixPet}: KeyLen: $keyLen | Size: ${sizeInMb.toStringAsFixed(2)}MB | Context: ${type.name}${AppKeys.logColorReset}');
      }

      // Compression for SM A256E if > 1MB
      if (sizeInMb > 1.0) {
        if (kDebugMode) debugPrint('${AppKeys.logColorYellow}${AppKeys.logPrefixPet}: Compressing image...${AppKeys.logColorReset}');
        
        final compressedPath = '${imagePath}_compressed.jpg';
        try {
           final result = await FlutterImageCompress.compressAndGetFile(
             imagePath, 
             compressedPath,
             quality: 75, // More aggressive compression
             minWidth: 800,
             minHeight: 800,
           );
           
           if (result != null) {
              finalPath = result.path;
              final newSize = await File(finalPath).length() / (1024 * 1024);
              if (kDebugMode) debugPrint('${AppKeys.logColorGreen}${AppKeys.logPrefixPet}: Compressed to ${newSize.toStringAsFixed(2)}MB${AppKeys.logColorReset}');
           }
        } catch (e) {
           // Fallback to original
           if (kDebugMode) debugPrint('${AppKeys.logColorRed}${AppKeys.logPrefixPetError}: Compression failed ($e). Using original.${AppKeys.logColorReset}');
        }
      }

      if (kDebugMode) debugPrint('[PET_STEP_6]: Reading bytes via compute...');
      
      // Use compute to avoid UI freeze
      final imageBytes = await compute(_readBytesSync, finalPath);

      // --- RAG IDENTITY CHECK (PILAR 0) ---
      // Only check identity if we don't have a specific name provided (i.e. 'Unknown Pet')
      // and it is a general pet analysis (not a label or loose image).
      // Actually, check always if "Unknown".
      if (petName == PetConstants.defaultPetName && type == PetImageType.general) {
         if (kDebugMode) debugPrint('${PetConstants.logTagPetRag}: Verifying biometric identity...');
         
         // Instantiate on the fly or inject. For MVP/Pilar0, instantiate safe.
         final ragService = PetRagService(PetRepository());
         final identity = await ragService.findPetMatch(imageBytes);

         if (identity != null) {
            // Match Found!
            petName = identity[PetConstants.fieldName] ?? petName;
            petUuid = identity[PetConstants.fieldUuid] ?? petUuid;
            if (kDebugMode) debugPrint('${PetConstants.logTagPetRag}: Visual match found: $petName (UUID: $petUuid)');
         } else {
            // No Match -> Trigger Voice/Form Flow
            // We interrupt the Artificial Intelligence Analysis to ask the HUMAN Intelligence.
            if (kDebugMode) debugPrint('${PetConstants.logTagPetRag}: No match. Requesting user input.');
            throw PetIdentityException(PetConstants.errorNewPet); // Handled by UI to show Voice/Form
         }
      }
      // ------------------------------------

      final contextInstruction = _getContextInstruction(type);
      final String analysisType = _mapTypeToAnalysis(type);
      
      if (kDebugMode) {
         debugPrint('[SCAN_NUT_LOG] Iniciando chamada LLM/RAG...');
         debugPrint('[SCAN_NUT_LOG] Nome do Pet: $petName | UUID: $petUuid');
         debugPrint('[SCAN_NUT_LOG] Contexto: ${type.name} | Lang: $languageCode');
      }

      // Call with explicit timeout 60s
      final result = await analyzePetImageBase(
        imagePath: finalPath,
        languageCode: languageCode,
        context: contextInstruction,
        imageBytes: imageBytes, // Pass bytes
        petName: petName,
        petUuid: petUuid, 
        analysisType: analysisType, 
      ).timeout(const Duration(seconds: 60), onTimeout: () {
         if (kDebugMode) debugPrint('[SCAN_NUT_ERROR] Timeout na resposta da IA.');
         throw TimeoutException(AppKeys.petErrorTimeout); 
      });

      stopwatch.stop();
      dev.Timeline.finishSync();

      if (kDebugMode) {
        final durationSec = (stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
        debugPrint('${AppKeys.logColorPurple}${AppKeys.logPrefixPetTrace}: Success in ${durationSec}s${AppKeys.logColorReset}');
        
        // Log truncated response for sanity check
        debugPrint('[SCAN_NUT_LOG] Resposta recebida da LLM: $result');
      }

      return (result, stopwatch.elapsed, petName);

    } catch (e, stackTrace) {
      stopwatch.stop();
      dev.Timeline.finishSync();
      
      if (kDebugMode) {
        debugPrint('${AppKeys.logColorRed}[SCAN_NUT_ERROR] Falha na análise: $e${AppKeys.logColorReset}');
        debugPrint('${AppKeys.logColorRed}[SCAN_NUT_ERROR] Stacktrace: $stackTrace${AppKeys.logColorReset}');
        
        if (e is SocketException) {
           debugPrint('[SCAN_NUT_ERROR] Falha na comunicação com o backend (sem internet?)');
        }
      }
      rethrow;
    }
  }

  String _mapTypeToAnalysis(PetImageType type) {
     switch(type) {
        case PetImageType.label: return PetConstants.typeNutrition;
        case PetImageType.lab: return PetConstants.typeLab;
        default: return PetConstants.typeClinical;
     }
  }

  String _getContextInstruction(PetImageType type) {
    switch (type) {
      case PetImageType.wound:
        return AiPrompts.contextWound;
      case PetImageType.stool:
        return AiPrompts.contextStool;
      case PetImageType.mouth:
        return AiPrompts.contextMouth;
      case PetImageType.eyes:
        return AiPrompts.contextEyes;
      case PetImageType.skin:
        return AiPrompts.contextSkin;
      case PetImageType.label:
        return AiPrompts.contextLabel;
      case PetImageType.lab:
        return PetConstants.contextLab; // Should be tokenized if needed, but for now string
      case PetImageType.general:
        return '';
    }
  }
}

final petAiService = PetAiService();

Uint8List _readBytesSync(String path) => File(path).readAsBytesSync();
