import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/objectbox.g.dart'; // Will be generated

class PetService {
  final Box<PetEntity> _box;

  PetService() : _box = ObjectBoxManager.currentStore.box<PetEntity>();

  Future<int> savePet(PetEntity pet) async {
    return _box.put(pet);
  }

  List<PetEntity> getAllPets() {
    return _box.getAll();
  }
}

final petService = PetService();
