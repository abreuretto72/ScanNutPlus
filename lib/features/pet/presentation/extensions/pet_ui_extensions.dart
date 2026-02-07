import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

extension PetImageTypeExt on PetImageType {
  /// Mapeia o Enum técnico para a string traduzida no arquivo .arb
  String toDisplayString(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PetImageType.profile: return l10n.pet_section_body;
      case PetImageType.skin: return l10n.pet_section_skin;
      case PetImageType.eyes: return l10n.pet_section_eyes;
      case PetImageType.mouth: return l10n.pet_section_mouth;
      case PetImageType.posture: return l10n.pet_section_posture;
      case PetImageType.lab: return l10n.pet_section_exams; // Mapped to exams based on context
      case PetImageType.stool: return l10n.category_feces;
      case PetImageType.safety: return l10n.pet_section_safety;
      case PetImageType.label: return l10n.category_food_label;
      case PetImageType.general: return l10n.pet_type_general;
      case PetImageType.wound: return l10n.category_wound;
      case PetImageType.newProfile: return l10n.pet_dialog_new_title;
    }
  }
}

extension PetSpeciesExt on String {
  /// Mapeia a string de espécie vinda do banco/IA para tradução
  String toSpeciesDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (this.toLowerCase() == 'dog' || this.toLowerCase() == 'cão') return l10n.species_dog;
    if (this.toLowerCase() == 'cat' || this.toLowerCase() == 'gato') return l10n.species_cat;
    return l10n.value_unknown;
  }
}
extension UserDisplayExt on String {
  String toUserDisplay(BuildContext context) {
    if (this == 'User Demo') return AppLocalizations.of(context)!.user_demo_name;
    if (this.isEmpty) return AppLocalizations.of(context)!.user_default_name;
    return this;
  }
}

extension CategoryStringExt on String {
  String toCategoryDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Map known technical keys (from PetConstants) to L10n
    if (this == PetConstants.typeClinical || this.toLowerCase().contains('clinical')) return l10n.category_clinical;
    if (this == PetConstants.typeLab || this.toLowerCase().contains('lab')) return l10n.category_lab;
    if (this.toLowerCase().contains('wound')) return l10n.category_wound;
    if (this.toLowerCase().contains('feces') || this.toLowerCase().contains('stool')) return l10n.category_feces;
    if (this.toLowerCase().contains('label') || this.toLowerCase().contains('nutrition')) return l10n.category_food_label;
    
    // New Mappings from Novas Chaves (AI Titles)
    final lower = this.toLowerCase();
    if (lower.contains('general pet analysis')) return l10n.pet_section_general;
    if (lower.contains('visual health') || lower.contains('inspection')) return l10n.pet_section_visual;
    if (lower.contains('species')) return l10n.pet_section_species;
    if (lower.contains('coat')) return l10n.pet_section_coat;
    if (lower.contains('skin')) return l10n.pet_section_skin;
    if (lower.contains('ear')) return l10n.pet_section_ears;
    if (lower.contains('nose')) return l10n.pet_section_nose;
    if (lower.contains('eye')) return l10n.pet_section_eyes;
    if (lower.contains('body') || lower.contains('posture')) return l10n.pet_section_posture;
    if (lower.contains('issue') || lower.contains('potential')) return l10n.pet_section_issues;
    if (lower.contains('mouth') || lower.contains('teeth')) return l10n.pet_section_mouth;
    if (lower.contains('biometric')) return l10n.pet_section_biometrics;
    if (lower.contains('weight')) return l10n.pet_section_weight;

    return this; // Fallback to original string if no translation found
  }
}

extension PetUrgencyStringExt on String {
  String toUrgencyDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Normalize string to match keys or values
    // Expecting: 'Green', 'Yellow', 'Red' or 'Monitor', 'Attention', 'Critical'
    // Or keys: 'key_green', 'key_yellow', 'key_red'
    
    final lower = this.toLowerCase();
    
    if (lower.contains(PetConstants.parseGreen) || lower.contains(PetConstants.parseMonitor) || this == PetConstants.keyMonitor || this == PetConstants.parseMonitor) {
      return l10n.key_green; // "Monitorar"
    }
    if (lower.contains(PetConstants.parseYellow) || lower.contains(PetConstants.parseAttention) || this == PetConstants.keyImmediateAttention || this == PetConstants.parseAttention) {
      return l10n.key_yellow; // "Atenção"
    }
    if (lower.contains(PetConstants.parseRed) || lower.contains(PetConstants.parseCritical) || this == PetConstants.keyCritical || this == PetConstants.parseCritical) {
      return l10n.key_red; // "Crítico"
    }
    
    return this;
  }
}
