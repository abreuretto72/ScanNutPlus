import 'package:objectbox/objectbox.dart'; // Required for Store/Box/Query
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/objectbox.g.dart';
import 'pet_constants.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart'; // Correct UI Model
import 'package:scannutplus/pet/agenda/pet_event_repository.dart'; // Correct UI Repo
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:uuid/uuid.dart'; // ID Generation

class PetRepository {
  late Box<PetEntity> _petBox;
  late Box<PetHistoryEntry> _historyBox;
  
  PetRepository() {
      _petBox = ObjectBoxManager.currentStore.box<PetEntity>();
      _historyBox = ObjectBoxManager.currentStore.box<PetHistoryEntry>();
  }

  // --- SEPARATION OF CONCERNS: PROFILE VS HISTORY (Refactoring 2026) ---
  
  /// 1. Saves or Updates the Fixed Pet Profile (The "Card")
  /// Does NOT save analysis results. Only Identity.
  Future<void> savePetProfile(PetEntity pet) async {
    // [GUARD] Prevent saving pets with null or empty names
    if ((pet.name?.isEmpty ?? true) || pet.name == PetConstants.valNull) {
       if (kDebugMode) debugPrint(PetConstants.logBlockedEmpty);
       return;
    }

    // Check if exists by UUID using indexed query
    final existing = _petBox.query(PetEntity_.uuid.equals(pet.uuid)).build().findFirst();
    
    if (existing != null) {
        // Update existing ID to ensure replace instead of insert
        pet.id = existing.id;
        // Preserve creation date if needed, though Entity logic usually handles this via constructor or field
        pet.createdAt = existing.createdAt;
    }
    
    _petBox.put(pet);
    
    if (kDebugMode) debugPrint('${PetConstants.logTagPetData}: Profile saved for ${pet.name} (${pet.uuid}) to ObjectBox (ID: ${pet.id})');
    
    // Trigger migration for any legacy data just in case
    // await _migrateGenerico(); // Call cautiously
  }

  /// 2. Saves an Analysis Event to History
  /// Does NOT alter the Profile Identity (Name/Breed) unless it's the very first time (New Profile).
  Future<void> saveAnalysis({
    required String petUuid,
    required String petName,
    required String analysisResult,
    required List<String> sources,
    required String imagePath, 
    String breed = PetConstants.valueUnknown,
    String analysisType = PetConstants.typeClinical,
    String? tutorName, // Added for Friend Pet
  }) async {
    // [GUARD] Prevent saving analysis for nameless pets
    if (petName.isEmpty || petName == PetConstants.valNull) {
        if (kDebugMode) {
          debugPrint(PetConstants.logBlockedEmpty);
        }
        return;
    }
    
    // A. Manage Profile Identity (Creation or Update)
    PetEntity? pet = _petBox.query(PetEntity_.uuid.equals(petUuid)).build().findFirst();
    
    if (pet == null) {
        // Create New Profile
        pet = PetEntity(
          uuid: petUuid, 
          name: petName,
          tutorName: tutorName, // Save Tutor Name
          breed: breed, 
          imagePath: imagePath,
          species: PetConstants.speciesUnknown, // Default, update later
          type: analysisType == PetConstants.typeFriend ? PetConstants.typeFriend : PetConstants.typePet
        );
        if (kDebugMode) {
          debugPrint(PetConstants.logDbWriteNew);
          debugPrint('${PetConstants.logDbWriteData}UUID: ${pet.uuid}, Name: ${pet.name}, Type: $analysisType');
        }
        final exist = _petBox.query(PetEntity_.uuid.equals(pet.uuid)).build().findFirst();
        if (kDebugMode) {
          debugPrint('${PetConstants.logDbWriteExist}${exist != null ? "${PetConstants.valYes} (ID: ${exist.id})" : PetConstants.valNo}');
        }
        
        _petBox.put(pet);
    } else {
        // UPDATE EXISTING PROFILE
        // LEI DE FERRO (Iron Law): Only update Image/Breed if this is explicitly a "New Profile" or "Initial Assessment".
        bool isIdentityUpdate = analysisType == PetConstants.typeNewProfile || analysisType == PetConstants.typeNewProfileLegacy;
        
        if (isIdentityUpdate) { // BLINDAGEM ATIVA
             if (breed != PetConstants.valueUnknown) pet.breed = breed;
             if (petName.isNotEmpty) pet.name = petName; 
             pet.imagePath = imagePath; // Only update image here!
             // pet.createdAt = DateTime.now(); // Do NOT update creation time on edit
             
             if (kDebugMode) {
               debugPrint(PetConstants.logDbWriteUpdate);
               debugPrint('${PetConstants.logDbWriteData}UUID: ${pet.uuid}, Name: ${pet.name}, Type: $analysisType');
             }
             final exist = _petBox.query(PetEntity_.uuid.equals(pet.uuid)).build().findFirst();
             if (kDebugMode) {
               debugPrint('${PetConstants.logDbWriteExist}${exist != null ? "${PetConstants.valYes} (ID: ${exist.id})" : PetConstants.valNo}');
             }

             _petBox.put(pet);
             if (kDebugMode) debugPrint('${PetConstants.logTagPetData}: Profile synced with IDENTITY data (Breed: $breed)');
        } else {
             if (kDebugMode) debugPrint('${PetConstants.logTagPetData}: Clinical Analysis - Profile Image PROTECTED. (Type: $analysisType)');
        }
    }

    // B. Save the Event to History Box (ObjectBox Migration - 2026)
    final historyEntry = PetHistoryEntry(
      petUuid: petUuid,
      rawJson: analysisResult,
      timestamp: DateTime.now(),
      category: analysisType,
      petName: petName,
      imagePath: imagePath,
      // Add other fields mapping if necessary
    );
    
    _historyBox.put(historyEntry);
    
    if (kDebugMode) {
       debugPrint('${PetConstants.logTagPetData}: Analysis added to History (ObjectBox) for $petName ($analysisType)');
    }

    // C. Sync to Agenda (Protocol 2026 - Active Repository)
    await _syncToAgenda(historyEntry);
  }

