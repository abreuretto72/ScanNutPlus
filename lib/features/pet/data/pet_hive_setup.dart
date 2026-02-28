import 'package:hive_flutter/hive_flutter.dart';
import 'models/pet_history_entry.dart';
import 'models/pet_profile.dart';
import 'pet_constants.dart';

void registerPetHiveAdapters() {
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(PetProfileAdapter());
  }
}

Future<void> openPetBoxes() async {
  if (!Hive.isBoxOpen(PetConstants.boxPetProfiles)) {
    await Hive.openBox<PetProfile>(PetConstants.boxPetProfiles);
  }
  // History box is usually opened on demand or here.
  // We'll leave history box management as is, assuming it handles itself or we add it later.
}
