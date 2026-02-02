import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pet_constants.dart';

class PetRepository {
  
  PetRepository();

  Future<void> saveAnalysis({
    required String petUuid,
    required String petName,
    required String analysisResult,
    required List<String> sources,
    String analysisType = PetConstants.typeClinical,
  }) async {
    // Run DB operations in isolate or just async to avoid UI freeze (SharedPreferences is async but decode/encode can be heavy)
    // For Pillar 0 compliance and SM A256E ergonomics, we trust the async nature of SharedPreferences for now.
    
    final prefs = await SharedPreferences.getInstance();
    
    final data = {
      PetConstants.keyPetUuid: petUuid,
      PetConstants.keyPetName: petName,
      PetConstants.keyPetAnalysisResult: analysisResult,
      PetConstants.keyPetSources: sources,
      PetConstants.fieldAnalysisType: analysisType,
      PetConstants.keyPetTimestamp: DateTime.now().toIso8601String(),
    };

    final String jsonStr = json.encode(data);
    
    final List<String> currentList = prefs.getStringList(PetConstants.boxPetAnalyses) ?? [];
    currentList.add(jsonStr);
    
    await prefs.setStringList(PetConstants.boxPetAnalyses, currentList);
    
    if (kDebugMode) {
      debugPrint('${PetConstants.logTagPetData}: Saving RAG data for $petName (UUID: $petUuid)');
    }
  }

  Future<List<Map<String, dynamic>>> getAnalyses(String petUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(PetConstants.boxPetAnalyses) ?? [];
    
    return currentList
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .where((item) => item[PetConstants.keyPetUuid] == petUuid)
        .toList();
  }
}
