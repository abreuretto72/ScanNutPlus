import 'package:objectbox/objectbox.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';

@Entity()
class PetMetrics {
  @Id()
  int id = 0;

  double? weight;
  String? size;
  bool? isNeutered;

  @Property(type: PropertyType.date)
  DateTime timestamp;

  // Relation by ID is still ObjectBox standard, but we add UUID for explicit linking if needed
  String petUuid;
  
  final pet = ToOne<PetEntity>();

  PetMetrics({
    this.id = 0,
    required this.petUuid,
    this.weight,
    this.size,
    this.isNeutered,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
