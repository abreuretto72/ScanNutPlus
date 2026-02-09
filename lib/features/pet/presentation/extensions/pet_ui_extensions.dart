import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

extension PetImageTypeExt on PetImageType {
  /// Mapeia o Enum técnico para a string traduzida no arquivo .arb
  String toDisplayString(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PetImageType.profile: return l10n.pet_type_general; // Contextually similar to general or needs specific 'Profile' key if meant for UI tab
      case PetImageType.skin: return l10n.pet_type_skin;
      case PetImageType.eyes: return l10n.pet_type_eyes;
      case PetImageType.mouth: return l10n.pet_type_mouth;
      case PetImageType.posture: return l10n.pet_section_posture;
      case PetImageType.lab: return l10n.pet_type_lab; 
      case PetImageType.stool: return l10n.category_feces;
      case PetImageType.safety: return l10n.pet_type_safety;
      case PetImageType.label: return l10n.category_food_label;
      case PetImageType.general: return l10n.pet_type_general;
      case PetImageType.wound: return l10n.category_wound;
      case PetImageType.newProfile: return l10n.pet_type_new_profile;
    }
  }
}

extension PetSpeciesExt on String {
  /// Mapeia a string de espécie vinda do banco/IA para tradução
  String toSpeciesDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (toLowerCase() == 'dog' || toLowerCase() == 'cão') return l10n.species_dog;
    if (toLowerCase() == 'cat' || toLowerCase() == 'gato') return l10n.species_cat;
    return l10n.value_unknown;
  }
}
extension UserDisplayExt on String {
  String toUserDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (this == 'User Demo') return l10n.user_demo_name;
    if (isEmpty) return l10n.user_default_name;
    return this;
  }
}

extension CategoryStringExt on String {
  String toCategoryDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Map known technical keys (from PetConstants) to L10n or Fallbacks
    if (this == PetConstants.typeClinical || toLowerCase().contains('clinical')) return l10n.category_clinical;
    if (this == PetConstants.typeLab || toLowerCase().contains('lab')) return l10n.pet_type_lab;
    if (toLowerCase().contains('wound')) return l10n.category_wound;
    if (toLowerCase().contains('feces') || toLowerCase().contains('stool')) return l10n.category_feces;
    if (toLowerCase().contains('label') || toLowerCase().contains('nutrition')) return l10n.category_food_label;
    
    // New Mappings from Novas Chaves (AI Titles)
    final lower = toLowerCase();
    if (lower.contains('general')) return l10n.pet_type_general;
    if (lower.contains('visual') || lower.contains('inspection')) return l10n.pet_section_visual;
    if (lower.contains('species')) return l10n.species_label;
    if (lower.contains('coat')) return l10n.pet_section_coat;
    if (lower.contains('skin')) return l10n.pet_type_skin;
    if (lower.contains('ear')) return l10n.pet_section_ears;
    if (lower.contains('nose')) return l10n.pet_section_nose;
    if (lower.contains('eye')) return l10n.pet_type_eyes;
    if (lower.contains('body') || lower.contains('posture')) return l10n.pet_section_posture;
    if (lower.contains('issue') || lower.contains('potential')) return l10n.pet_section_issues;
    if (lower.contains('mouth') || lower.contains('teeth')) return l10n.pet_type_mouth;
    if (lower.contains('biometric')) return l10n.pet_section_biometrics;
    if (lower.contains('weight')) return l10n.pet_section_weight;

    return this; 
  }
}

extension PetUrgencyStringExt on String {
  String toUrgencyDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Normalize string to match keys or values
    // Expecting: 'Green', 'Yellow', 'Red' or 'Monitor', 'Attention', 'Critical'
    
    final lower = toLowerCase();
    
    if (lower.contains(PetConstants.parseGreen) || lower.contains(PetConstants.parseMonitor) || this == PetConstants.keyMonitor || this == PetConstants.valMonitor) {
      return l10n.key_green; 
    }
    if (lower.contains(PetConstants.parseYellow) || lower.contains(PetConstants.parseAttention) || this == PetConstants.keyImmediateAttention || this == PetConstants.valAttention) {
      return l10n.key_yellow; 
    }
    if (lower.contains(PetConstants.parseRed) || lower.contains(PetConstants.parseCritical) || this == PetConstants.keyCritical || this == PetConstants.valCritical) {
      return l10n.key_red; 
    }
    
    return this;
  }
}