  /// 3. Get All Registered Profiles (Source of Truth: ObjectBox)
  Future<List<Map<String, dynamic>>> getAllRegisteredPets() async {
    // Migration Check: If ObjectBox is empty but SharedPreferences has data
    if (_petBox.isEmpty()) {
       final prefs = await SharedPreferences.getInstance();
       if (prefs.containsKey(PetConstants.boxPetProfiles)) {
          await _migrateLegacyData(prefs);
       }
    }

    // CHECK HISTORY MIGRATION
    if (_historyBox.isEmpty()) {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey(PetConstants.boxPetHistory)) {
            await _migrateLegacyHistory(prefs);
        }
    }
    
    // [SANITIZATION] Auto-clean "Ghost" records with null/empty names
    // This runs on every fetch to ensure the list stays clean
    final ghostPets = _petBox.query(PetEntity_.name.isNull().or(PetEntity_.name.equals(''))).build().find();
    if (ghostPets.isNotEmpty) {
       if (kDebugMode) {
         debugPrint(PetConstants.logSanitization.replaceFirst('{}', ghostPets.length.toString()));
       }
       _petBox.removeMany(ghostPets.map((e) => e.id).toList());
    }
    

    
    // [FILTER] Exclude Friend Pets from Main List (Module 2026)
    // We want only "My Pets" (Type: 'pet' or null/legacy)
    final pets = _petBox.query(
      PetEntity_.type.notEquals(PetConstants.typeFriend) // Exclude friends
    ).build().find();
    // Convert to Map for compatibility with existing UI layer expecting JSON maps
    return pets.map((p) => {
        PetConstants.fieldUuid: p.uuid,
        PetConstants.fieldName: p.name,
        PetConstants.fieldBreed: p.breed,
        PetConstants.fieldImagePath: p.imagePath,
        PetConstants.fieldTimestamp: p.createdAt.toIso8601String(), 
        // Add other fields as needed
  }).toList();
  }
  
  /// 4. Get History for a Specific Pet
  Future<List<Map<String, dynamic>>> getPetHistory(String uuid) async {
    // If UUID is Environment tag, we want all general history or specific env history
    // For now, let's assume UUID is specific pet UUID.
    
    if (kDebugMode) {
      debugPrint('${PetConstants.logHistorySearch}$uuid');
    }
    
    final query = _historyBox.query(
        PetHistoryEntry_.petUuid.equals(uuid)
    ).order(PetHistoryEntry_.timestamp, flags: Order.descending).build();
    
    final entries = query.find();
    if (kDebugMode) {
      debugPrint('${PetConstants.logHistoryFound}${entries.length}');
    }
    query.close();

    // Map to legacy format for compatibility if needed, or update consumers
    return entries.map((e) => {
        PetConstants.keyPetUuid: e.petUuid,
        PetConstants.keyPetAnalysisResult: e.rawJson,
        PetConstants.fieldAnalysisType: e.category,
        PetConstants.fieldTimestamp: e.timestamp.toIso8601String(),
        PetConstants.fieldImagePath: e.imagePath,
        PetConstants.fieldName: e.petName,
        // Add other fields
    }).toList();
  }

  /// 5. Get Friend Pets (Module 2026)
  List<PetEntity> getFriendPets() {
    return _petBox.query(PetEntity_.type.equals(PetConstants.typeFriend))
        .order(PetEntity_.name)
        .build()
        .find();
  }

  /// 5.1 Update Friend Pet (Module 2026)
  Future<void> updateFriend(PetEntity pet) async {
    // Re-verify existence to be safe
    final existing = _petBox.get(pet.id);
    if (existing != null) {
      // Identity Updates allow Name/Tutor changes for Friends
      existing.name = pet.name;
      existing.tutorName = pet.tutorName;
      _petBox.put(existing);
      
      if (kDebugMode) {
          debugPrint('${PetConstants.logTagPetData}: Friend updated: ${pet.name} (Tutor: ${pet.tutorName})');
      }
    }
  }

  /// 5.2 Delete Friend Pet (Module 2026)
  Future<void> deleteFriend(String uuid) async {
      // 1. Find Friend Entity
      final pet = _petBox.query(PetEntity_.uuid.equals(uuid) & PetEntity_.type.equals(PetConstants.typeFriend)).build().findFirst();
      
      if (pet != null) {
          // 2. Remove Entity from Box
          _petBox.remove(pet.id);
          
          // 3. Optional: Remove Associated History?
          // For now, let's keep history or maybe delete it too?
          // As per "deleteFullPetData", we usually remove everything.
          // Let's reuse deleteFullPetData logic but specific for friend context if needed, 
          // but calling remove(pet.id) is the core action.
          
          if (kDebugMode) {
             debugPrint('${PetConstants.logTagPetData}: Friend deleted: ${pet.name} (${pet.uuid})');
          }
      }
  }
  
  // --- MIGRATION HELPER ---
  Future<void> _migrateLegacyData(SharedPreferences prefs) async {
      if (kDebugMode) debugPrint('[PET_MIGRATION]: Migrating legacy data from SharedPreferences to ObjectBox...');
      
      final List<String> rawProfiles = prefs.getStringList(PetConstants.boxPetProfiles) ?? [];
      
      for (var item in rawProfiles) {
         try {
            final entry = json.decode(item);
            final uuid = entry[PetConstants.fieldUuid];
            if (uuid == null) continue;

            // Check if already in ObjectBox
            if (_petBox.query(PetEntity_.uuid.equals(uuid)).build().findFirst() != null) continue;

            final pet = PetEntity(
               uuid: uuid,
               name: entry[PetConstants.fieldName],
               breed: entry[PetConstants.fieldBreed],
               imagePath: entry[PetConstants.fieldImagePath] ?? '',
               species: PetConstants.speciesUnknown, // Default
               type: PetConstants.typePet,
               createdAt: DateTime.tryParse(entry[PetConstants.fieldTimestamp] ?? '') 
            );
            
            _petBox.put(pet);
            if (kDebugMode) debugPrint('[PET_MIGRATION]: Migrated pet $uuid to ObjectBox.');
         } catch(e) {
            if (kDebugMode) debugPrint('[PET_MIGRATION]: Failed to migrate item: $e');
         }
      }
      }


  Future<void> _migrateLegacyHistory(SharedPreferences prefs) async {
      if (kDebugMode) debugPrint('[PET_MIGRATION]: Migrating legacy HISTORY from SharedPreferences to ObjectBox...');
      
      final List<String> rawHistory = prefs.getStringList(PetConstants.boxPetHistory) ?? [];
      int migratedCount = 0;

      for (var item in rawHistory) {
         try {
            final entry = json.decode(item);
            final uuid = entry[PetConstants.keyPetUuid];
            final timestampStr = entry[PetConstants.fieldTimestamp];
            
            if (uuid == null) continue; // Skip bad data

            // Check duplicate by rawJson signature or timestamp+uuid? 
            // For now, simpler check: if we started empty, we add all. 
            // If re-running, check logic requires index.
            // Let's rely on _historyBox.isEmpty() check from caller.

            final historyEntry = PetHistoryEntry(
               petUuid: uuid,
               rawJson: entry[PetConstants.keyPetAnalysisResult] ?? '',
               timestamp: DateTime.tryParse(timestampStr ?? ''),
               category: entry[PetConstants.fieldAnalysisType] ?? PetConstants.valGeneral,
               petName: entry[PetConstants.fieldName] ?? '', // Might be missing in old history?
               imagePath: entry[PetConstants.fieldImagePath] ?? '',
            );
            
            _historyBox.put(historyEntry);
            migratedCount++;
         } catch(e) {
            if (kDebugMode) debugPrint('[PET_MIGRATION]: Failed to migrate history item: $e');
         }
      }
      if (kDebugMode) debugPrint('[PET_MIGRATION]: History Migration Complete. Processed $migratedCount items.');
  }

  // --- DELETE FULL PET DATA ---
  Future<void> deleteFullPetData(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Delete Profile from ObjectBox
    final pet = _petBox.query(PetEntity_.uuid.equals(uuid)).build().findFirst();
    if (pet != null) {
      _petBox.remove(pet.id);
    }
    
    // 2. Delete Profile from SharedPreferences (Legacy Cleanup)
    final List<String> profiles = prefs.getStringList(PetConstants.boxPetProfiles) ?? [];
    profiles.removeWhere((item) => item.contains(uuid));
    await prefs.setStringList(PetConstants.boxPetProfiles, profiles);
    
    // 3. Delete History
    final List<String> history = prefs.getStringList(PetConstants.boxPetHistory) ?? [];
    history.removeWhere((item) => item.contains(uuid));
    await prefs.setStringList(PetConstants.boxPetHistory, history);
    
    // 4. Delete Legacy (Cleanup)
    final List<String> legacy = prefs.getStringList(PetConstants.boxPetAnalyses) ?? [];
    legacy.removeWhere((item) => item.contains(uuid));
    await prefs.setStringList(PetConstants.boxPetAnalyses, legacy);

    if (kDebugMode) {
      debugPrint('${PetConstants.logTagPetData}: Full delete performed for UUID: $uuid (ObjectBox + Refs)');
    }
  }

  // --- UPDATE IDENTITY ---
  Future<void> updatePetIdentity(String uuid, String newName, String newBreed) async {
    final pet = _petBox.query(PetEntity_.uuid.equals(uuid)).build().findFirst();
    if (pet != null) {
       pet.name = newName;
       if (newBreed.isNotEmpty) pet.breed = newBreed;
       _petBox.put(pet);
    } else {
       // Fallback to legacy structure if not found (unlikely after migration)
       if (kDebugMode) debugPrint('[UPDATE_ERROR] Pet $uuid not found in ObjectBox for update.');
    }
  }
  
  

