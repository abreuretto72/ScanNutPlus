import 'package:hive_flutter/hive_flutter.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_model.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

/// Repository for managing Pet Agenda Events via Hive.
/// 
/// Architecture:
/// - Direct Hive Box access.
/// - No Exceptions thrown; returns success status or empty lists.
/// - Logs errors conservatively.
class PetEventRepository {
  static const String _boxName = 'pet_events_box';

  Future<Box<PetEvent>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<PetEvent>(_boxName);
    }
    return Hive.box<PetEvent>(_boxName);
  }

  /// Saves or updates a PetEvent.
  /// Returns ID on success, null on error.
  Future<String?> saveEvent(PetEvent event) async {
    try {
      final box = await _openBox();
      await box.put(event.id, event);
      return event.id;
    } catch (e) {
      debugPrint('[PetEventRepository] Error saving event: $e');
      return null;
    }
  }

  /// Retrieves events for a specific pet, ordered by date descending (newest first).
  Future<List<PetEvent>> getEventsForPet(String petUuid) async {
    try {
      final box = await _openBox();
      final allEvents = box.values.toList();
      
      final petEvents = allEvents.where((e) => e.involvesPet(petUuid)).toList();
      
      // Sort by startDateTime descending
      petEvents.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      
      return petEvents;
    } catch (e) {
      debugPrint('[PetEventRepository] Error fetching events for pet $petUuid: $e');
      return [];
    }
  }
  
  /// Retrieves all events for all pets (e.g. for a master calendar).
  Future<List<PetEvent>> getAllEvents() async {
    try {
      final box = await _openBox();
      final allEvents = box.values.toList();
       // Sort by startDateTime descending
      allEvents.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      return allEvents;
    } catch (e) {
       debugPrint('[PetEventRepository] Error fetching all events: $e');
       return [];
    }
  }

  /// Deletes an event by ID.
  /// Returns true if successful.
  Future<bool> deleteEvent(String eventId) async {
    try {
      final box = await _openBox();
      await box.delete(eventId);
      return true;
    } catch (e) {
      debugPrint('[PetEventRepository] Error deleting event $eventId: $e');
      return false;
    }
  }
}
