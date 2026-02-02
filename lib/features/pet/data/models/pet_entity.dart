import 'package:objectbox/objectbox.dart';

@Entity()
class PetEntity {
  @Id()
  int id = 0;

  String? name;
  String species;
  String imagePath;
  String? type;
  
  @Property(type: PropertyType.date)
  DateTime createdAt;

  PetEntity({
    this.id = 0,
    this.name,
    required this.species,
    required this.imagePath,
    this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