// ... (keep class definition header)

  // --- ARCHIVING (Protocol 2026) ---

  Future<void> saveHealthSummary(String petUuid, String summary) async {
    final pet = _petBox.query(PetEntity_.uuid.equals(petUuid)).build().findFirst();
    final petName = pet?.name ?? PetConstants.defaultPetName;

    final entry = PetHistoryEntry(
      petUuid: petUuid,
      rawJson: summary,
      timestamp: DateTime.now(),
      category: PetConstants.catHealthSummary,
      petName: petName,
      imagePath: '', // Text only
    );

    _historyBox.put(entry);
    
    if (kDebugMode) debugPrint('${PetConstants.logTagPetData}: Health Summary archived for $petName');

    await _syncToAgenda(entry);
  }

  Future<void> saveNutritionPlan(String petUuid, String plan) async {
    final pet = _petBox.query(PetEntity_.uuid.equals(petUuid)).build().findFirst();
    final petName = pet?.name ?? PetConstants.defaultPetName;

    final entry = PetHistoryEntry(
      petUuid: petUuid,
      rawJson: plan,
      timestamp: DateTime.now(),
      category: PetConstants.catNutritionPlan,
      petName: petName,
      imagePath: '', // Text only
    );

    _historyBox.put(entry);

    if (kDebugMode) debugPrint('${PetConstants.logTagPetData}: Nutrition Plan archived for $petName');

    await _syncToAgenda(entry);
  }

  // --- AGENDA SYNC HELPER ---
  Future<void> _syncToAgenda(PetHistoryEntry entry) async {
    try {
      final repo = PetEventRepository();
      
      // 1. Refined Title Logic (Protocol 2026)
      String rawCategory = entry.category.toLowerCase();
      String mappedTitle = _mapCategoryToTitle(rawCategory);
      
      // Capitalize
      if (mappedTitle.isNotEmpty) {
          mappedTitle = mappedTitle[0].toUpperCase() + mappedTitle.substring(1);
      }

      final eventTitle = mappedTitle; // "Oftalmologia", "Nutrição", "Resumo de Saúde", "Chat IA"

      // 2. Determine Event Type via Mapped Title or Category
      PetEventType eventType = PetEventType.health; // Default
      String source = 'analysis';

      // --- LOGIC MAP ---
      // CHAT IA
      if (['Chat IA', 'Chat', 'Conversa', 'AI Chat'].contains(eventTitle) || 
          rawCategory.contains('chat') || rawCategory.contains('message')) {
          eventType = PetEventType.aiChat;
          source = 'chat_log';
      }
      // NUTRITION
      else if (['Nutrição', 'Plano Nutricional', 'Análise de Rótulo', 'Alimentação'].contains(eventTitle) || 
          rawCategory.contains('food') || rawCategory.contains('nutrition') || rawCategory.contains('label')) {
          eventType = PetEventType.food;
          source = 'nutrition';
      } 
      // WALKS (PASSEIOS)
      else if (['Passeio', 'Caminhada', 'Exercício'].contains(eventTitle) ||
          rawCategory.contains('walk') || rawCategory.contains('exercise') || rawCategory.contains('activity')) {
          eventType = PetEventType.activity; // Mapped to "Passeios" in UI
          source = 'walk';
      }
      // BEHAVIOR (Comportamento, Vocalização, Body Condition)
      else if (['Comportamento', 'Vocalização', 'Condição Corporal'].contains(eventTitle) ||
          rawCategory.contains('behavior') || rawCategory.contains('vocal') || rawCategory.contains('body') || rawCategory.contains('posture')) {
          eventType = PetEventType.behavior;
          source = 'behavior_analysis';
      }
      // PLANT
      else if (['Módulo Plantas', 'Plantas', 'Planta', 'Plant'].contains(eventTitle) || 
          rawCategory.contains('plant') || rawCategory.contains('toxic') || rawCategory.contains('botanic')) {
          eventType = PetEventType.plant;
          source = 'plant_analysis';
      }
      // HYGIENE -> APPOINTMENT (Consolidated)
      else if (['Banho', 'Tosa', 'Higiene', 'Grooming', 'Bath'].contains(eventTitle) || 
          rawCategory.contains('hygiene') || rawCategory.contains('bath') || rawCategory.contains('grooming')) {
          eventType = PetEventType.appointment; // Consolidated into Appointments
          source = 'hygiene';
      }
      // FRIEND
      else if (rawCategory.contains('friend')) {
          eventType = PetEventType.other; // Friend logic usually handled by IS_FRIEND flag
          source = 'friend';
      } 
      // PROFILE
      else if (['Avaliação Inicial', 'Perfil'].contains(eventTitle)) {
          eventType = PetEventType.other; 
          source = 'profile';
      } 
      // HEALTH (Default for Eyes, Skin, Mouth, Lab, etc.)
      else {
          eventType = PetEventType.health;
          if (eventTitle == 'Resumo de Saúde') source = 'health_summary';
      }

      final event = PetEvent(
        id: const Uuid().v4(),
        startDateTime: entry.timestamp,
        petIds: [entry.petUuid],
        eventTypeIndex: eventType.index,
        // eventSubType: rawCategory, // Removed: Field does not exist in PetEvent
        hasAIAnalysis: true,
        notes: eventType == PetEventType.aiChat ? 'Conversa com IA' : 'Análise: $eventTitle', 
        metrics: {
          'custom_title': eventTitle, // FORCE DISPLAY TITLE
          PetConstants.keyAiSummary: entry.rawJson,
          PetConstants.keyCategory: entry.category,
          'source': source,
        },
        mediaPaths: entry.imagePath.isNotEmpty ? [entry.imagePath] : null,
      );

      final resultId = await repo.saveEvent(event);
      
      if (resultId != null) {
         if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [AGENDA_SYNC] Evento criado: ${event.id} | Title: $eventTitle');
      } else {
         if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [AGENDA_SYNC] Falha ao criar evento.');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [AGENDA_SYNC] Erro crítico: $e');
    }
  }

  String _mapCategoryToTitle(String category) {
    switch (category.toLowerCase()) {
      case 'eyes': return 'pet_title_ophthalmology'; 
      case 'mouth': 
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
      case 'lab': return 'pet_title_lab'; // l10n
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

  // Legacy Stub for compatibility
  Future<List<Map<String, dynamic>>> getAnalyses(String uuid) async {
      return getPetHistory(uuid);
  }
}
