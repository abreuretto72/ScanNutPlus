import 'package:hive/hive.dart';

part 'pet_map_alert.g.dart';

@HiveType(typeId: 20) // Ensure this ID is unique in your project
class PetMapAlert extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final String category; // e.g., constants from PetConstants

  @HiveField(4)
  final String description;

  @HiveField(5)
  final DateTime timestamp;

  PetMapAlert({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.description,
    required this.timestamp,
  });
}
