
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/objectbox.g.dart';
import 'package:intl/intl.dart';

import 'package:scannutplus/features/pet/data/models/health_plan_entity.dart';
import 'package:scannutplus/features/pet/data/repositories/pet_event_repository.dart'; // Added
// Added

class PetAiRepository {
  late Box<PetEntity> _petBox;
  late Box<PetHistoryEntry> _historyBox;
  late Box<HealthPlanEntity> _healthPlanBox;
  final PetEventRepository _eventRepository = PetEventRepository(); // Added

  PetAiRepository() {
    _petBox = ObjectBoxManager.currentStore.box<PetEntity>();
    _historyBox = ObjectBoxManager.currentStore.box<PetHistoryEntry>();
    _healthPlanBox = ObjectBoxManager.currentStore.box<HealthPlanEntity>();
  }

  /// Retrieves the full context for a specific pet to be used in RAG (Retrieval-Augmented Generation).
  /// Includes:
  /// - Pet Profile (Identity, Breed, Age, Weight, Medical)
  /// - Health Plan (Insurance details)
  /// - Recent History (Analysis results)
  /// - Agenda Events (Walks, Vet, Meds) - DEEP KNOWLEDGE
  /// - Metrics History (Weight evolution)
  Future<String> getPetContext(String uuid) async {
    final buffer = StringBuffer();

    // 1. Fetch Profile
    final pet = _petBox.query(PetEntity_.uuid.equals(uuid)).build().findFirst();
    
    if (pet != null) {
      buffer.writeln(PetConstants.ragProfileHeader);
      buffer.writeln('${PetConstants.labelName}${pet.name}');
      buffer.writeln('${PetConstants.labelBreed}${pet.breed ?? "Unknown"}');
      buffer.writeln('${PetConstants.labelSpecies}${pet.species}');
      
      // Age & Weight
      if (pet.birthDate != null) {
         final ageDays = DateTime.now().difference(pet.birthDate!).inDays;
         final years = ageDays ~/ 365;
         final months = (ageDays % 365) ~/ 30;
         buffer.writeln('Age: $years years, $months months');
      }
      if (pet.estimatedWeight != null) {
         buffer.writeln('Current Weight: ${pet.estimatedWeight} kg');
      }
      
      // Medical Notes
      if (pet.allergies != null && pet.allergies!.isNotEmpty) buffer.writeln('Allergies: ${pet.allergies}');
      if (pet.chronicConditions != null && pet.chronicConditions!.isNotEmpty) buffer.writeln('Chronic Conditions: ${pet.chronicConditions}');
      if (pet.disabilities != null && pet.disabilities!.isNotEmpty) buffer.writeln('Disabilities: ${pet.disabilities}');
      
      // --- METRICS HISTORY (Weight Evolution) ---
      if (pet.metrics.isNotEmpty) {
         buffer.writeln('\n[METRICS HISTORY]');
         // Sort descending by date
         final sortedMetrics = pet.metrics.toList()
           ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
         
         for (var m in sortedMetrics.take(5)) { // Last 5 measurements
            if (m.weight != null) buffer.writeln('- ${DateFormat('dd/MM/yyyy').format(m.timestamp)}: ${m.weight} kg');
         }
      }

      buffer.writeln(PetConstants.ragSeparator);
    } else {
      buffer.writeln(PetConstants.ragUnknownProfile.replaceFirst('{}', uuid));
    }

    // 2. Fetch Health Insurance
    final healthPlan = _healthPlanBox.query(HealthPlanEntity_.petUuid.equals(uuid)).build().findFirst();
    if (healthPlan != null) {
       buffer.writeln('--- HEALTH INSURANCE ---');
       buffer.writeln('Operator: ${healthPlan.operatorName ?? "N/A"}');
       buffer.writeln('Plan: ${healthPlan.planName ?? "N/A"}');
       buffer.writeln('Card Number: ${healthPlan.cardNumber ?? "N/A"}');
       buffer.writeln('24h Service: ${healthPlan.is24hService ? "YES" : "NO"}');
       buffer.writeln('Coverages: ${healthPlan.coveragesJson ?? "Not specified"}');
       buffer.writeln('------------------------');
    }

    // 3. Fetch Agenda Events (Walks, Vet, Meds) - DEEP KNOWLEDGE
    final events = await _eventRepository.getEventsForPet(uuid);
    if (events.isNotEmpty) {
       buffer.writeln('\n--- AGENDA / DAILY LIFE (Last 10 Events) ---');
       final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
       
       for (var event in events.take(10)) {
          buffer.write('- [${dateFormat.format(event.startDateTime)}] ${event.eventType.name.toUpperCase()}');
          if (event.notes != null && event.notes!.isNotEmpty) buffer.write(': ${event.notes}');
          if (event.metrics != null && event.metrics!.isNotEmpty) buffer.write(' | Data: ${event.metrics}');
          buffer.writeln('');
       }
       buffer.writeln('--------------------------------------------');
    }

    // 4. Fetch Analysis History (Increased limit to 10 for "Deep Knowledge")
    final query = _historyBox
        .query(PetHistoryEntry_.petUuid.equals(uuid))
        .order(PetHistoryEntry_.timestamp, flags: Order.descending)
        .build();
    
    // Get top 10 most recent (was 5)
    final history = query.find().take(10).toList();
    query.close();

    if (history.isNotEmpty) {
      buffer.writeln(PetConstants.ragHistoryHeader.replaceFirst('{}', history.length.toString()));
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      
      for (var entry in history) {
        buffer.writeln('${PetConstants.labelDate}${dateFormat.format(entry.timestamp)}');
        buffer.writeln('${PetConstants.labelCategory}${entry.category}');
        // Provide summary if rawJson is too verbose, or cleaned content
        buffer.writeln('${PetConstants.labelSummary}${_truncate(entry.rawJson, 500)}'); 
        buffer.writeln('---');
      }
      buffer.writeln(PetConstants.ragEndBlock);
    } else {
      buffer.writeln(PetConstants.ragNoHistory);
    }

    return buffer.toString();
  }
  
  String _truncate(String? text, int length) {
    if (text == null) return '';
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}
