import 'package:objectbox/objectbox.dart';
import 'package:scannutplus/features/pet/data/models/pet_metrics.dart';

@Entity()
class PetEntity {
  @Id()
  int id = 0;

  @Index()
  @Unique()
  String uuid;

  String? name;
  String? breed;
  String species;
  String imagePath;
  String? type;
  
  @Property(type: PropertyType.date)
  DateTime? birthDate;
  
  String? healthPlan;
  String? funeralPlan;

  final metrics = ToMany<PetMetrics>();

  @Property(type: PropertyType.date)
  DateTime createdAt;

  PetEntity({
    this.id = 0,
    required this.uuid,
    this.name,
    this.breed,
    required this.species,
    required this.imagePath,
    this.type,
    this.birthDate,
    this.healthPlan,
    this.funeralPlan,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
