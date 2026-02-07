import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

class PetHistorySource {
  static const String _boxName = 'pet_history_box';
  
  // 1. Singleton/Lazy Box Pattern
  // 1. Singleton/Lazy Box Pattern with Self-Healing
  Future<Box<PetHistoryEntry>> getBox() async {
    // Garante que a box SEMPRE retorne o tipo forte da entidade (Strong Typing Enforcement)
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox<PetHistoryEntry>(_boxName);
      }
      return Hive.box<PetHistoryEntry>(_boxName);
    } catch (e) {
      debugPrint('${PetConstants.logTagPetFatal} [CRITICAL] HIVE BOX CORRUPTED OR TYPE MISMATCH: $e');
      // ... existing error handling or simplified since user wants the "Fix"
      // User snippet was simple. I will keep the self-healing logical structure but enforce the typing.
      try {
        await Hive.deleteBoxFromDisk(_boxName);
      } catch (_) {}
      return await Hive.openBox<PetHistoryEntry>(_boxName);
    }
  }

  // 2. Persist with Image Handling
  Future<void> saveAnalysis({
    required String petUuid, // Can be null (handled by logic) but typed String for specific pets
    required String petName,
    required String originalImagePath,
    required String type, // CLINICAL, EXAM, etc.
    required List<Map<String, dynamic>> analysisCards,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('--- [TRACE] INÍCIO DA GRAVAÇÃO - UUID: $petUuid | Name: $petName ---');

    try {
      // Step A: Secure Image Storage
      final safeImagePath = await _moveImageToSafeStorage(originalImagePath, petUuid);
      
      // Logic to resolve ENVIRONMENT UUID collision
      final String finalUuid = (petUuid == PetConstants.tagEnvironment) 
          ? '${PetConstants.prefixPet}${DateTime.now().millisecondsSinceEpoch}' 
          : petUuid;

      // Step B: Create Entry
      final entry = PetHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petUuid: finalUuid, 
        petName: petName,
        timestamp: DateTime.now(),
        category: type,
        imagePath: safeImagePath,
        analysisCards: analysisCards,
        rawJson: '', // Required by model
      );

      // Step C: Save to Hive
      final box = await getBox();
      if (!box.isOpen) {
        debugPrint('[ERROR] Box $_boxName está FECHADA.');
        return;
      }

      // Verificação da Imagem
      final fileExists = await File(safeImagePath).exists();
      debugPrint('[LOG] Path da imagem segura: $safeImagePath | Existe: $fileExists');

      await box.put(entry.id, entry);
      
      stopwatch.stop();
      debugPrint('[SUCCESS] Gravado no Hive em ${stopwatch.elapsed.inMilliseconds}ms');
      debugPrint('[LOG] Total de itens na Box agora: ${box.length}');
      
      if (kDebugMode) {
        debugPrint('${PetConstants.logTagPetData} HISTORY SAVED: ${entry.id} for $petName ($petUuid)');
      }

    } catch (e, stackTrace) {
      debugPrint('[ERROR] Falha crítica na gravação: $e');
      debugPrint('[STACKTRACE] $stackTrace');
      throw Exception('${PetConstants.errorHistorySave}$e');
    }
  }

  // 3. Image Move Logic (Internal Storage)
  Future<String> _moveImageToSafeStorage(String sourcePath, String uuid) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final historyDir = Directory('${appDir.path}/pet_history_images');

      if (!historyDir.existsSync()) {
        historyDir.createSync(recursive: true);
      }

      final extension = path.extension(sourcePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = '${uuid}_$timestamp$extension';
      final targetPath = '${historyDir.path}/$newFileName';

      // Copy instead of move to avoid permission issues with cached temp files
      await File(sourcePath).copy(targetPath);
      
      return targetPath;
    } catch (e) {
      debugPrint('${PetConstants.logTagPetData} Warning: Could not move image. Using reference. $e');
      return sourcePath;
    }
  }

  // 4. Retrieval Methods
  ValueListenable<Box<PetHistoryEntry>> getHistoryListenable() {
    if (!Hive.isBoxOpen(_boxName)) {
      throw HiveError(PetConstants.errorBoxNotOpen);
    }
    return Hive.box<PetHistoryEntry>(_boxName).listenable();
  }

  Future<List<PetHistoryEntry>> getHistoryByPet(String uuid, {String? petName}) async {
    final box = await getBox();
    final allEntries = box.values.toList();

    debugPrint('--- [TRACE] LEITURA POR PET ($uuid) | Name: $petName ---');
    debugPrint('[LOG] Total bruto na Box: ${allEntries.length}');

    final filtered = allEntries.where((entry) {
        // If searching by generic UUID, must match Name too
        if ((uuid == PetConstants.tagEnvironment || uuid == PetConstants.tagEnvironment) && petName != null) {
            final entryUuid = entry.petUuid ?? PetConstants.tagEnvironment;
            // Check if entry is also generic
            bool isEntryGeneric = (entryUuid == PetConstants.tagEnvironment || entryUuid == PetConstants.tagEnvironment);
            
            if (isEntryGeneric) {
                return entry.petName == petName;
            }
        }
        return entry.petUuid == uuid;
    }).toList();
    
    debugPrint('[LOG] Itens após filtro ($uuid / $petName): ${filtered.length}');

    if (allEntries.isNotEmpty && filtered.isEmpty) {
        debugPrint('[WARNING] ${PetConstants.msgWarnNoData}');
        if (allEntries.length < 10) {
             debugPrint('${PetConstants.errorUuidMismatch}${allEntries.map((e) => '${e.petName}:${e.petUuid}').toList()}');
        }
    }

    return filtered
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
  }

  /// Returns the specific latest entry for each distinct pet found in history.
  /// Effectively a "Group By Uuid" to show active profiles.
  Future<List<PetHistoryEntry>> getActiveProfiles() async {
    final box = await getBox();
    final allEntries = box.values.toList();
    
    debugPrint('--- [TRACE] LEITURA DE PERFIS ATIVOS ---');
    debugPrint('[LOG] Total bruto na Box: ${allEntries.length}');

    
    // Group by UUID
    final Map<String, PetHistoryEntry> latestEntries = {};
    
    for (var entry in allEntries) {
      if (entry.petUuid == null) continue; 
      
      // If UUID is still generic (legacy data), use Name as differentiator
      final String key = (entry.petUuid == PetConstants.tagEnvironment || entry.petUuid == PetConstants.tagEnvironment) 
          ? entry.petName 
          : entry.petUuid!;

      if (!latestEntries.containsKey(key) || 
          entry.timestamp.isAfter(latestEntries[key]!.timestamp)) {
        latestEntries[key] = entry;
      }
    }
    
    return latestEntries.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deletePetCompleteHistory(String identifier) async {
    final box = await getBox();
    
    // 1. Identify keys belonging to the pet
    final keysToDelete = box.keys.where((key) {
      final entry = box.get(key);
      if (entry == null) return false;
      
      // Match by UUID or Name (for legacy records)
      return entry.petUuid == identifier || entry.petName == identifier;
    }).toList();

    debugPrint('${PetConstants.logTagPetData} Deleting ${keysToDelete.length} records for $identifier');

    // 2. Delete physical images
    for (var key in keysToDelete) {
      final entry = box.get(key);
      if (entry != null && entry.imagePath.isNotEmpty) {
        try {
          final file = File(entry.imagePath);
          if (await file.exists()) {
            await file.delete();
            debugPrint('[LOG] Deleted image: ${entry.imagePath}');
          }
        } catch (e) {
            debugPrint('[WARNING] Failed to delete image: $e');
        }
      }
    }

    // 3. Remove from Hive
    await box.deleteAll(keysToDelete);
    debugPrint('${PetConstants.logTagPetData} Complete deletion successful.');
  }
}
