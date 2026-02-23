import 'package:hive/hive.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';

part 'pending_analysis.g.dart';

@HiveType(typeId: 204)
class PendingAnalysis extends HiveObject {
  @HiveField(0)
  final String eventId;

  @HiveField(1)
  final PetEventType eventType;

  @HiveField(2)
  final String? imagePath;

  @HiveField(3)
  final String? audioPath;

  @HiveField(4)
  final String? videoPath;

  @HiveField(5)
  final String notes;

  @HiveField(6)
  final Map<String, dynamic> metrics;

  @HiveField(7)
  final bool isFriendUrl; // Stored as boolean

  @HiveField(8)
  final String petUuid;

  @HiveField(9)
  final String petName;
  
  @HiveField(10)
  final DateTime timestamp;

  PendingAnalysis({
    required this.eventId,
    required this.eventType,
    this.imagePath,
    this.audioPath,
    this.videoPath,
    required this.notes,
    required this.metrics,
    required this.isFriendUrl,
    required this.petUuid,
    required this.petName,
    required this.timestamp,
  });
}
