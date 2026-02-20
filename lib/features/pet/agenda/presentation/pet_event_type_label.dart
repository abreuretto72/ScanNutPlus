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
      case PetEventType.aiChat:
        return l10n.pet_event_type_ai_chat;
      case PetEventType.appointment:
        return l10n.pet_event_type_appointment;
      case PetEventType.partner:
        return l10n.pet_event_type_partner;
      case PetEventType.behavior:
        return l10n.pet_event_type_behavior;
      case PetEventType.plant:
        return l10n.pet_event_plant;
      case PetEventType.friend:
        // Extract "amigo" from keyword list and capitalize
        final word = l10n.keywordFriend.split(',').first.trim();
        if (word.isEmpty) return "Friend";
        return "${word[0].toUpperCase()}${word.substring(1)}";
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
      case PetEventType.friend:
        return Icons.pets;
      case PetEventType.aiChat:
        return Icons.chat;
      case PetEventType.appointment:
        return Icons.event;
      case PetEventType.partner:
        return Icons.handshake;
      case PetEventType.behavior:
        return Icons.psychology;
      case PetEventType.plant:
        return Icons.local_florist;
    }
  }
}
