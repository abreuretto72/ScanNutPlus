import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'pet_constants.dart';

class PetRepository {
  
  PetRepository();

  // --- SEPARATION OF CONCERNS: PROFILE VS HISTORY (Refactoring 2026) ---
  
  /// 1. Saves or Updates the Fixed Pet Profile (The "Card")
  /// Does NOT save analysis results. Only Identity.
  Future<void> savePetProfile(PetEntity pet) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawProfiles = prefs.getStringList(PetConstants.boxPetProfiles) ?? [];
    
    // Check if profile exists and update, or add new.
    int index = -1;
    for (int i = 0; i < rawProfiles.length; i++) {
        final Map<String, dynamic> entry = json.decode(rawProfiles[i]);
        if (entry[PetConstants.fieldUuid] == pet.uuid) {
           index = i;
           break;
        }
    }

    final Map<String, dynamic> profileData = {
       PetConstants.fieldUuid: pet.uuid,
       PetConstants.fieldName: pet.name,
       PetConstants.fieldBreed: pet.breed ?? PetConstants.valueUnknown,
       PetConstants.fieldImagePath: pet.imagePath,
       PetConstants.fieldTimestamp: DateTime.now().toIso8601String(), // Last updated
    };

    // Immutability Check: Preserve CreatedAt if exists, else set new
    if (index != -1) {
       final existing = json.decode(rawProfiles[index]);
       profileData[PetConstants.fieldCreatedAt] = existing[PetConstants.fieldCreatedAt] ?? DateTime.now().toIso8601String();
    } else {
       profileData[PetConstants.fieldCreatedAt] = DateTime.now().toIso8601String();
    }

    if (index != -1) {
       // Update existing profile (Merge to preserve other fields if any?)
       // For now, overwrite identity fields.
       rawProfiles[index] = json.encode(profileData);
    } else {
       // Add new
       rawProfiles.add(json.encode(profileData));
    }
    
    await prefs.setStringList(PetConstants.boxPetProfiles, rawProfiles);
    if (kDebugMode) debugPrint('${PetConstants.logTagPetData}: Profile saved for ${pet.name} (${pet.uuid})');
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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // A. Manage Profile Identity (Creation or Update)
    bool profileExists = false;
    int profileIndex = -1;
    final List<String> rawProfiles = prefs.getStringList(PetConstants.boxPetProfiles) ?? [];
    
    for (int i = 0; i < rawProfiles.length; i++) {
       if (rawProfiles[i].contains(petUuid)) {
          profileExists = true; 
          profileIndex = i;
          break; 
       }
    }
    
    if (!profileExists) {
        // Create New Profile
        await savePetProfile(PetEntity(
          uuid: petUuid, 
          name: petName, 
          breed: breed, 
          imagePath: imagePath,
          species: PetConstants.speciesUnknown, // Default, update later
          type: PetConstants.typePet
        ));
    } else {
        // UPDATE EXISTING PROFILE
        // LEI DE FERRO (Iron Law): Only update Image/Breed if this is explicitly a "New Profile" or "Initial Assessment".
        // Clinical modules (Dentistry, etc.) MUST NOT touch the profile identity.
        
        bool isIdentityUpdate = analysisType == PetConstants.typeNewProfile || analysisType == PetConstants.typeNewProfileLegacy;
        
        if (isIdentityUpdate) { // BLINDAGEM ATIVA: Only enters here if creating/updating a NEW profile
             try {
                final Map<String, dynamic> output = json.decode(rawProfiles[profileIndex]);
                // Update identity fields
                if (breed != PetConstants.valueUnknown) output[PetConstants.fieldBreed] = breed;
                if (petName.isNotEmpty) output[PetConstants.fieldName] = petName; 
                output[PetConstants.fieldImagePath] = imagePath; // Only update image here!
                output[PetConstants.fieldTimestamp] = DateTime.now().toIso8601String();
                
                // Save back
                rawProfiles[profileIndex] = json.encode(output);
                await prefs.setStringList(PetConstants.boxPetProfiles, rawProfiles);
                
                if (kDebugMode) debugPrint('${PetConstants.logTagPetData}: Profile synced with IDENTITY data (Breed: $breed)');
             } catch (e) {
                if (kDebugMode) debugPrint('${PetConstants.logTagPetError}: Failed to sync profile: $e');
             }
        } else {
             if (kDebugMode) debugPrint('${PetConstants.logTagPetData}: Clinical Analysis - Profile Image PROTECTED. (Type: $analysisType)');
        }
    }

