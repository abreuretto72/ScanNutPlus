import 'package:hive/hive.dart';

import 'package:scannutplus/features/pet/data/datasources/pet_history_source.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

class PetHistoryRepository {
  final PetHistorySource _dataSource = PetHistorySource();

  // Expose Box for ValueListenableBuilder (Legacy support until full refactor)
  Future<Box<PetHistoryEntry>> getBox() => _dataSource.getBox();

  /// Saves an entry via DataSource
  Future<void> saveEntry({
    required String type,
    required String tempImagePath,
    required List<Map<String, dynamic>> cards,
    String? petUuid,
    String petName = PetConstants.defaultPetName,
  }) async {
    return _dataSource.saveAnalysis(
      petUuid: petUuid ?? PetConstants.tagEnvironment,
      petName: petName,
      originalImagePath: tempImagePath,
      type: type,
      analysisCards: cards,
    );
  }

  /// Get history filtered by Pet UUID
  Future<List<PetHistoryEntry>> getHistoryByPet(String petUuid, {String? petName}) {
    return _dataSource.getHistoryByPet(petUuid, petName: petName);
  }

  /// Get distinct active profiles (consolidated by latest entry)
  Future<List<PetHistoryEntry>> getActiveProfiles() {
    return _dataSource.getActiveProfiles();
  }

  /// Get environmental history (Plants/Alerts)
  Future<List<PetHistoryEntry>> getEnvironmentalHistory() async {
    final box = await _dataSource.getBox();
    return box.values
        .where((e) => e.petUuid == PetConstants.tagEnvironment)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  /// Delete all history for a specific pet (by UUID or Name for legacy)
  Future<void> deletePetHistory(String identifier) async {
    return _dataSource.deletePetCompleteHistory(identifier);
  }
}
