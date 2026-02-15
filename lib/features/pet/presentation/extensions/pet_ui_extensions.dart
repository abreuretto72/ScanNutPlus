import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'dart:convert'; // Required for jsonDecode used in extension

extension PetImageTypeExt on PetImageType {
  /// Mapeia o Enum técnico para a string traduzida no arquivo .arb
  String toDisplayString(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PetImageType.profile: return l10n.pet_type_general; // Contextually similar to general or needs specific 'Profile' key if meant for UI tab
      case PetImageType.skin: return l10n.pet_type_skin;
      case PetImageType.eyes: return l10n.pet_type_eyes;
      case PetImageType.ears: return l10n.pet_module_ears;
      case PetImageType.mouth: return l10n.pet_type_mouth;
      case PetImageType.posture: return l10n.pet_section_posture;
      case PetImageType.lab: return l10n.pet_type_lab; 
      case PetImageType.stool: return l10n.category_feces;
      case PetImageType.safety: return l10n.pet_type_safety;
      case PetImageType.label: return l10n.category_food_label;
      case PetImageType.general: return l10n.pet_type_general;
      case PetImageType.wound: return l10n.category_wound;
      case PetImageType.newProfile: return l10n.pet_type_new_profile;
      case PetImageType.vocal: return l10n.pet_module_vocal;
      case PetImageType.behavior: return l10n.pet_module_behavior;
      case PetImageType.plantCheck: return l10n.pet_module_plant;
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
    
    // Specific camelCase mappings (Raw Keys)
    if (this == 'newProfile' || this == PetConstants.typeNewProfile) return l10n.pet_type_new_profile;
    if (this == 'plantCheck' || this == PetConstants.valPlantCheck) return l10n.pet_module_plant;
    if (this == 'behavior' || this == PetConstants.valBehavior) return l10n.pet_module_behavior;
    if (this == 'vocal' || this == PetConstants.valVocal) return l10n.pet_module_vocal;
    if (this == 'mouth' || this == PetConstants.valMouth) return l10n.pet_type_mouth;
    if (this == 'skin' || this == PetConstants.valSkin) return l10n.pet_type_skin;
    
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
    
    if (lower.contains(PetConstants.parseGreen) || lower.contains(PetConstants.parseMonitor) || this == PetConstants.valMonitor) {
      return l10n.key_green; 
    }
    if (lower.contains(PetConstants.parseYellow) || lower.contains(PetConstants.parseAttention) || this == PetConstants.valAttention) {
      return l10n.key_yellow; 
    }
    if (lower.contains(PetConstants.parseRed) || lower.contains(PetConstants.parseCritical) || this == PetConstants.keyCritical || this == PetConstants.valCritical) {
      return l10n.key_red; 
    }
    
    return this;
  }
}

extension PetHistoryEntryExt on PetHistoryEntry {
  /// Extracts the Plant Name and Toxicity status for the History Card Title
  /// Returns null if not a plant or not found.
  String? getPlantTitle(BuildContext context) {
      if (category != PetConstants.valPlantCheck) return null;
      
      final l10n = AppLocalizations.of(context)!;
      String plantName = '';
      bool isToxic = false;

      // 0. Priority: Check Metadata in Raw JSON (Most Reliable)
      // Log Example: [METADATA] breed_name: Cóleo (Plectranthus scutellarioides) | ...
      if (plantName.isEmpty) {
          final metaMatch = RegExp(r'breed_name:\s*([^|\]\n]*)', caseSensitive: false).firstMatch(rawJson);
          if (metaMatch != null) {
              plantName = metaMatch.group(1)?.trim() ?? '';
          }
      }

      // 1. Try to parse from JSON cards if available
      try {
        if (analysisCardsJson.isNotEmpty) {
           final List<dynamic> cards = jsonDecode(analysisCardsJson);
           if (cards.isNotEmpty) {
              final firstCard = cards.first;
              String rawTitle = firstCard['title'] ?? '';
              final icon = firstCard['icon'] ?? '';
              final content = firstCard['content'] ?? '';
              
              isToxic = icon == 'warning' || icon == '⚠️' || icon == '☠️' || icon == '💀';
              
              // If we already found the name in metadata only, we still need to check toxicity in cards if not parsed from raw
              if (plantName.isEmpty) {
                  // Validate Title: If generic, search inside Content
                  final lowerTitle = rawTitle.toLowerCase();
                  bool isGeneric = lowerTitle.contains('identificação') || 
                                   lowerTitle.contains('análise') || 
                                   lowerTitle.contains('plant') ||
                                   lowerTitle.contains('saúde');
                                   
                  if (!isGeneric && rawTitle.split(' ').length < 10) {
                      plantName = rawTitle;
                  } else {
                      // DEEP SEARCH IN CONTENT
                      // Patterns: **Name**, Nome: Name, Species: Name
                      final namePatterns = [
                          RegExp(r'(?:Nome|Name|Planta|Plant):\s*([^*\n]+)', caseSensitive: false),
                          RegExp(r'\*\*([^*\n]+)\*\*', caseSensitive: false), // Bold text usually implied name
                      ];
                      
                      for (final pattern in namePatterns) {
                          final match = pattern.firstMatch(content);
                          if (match != null) {
                              String candidate = match.group(1)?.trim() ?? '';
                              // Cleanup
                              if (candidate.isNotEmpty && candidate.length < 40) { // Increased length for scientific names
                                  plantName = candidate;
                                  break;
                              }
                          }
                      }
                      // Ultimate Fallback if regex fails but title was generic
                      if (plantName.isEmpty) plantName = rawTitle; 
                  }
              }
           }
        }
      } catch (_) {}

      // 2. Fallback: Parse from Raw Text (Legacy / Fallback for Toxicity)
      // If we still don't have toxicity status, check rawJson
      if (!isToxic) {
         final iconMatch = RegExp(PetConstants.regexIcon).firstMatch(rawJson);
         if (iconMatch != null) {
            final iconStr = iconMatch.group(1)?.trim() ?? '';
            isToxic = iconStr == 'warning' || iconStr == '⚠️' || iconStr == '☠️' || iconStr == '💀';
         }
      }

      // 3. Last resort for name
      if (plantName.isEmpty) {
         final titleMatch = RegExp(PetConstants.regexTitle).firstMatch(rawJson);
         if (titleMatch != null) {
            plantName = titleMatch.group(1)?.trim() ?? '';
         }
      }

      if (plantName.isEmpty) return l10n.pet_module_plant;

      // Clean cleanup
      plantName = plantName.replaceAll(RegExp(r'[*_:]'), '').trim();

      // Format: "Name (Toxic/Safe)"
      final status = isToxic ? l10n.pet_plant_toxic : l10n.pet_plant_safe;
      return '$plantName ($status)';
  }
}
