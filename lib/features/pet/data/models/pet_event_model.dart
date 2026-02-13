import 'package:hive/hive.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';

part 'pet_event_model.g.dart';

/// Represents a single event in the Pet Agenda timeline.
/// 
/// Strict architecture rules:
/// - Persisted locally via Hive (typeId: 202).
/// - No external dependencies (User/Auth/Firebase).
/// - Metrics is a flexible Map for domain-specific data (e.g., weight value, food brand).
@HiveType(typeId: 202)
class PetEvent extends HiveObject {
  
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startDateTime;

  @HiveField(2)
  final DateTime? endDateTime;

  /// List of Pet UUIDs involved in this event.
  /// Supports multi-pet events (e.g., shared walk).
  @HiveField(3)
  final List<String> petIds;

  @HiveField(4)
  final PetEventType eventType;

  @HiveField(5)
  final String? eventSubType; // Optional: e.g., health type like vaccination

  @HiveField(6)
  final String? notes;

  /// flexible key-value store for event specific data.
  /// e.g. {'weight_kg': 12.5} or {'food_brand': 'Royal Canin'}
  @HiveField(7)
  final Map<String, dynamic>? metrics;

  /// Local paths to images/videos associated with the event.
  @HiveField(8)
  final List<String>? mediaPaths;

  /// Optional: ID of a partner/vet/clinic (future feature).
  @HiveField(9)
  final String? partnerId;

  @HiveField(10)
  final bool hasAIAnalysis;

  PetEvent({
    required this.id,
    required this.startDateTime,
    this.endDateTime,
    required this.petIds,
    required this.eventType,
    this.eventSubType,
    this.notes,
    this.metrics,
    this.mediaPaths,
    this.partnerId,
    this.hasAIAnalysis = false,
  });

  /// Helper to check if event involves a specific pet
  bool involvesPet(String petUuid) {
    return petIds.contains(petUuid);
  }
}
