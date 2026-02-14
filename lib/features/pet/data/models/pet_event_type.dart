import 'package:hive/hive.dart';

part 'pet_event_type.g.dart';

/// Enum representing the core types of events in the Pet Agenda.
/// Used to categorize timeline entries.
@HiveType(typeId: 203)
enum PetEventType {
  @HiveField(0)
  food,

  @HiveField(1)
  health,

  @HiveField(2)
  weight,

  @HiveField(3)
  hygiene,

  @HiveField(4)
  activity,

  @HiveField(5)
  other,

  @HiveField(6)
  friend,
}
