import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:uuid/uuid.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:flutter/foundation.dart';

class PetMedicationService {
  final PetEventRepository repository;

  PetMedicationService(this.repository);

  /// Schedules multiple `PetEvent` instances for a medication treatment.
  /// Generates events in the database for each dose.
  Future<void> scheduleTreatment({
    required String petId,
    required String drugName,
    required String dosage,
    required String unit,
    required String route,
    required String observation,
    required int durationDays,
    required int intervalHours,
    required DateTime startDate,
  }) async {
    final int totalDoses = (durationDays * 24) ~/ intervalHours;
    debugPrint("[SCAN_NUT_TRACE] [MEDICATION_SERVICE] Scheduling $totalDoses doses for $drugName");
    
    // Add the very first dose as startDateTime
    for (int i = 0; i < totalDoses; i++) {
        final doseTime = startDate.add(Duration(hours: i * intervalHours));
        
        final metricsData = {
          'is_medication': true,
          'custom_title': drugName,
          'dosage': dosage,
          'unit': unit,
          'route': route,
          'status': 'pending', // Marks as not taken yet
        };

        final notes = observation.isNotEmpty ? observation : null;

        final event = PetEvent(
          id: const Uuid().v4(),
          startDateTime: doseTime,
          endDateTime: doseTime,
          petIds: [petId],
          eventTypeIndex: PetEventType.health.index, 
          hasAIAnalysis: false,
          notes: notes,
          metrics: metricsData,
        );

        await repository.saveEvent(event);
    }
    debugPrint("[SCAN_NUT_TRACE] [MEDICATION_SERVICE] Finished scheduling $totalDoses doses.");
  }
}
