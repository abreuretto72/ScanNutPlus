import 'package:hive/hive.dart';
import '../pet_constants.dart';

part 'pet_profile.g.dart';

@HiveType(typeId: 12)
class PetProfile extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String profileImagePath;

  @HiveField(3)
  final String breed;

  @HiveField(4)
  final String age;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final String species; // New Field

  PetProfile({
    required this.uuid,
    required this.name,
    required this.profileImagePath,
    this.breed = PetConstants.valueUnknown,
    this.age = PetConstants.valueUnknown,
    this.species = PetConstants.speciesDog, // Default
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
        
    // Required for Hive to work with generated adapters sometimes or empty constructor
    // But since we use fields, it's fine.
}
