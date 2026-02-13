import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';

extension PetEventTypeLabel on PetEventType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PetEventType.food:
        return l10n.pet_event_food;
      case PetEventType.health:
        return l10n.pet_event_health;
      case PetEventType.weight:
        return l10n.pet_event_weight;
      case PetEventType.hygiene:
        return l10n.pet_event_hygiene;
      case PetEventType.activity:
        return l10n.pet_event_type_activity; 
      case PetEventType.other:
        return l10n.pet_event_type_other;
    }
  }

  IconData get icon {
    switch (this) {
      case PetEventType.food:
        return Icons.restaurant;
      case PetEventType.health:
        return Icons.local_hospital;
      case PetEventType.weight:
        return Icons.monitor_weight;
      case PetEventType.hygiene:
        return Icons.soap;
      case PetEventType.activity:
        return Icons.directions_walk;
      case PetEventType.other:
        return Icons.category;
    }
  }
}