    // B. Save the Event to History Box (ONLY if NOT just a New Profile creation)
    // We NO LONGER skip 'newProfile'. It must be recorded.
    final historyEntry = {
      PetConstants.keyPetUuid: petUuid,
      PetConstants.keyPetAnalysisResult: analysisResult,
      PetConstants.fieldAnalysisType: analysisType, 
      PetConstants.fieldTimestamp: DateTime.now().toIso8601String(),
      PetConstants.fieldImagePath: imagePath, // History saves the clinical image
      PetConstants.fieldBreed: breed, 
    };

    final List<String> historyList = prefs.getStringList(PetConstants.boxPetHistory) ?? [];
    historyList.add(json.encode(historyEntry));
    await prefs.setStringList(PetConstants.boxPetHistory, historyList);
    
    if (kDebugMode) {
       debugPrint('${PetConstants.logTagPetData}: Analysis added to History for $petName ($analysisType)');
    }
    
    // C. Legacy Fallback (KEEPING boxPetAnalyses populated for now to not break older Views if any)
    // We can phase this out later. For now, we sync.
    // Actually, prompt says "Realize a separação". I should switch the Read methods.
    

  }

  /// 3. Get All Registered Profiles (Source of Truth: boxPetProfiles)
  Future<List<Map<String, dynamic>>> getAllRegisteredPets() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Migration Check: If boxPetProfiles is empty but boxPetAnalyses has data
    if (!prefs.containsKey(PetConstants.boxPetProfiles) && prefs.containsKey(PetConstants.boxPetAnalyses)) {
       await _migrateLegacyData(prefs);
    }
    
    final List<String> rawList = prefs.getStringList(PetConstants.boxPetProfiles) ?? [];
    return rawList.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }
  
  /// 4. Get History for a Specific Pet
  Future<List<Map<String, dynamic>>> getPetHistory(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawHistory = prefs.getStringList(PetConstants.boxPetHistory) ?? [];
    
    // Filter by UUID
    final history = rawHistory
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .where((e) => e[PetConstants.keyPetUuid] == uuid)
        .toList();

    // DEDUPLICATION LOGIC (Pilar 0: Unique Events)
    final Set<String> seenHashes = {};
    final List<Map<String, dynamic>> uniqueHistory = [];

    for (var item in history) {
       // Create a unique signature: Type + Timestamp(Minute) or just Content Hash?
       // Content might be identical if re-analyzed.
       // Let's use Type + Short Timestamp (to avoid exact millisecond diffs) + 50 chars of result
       final type = item[PetConstants.fieldAnalysisType] ?? '';
       final time = item[PetConstants.fieldTimestamp] ?? '';


       
       // Dedupe: Same Type approx same time? Or strict equality?
       // User says: "filtro por analysis_id único". We don't have ID.
       // Let's generate a hash based on content length + type.
       final signature = '${type}_${time.substring(0, time.length > 16 ? 16 : 0)}'; // Up to minute
       
       if (!seenHashes.contains(signature)) {
          seenHashes.add(signature);
          uniqueHistory.add(item);
       }
    }
    
    // Sort by Date Descending
    uniqueHistory.sort((a, b) {
       final dateA = DateTime.tryParse(a[PetConstants.fieldTimestamp] ?? '') ?? DateTime(1970);
       final dateB = DateTime.tryParse(b[PetConstants.fieldTimestamp] ?? '') ?? DateTime(1970);
       return dateB.compareTo(dateA); 
    });
    
    return uniqueHistory;
  }
  
  // --- MIGRATION HELPER ---
  Future<void> _migrateLegacyData(SharedPreferences prefs) async {
      if (kDebugMode) debugPrint('[PET_MIGRATION]: Migrating legacy data to Profiles...');
      final List<String> legacy = prefs.getStringList(PetConstants.boxPetAnalyses) ?? [];
      final Map<String, Map<String, dynamic>> uniqueProfiles = {};
      
      for (var item in legacy) {
         try {
            final entry = json.decode(item);
            final uuid = entry[PetConstants.keyPetUuid];
            if (uuid != null && !uniqueProfiles.containsKey(uuid)) {
               uniqueProfiles[uuid] = {
                  PetConstants.fieldUuid: uuid,
                  PetConstants.fieldName: entry[PetConstants.keyPetName],
                  PetConstants.fieldBreed: entry[PetConstants.fieldBreed],
                  PetConstants.fieldImagePath: entry[PetConstants.fieldImagePath],
                  PetConstants.fieldTimestamp: entry[PetConstants.keyPetTimestamp],
               };
            }
            // Also migrate to history? Yes.
            final historyEntry = {
               PetConstants.keyPetUuid: uuid,
               PetConstants.keyPetAnalysisResult: entry[PetConstants.keyPetAnalysisResult],
               PetConstants.fieldAnalysisType: entry[PetConstants.fieldAnalysisType] ?? PetConstants.typeClinical,
               PetConstants.fieldTimestamp: entry[PetConstants.keyPetTimestamp],
            };
            
            final List<String> historyLog = prefs.getStringList(PetConstants.boxPetHistory) ?? [];
            historyLog.add(json.encode(historyEntry));
            await prefs.setStringList(PetConstants.boxPetHistory, historyLog);
         } catch(e) {
            // skip
         }
      }
      
      // Save Unique Profiles
      final List<String> profilesJson = uniqueProfiles.values.map((e) => json.encode(e)).toList();
      await prefs.setStringList(PetConstants.boxPetProfiles, profilesJson);
  }

  // --- DELETE FULL PET DATA (Updated) ---
  Future<void> deleteFullPetData(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Delete Profile
    final List<String> profiles = prefs.getStringList(PetConstants.boxPetProfiles) ?? [];
    profiles.removeWhere((item) => item.contains(uuid)); // Simple Check
    await prefs.setStringList(PetConstants.boxPetProfiles, profiles);
    
    // 2. Delete History
    final List<String> history = prefs.getStringList(PetConstants.boxPetHistory) ?? [];
    history.removeWhere((item) => item.contains(uuid));
    await prefs.setStringList(PetConstants.boxPetHistory, history);
    
    // 3. Delete Legacy (Cleanup)
    final List<String> legacy = prefs.getStringList(PetConstants.boxPetAnalyses) ?? [];
    legacy.removeWhere((item) => item.contains(uuid));
    await prefs.setStringList(PetConstants.boxPetAnalyses, legacy);

    if (kDebugMode) {
      debugPrint('${PetConstants.logTagPetData}: Full delete performed for UUID: $uuid (Profile + History)');
    }
  }

  // --- UPDATE IDENTITY (Updated) ---
  Future<void> updatePetIdentity(String uuid, String newName, String newBreed) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> profiles = prefs.getStringList(PetConstants.boxPetProfiles) ?? [];
    
    bool updated = false;
    for (int i = 0; i < profiles.length; i++) {
       if (profiles[i].contains(uuid)) {
          final Map<String, dynamic> entry = json.decode(profiles[i]);
          entry[PetConstants.fieldName] = newName;
          if (newBreed.isNotEmpty) entry[PetConstants.fieldBreed] = newBreed;
          profiles[i] = json.encode(entry);
          updated = true;
          break;
       }
    }
    
    if (updated) {
       await prefs.setStringList(PetConstants.boxPetProfiles, profiles);
    }
  }
  
  // Legacy Stub for compatibility if needed elsewhere (should be removed/refactored)
  Future<List<Map<String, dynamic>>> getAnalyses(String uuid) async {
      return getPetHistory(uuid);
  }
}
