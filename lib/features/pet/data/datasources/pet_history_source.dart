import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_model.dart';
import 'package:scannutplus/features/pet/data/repositories/pet_event_repository.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:uuid/uuid.dart';

class PetHistorySource {
  static const String _boxName = 'pet_history_box';
  
  // 1. Singleton/Lazy Box Pattern with Self-Healing
  Future<Box<PetHistoryEntry>> getBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox<PetHistoryEntry>(_boxName);
      }
      return Hive.box<PetHistoryEntry>(_boxName);
    } catch (e) {
      debugPrint('${PetConstants.logTagPetFatal} [CRITICAL] HIVE BOX CORRUPTED OR TYPE MISMATCH: $e');
      try {
        await Hive.deleteBoxFromDisk(_boxName);
      } catch (_) {}
      return await Hive.openBox<PetHistoryEntry>(_boxName);
    }
  }

  // 2. Persist with Image Handling
  Future<void> saveAnalysis({
    required String petUuid,
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
        id: DateTime.now().millisecondsSinceEpoch,
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

      // Step D: Sync to Agenda (Protocol 2026)
      await _syncToAgenda(entry);

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
        if ((uuid == PetConstants.tagEnvironment) && petName != null) {
            final entryUuid = entry.petUuid;
            // Check if entry is also generic
            bool isEntryGeneric = (entryUuid == PetConstants.tagEnvironment);
            
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
      final String key = (entry.petUuid == PetConstants.tagEnvironment) 
          ? entry.petName 
          : entry.petUuid;

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

  // --- AGENDA SYNC HELPER ---
  Future<void> _syncToAgenda(PetHistoryEntry entry) async {
    try {
      final repo = PetEventRepository();
      
      // 1. Determine Event Type
      PetEventType eventType = PetEventType.health; // Default to Health
      String? subType = 'ai_analysis'; // l10n
 // l10n
      if (entry.category.toLowerCase().contains('friend')) { // l10n
        eventType = PetEventType.other;  // l10n
        subType = 'friend_detection'; // l10n
      } else if (['foodbowl', 'food_bowl', 'label', 'nutrition'].contains(entry.category.toLowerCase())) { // l10n
        eventType = PetEventType.food; // Mapped to "Nutrição" // l10n
        subType = 'nutrition_analysis'; // l10n
      } // l10n
 // l10n
      // 2. Refined Title Logic (Protocol 2026) // l10n
      // Map technical keys (eyes, skin, etc.) to user-friendly titles // l10n
      String rawCategory = entry.category.toLowerCase(); // l10n
      String eventTitle = _mapCategoryToTitle(rawCategory); // l10n
       // l10n
      // If the map returned the same raw category, check if we can get a better title from cards // l10n
      if (eventTitle.toLowerCase() == rawCategory && entry.analysisCards.isNotEmpty) { // l10n
        final firstCard = entry.analysisCards.first; // l10n
        if (firstCard.containsKey('title')) { // l10n
           eventTitle = firstCard['title'].toString(); // l10n
        } // l10n
      } // l10n
 // l10n
      // Capitalize first letter if it's a generic fallback // l10n
      if (eventTitle.isNotEmpty) { // l10n
          eventTitle = eventTitle[0].toUpperCase() + eventTitle.substring(1); // l10n
      } // l10n
 // l10n
      final event = PetEvent( // l10n
        id: const Uuid().v4(), // l10n
        startDateTime: entry.timestamp, // l10n
        petIds: [entry.petUuid], // l10n
        eventType: eventType, // l10n
        eventSubType: subType, // Reverted to String based on model definition // l10n
        hasAIAnalysis: true, // l10n
        notes: '', // Empty to avoid redundancy in UI (Title already shows category) // l10n
        metrics: { // l10n
          'custom_title': eventTitle, // FORCE DISPLAY TITLE (Fix for User Feedback) // l10n
          'source': 'analysis', // Standardized Origin // l10n
        }, // l10n
        mediaPaths: entry.imagePath.isNotEmpty ? [entry.imagePath] : null, // l10n
      ); // l10n
 // l10n
      final resultId = await repo.saveEvent(event); // l10n
       // l10n
      if (resultId != null) { // l10n
         debugPrint('${PetConstants.logTagPetData} [AGENDA_SYNC] Evento criado com sucesso: ${event.id} | Title: $eventTitle'); // l10n
      } else { // l10n
         debugPrint('${PetConstants.logTagPetData} [AGENDA_SYNC] Falha ao criar evento.'); // l10n
      } // l10n
    } catch (e) { // l10n
      debugPrint('${PetConstants.logTagPetData} [AGENDA_SYNC] Erro crítico: $e'); // l10n
    } // l10n
  } // l10n
 // l10n
  String _mapCategoryToTitle(String category) { // l10n
    // Map English/Technical keys to Portuguese (Target Market) // l10n
    // Users requested "Respect Language", assuming PT based on "Outros" report. // l10n
    switch (category.toLowerCase()) { // l10n
      case 'eyes': return 'pet_title_ophthalmology';  // l10n
      case 'mouth':  // l10n
      case 'dental': return 'pet_title_dental';  // l10n
      case 'skin':  // l10n
      case 'dermatology':  // l10n
      case 'fur': return 'pet_title_dermatology'; // l10n
      case 'ears': return 'pet_title_ears'; // l10n
      case 'stool':  // l10n
      case 'feces':  // l10n
      case 'gastro': return 'pet_title_digestion'; // l10n
      case 'posture':  // l10n
      case 'body': return 'pet_title_body_condition'; // l10n
      case 'vocal': return 'pet_title_vocalization'; // l10n
      case 'behavior': return 'pet_title_behavior'; // l10n
      case 'walk': // l10n
      case 'exercise': // l10n
      case 'activity': return 'pet_title_walk'; // l10n
      case 'chat': // l10n
      case 'ai_chat': // l10n
      case 'message': return 'pet_title_ai_chat'; // l10n
      case 'foodbowl':  // l10n
      case 'food_bowl':  // l10n
      case 'nutrition': return 'pet_title_nutrition'; // l10n
      case 'lab':  // l10n
      case 'lab_result': return 'pet_title_lab'; // l10n
      case 'label': return 'pet_title_label_analysis'; // l10n
      case 'plant':  // l10n
      case 'plantcheck': return 'pet_title_plants'; // l10n
      case 'newprofile': return 'pet_title_initial_eval'; // l10n
      case 'general': // l10n
      case 'health_summary': return 'pet_title_health_summary';  // l10n
      case 'other': return 'pet_title_general_checkup';  // l10n
      case 'clinical_summary': return 'pet_title_clinical_summary'; // l10n
      default: return category; 
    }
  }
}
