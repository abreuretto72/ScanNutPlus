import 'package:scannutplus/features/pet/data/models/pet_entity.dart';

abstract class PetRepository {
  Future<void> savePet(PetEntity pet);
  List<PetEntity> getAllPets();
  Future<String> analyzePetImage(String imagePath, String languageCode);
  Future<List<Map<String, dynamic>>> getAnalyses(String uuid);
}
