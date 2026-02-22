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
      case PetImageType.posture: return l10n.pet_module_physique;
      case PetImageType.lab: return l10n.pet_type_lab; 
      case PetImageType.stool: return l10n.category_feces;
      case PetImageType.safety: return l10n.pet_type_safety;
      case PetImageType.label: return l10n.pet_module_nutrition; // Changed from category_food_label as per user request (Rotulos)
      case PetImageType.general: return l10n.pet_type_general;
      case PetImageType.wound: return l10n.category_wound;
      case PetImageType.newProfile: return l10n.pet_type_new_profile;
      case PetImageType.vocal: return l10n.pet_module_vocal;
      case PetImageType.behavior: return l10n.pet_module_behavior;
      case PetImageType.plantCheck: return l10n.pet_module_plant;
      case PetImageType.foodBowl: return l10n.pet_module_food_bowl;
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
    // Fix: Check 'label' before 'lab' because 'label' contains 'lab'
    if (toLowerCase().contains('label')) return l10n.pet_module_nutrition; // "Rótulos"
    if (toLowerCase().contains('nutrition')) return l10n.category_food_label; // Keep "Alimentos" for general nutrition if needed, or unify.
    
    if (this == PetConstants.typeClinical || toLowerCase().contains('clinical')) return l10n.category_clinical;
    if (this == PetConstants.typeLab || toLowerCase().contains('lab')) return l10n.pet_type_lab;
    if (toLowerCase().contains('wound')) return l10n.category_wound;
    if (toLowerCase().contains('feces') || toLowerCase().contains('stool')) return l10n.category_feces;
    
    // Archive Mappings
    if (this == PetConstants.catHealthSummary) return l10n.category_clinical; // Reuse Clinical
    if (this == PetConstants.catNutritionPlan) return l10n.pet_plan_nutritional; // Localized
    
    // Specific camelCase mappings (Raw Keys)
    if (this == 'newProfile' || this == PetConstants.typeNewProfile) return l10n.pet_type_new_profile;
    if (this == 'plantCheck' || this == PetConstants.valPlantCheck) return l10n.pet_module_plant;
    if (this == 'behavior' || this == PetConstants.valBehavior) return l10n.pet_module_behavior;
    if (this == 'vocal' || this == PetConstants.valVocal) return l10n.pet_module_vocal;
    if (this == 'mouth' || this == PetConstants.valMouth) return l10n.pet_type_mouth;
    if (this == 'skin' || this == PetConstants.valSkin) return l10n.pet_type_skin;
    if (this == 'foodBowl' || this == PetConstants.valFoodBowl) return l10n.pet_module_food_bowl;
    
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
    if (lower.contains('body') || lower.contains('posture')) return l10n.pet_module_physique;
    if (lower.contains('issue') || lower.contains('potential')) return l10n.pet_section_issues;
    if (lower.contains('mouth') || lower.contains('teeth')) return l10n.pet_type_mouth;
    if (lower.contains('biometric')) return l10n.pet_section_biometrics;
    if (lower.contains('weight')) return l10n.pet_section_weight;

    // Mappings for new Repository Keys (Pilar 0 Fix)
    if (lower == 'pet_title_ophthalmology') return l10n.pet_title_ophthalmology;
    if (lower == 'pet_title_dental') return l10n.pet_title_dental;
    if (lower == 'pet_title_dermatology') return l10n.pet_title_dermatology;
    if (lower == 'pet_title_ears') return l10n.pet_title_ears;
    if (lower == 'pet_title_digestion') return l10n.pet_title_digestion;
    if (lower == 'pet_title_body_condition') return l10n.pet_title_body_condition;
    if (lower == 'pet_title_vocalization') return l10n.pet_title_vocalization;
    if (lower == 'pet_title_behavior') return l10n.pet_title_behavior;
    if (lower == 'pet_title_walk') return l10n.pet_title_walk;
    if (lower == 'pet_title_ai_chat') return l10n.pet_title_ai_chat;
    if (lower == 'pet_title_nutrition') return l10n.pet_title_nutrition;
    if (lower == 'pet_title_lab') return l10n.pet_title_lab;
    if (lower == 'pet_title_label_analysis') return l10n.pet_title_label_analysis;
    if (lower == 'pet_title_plants' || lower == 'pet_title_pants') return l10n.pet_title_plants; // Fix: Handle typo 'pants'
    if (lower == 'pet_title_initial_eval') return l10n.pet_title_initial_eval;
    if (lower == 'pet_title_health_summary') return l10n.pet_title_health_summary;
    if (lower == 'pet_title_general_checkup') return l10n.pet_title_general_checkup;
    if (lower == 'pet_title_clinical_summary') return l10n.pet_title_clinical_summary;
    if (lower == 'pet_title_planned_meal') return l10n.pet_title_planned_meal;

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
      // We only want the common name, so we stop capturing before the first opening parenthesis.
      if (plantName.isEmpty) {
          final metaMatch = RegExp(r'breed_name:\s*([^\(|\]\n]+)', caseSensitive: false).firstMatch(rawJson);
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
              String rawTitle = firstCard[l10n.tech_title] ?? '';
              final icon = firstCard[l10n.tech_icon] ?? '';
              final content = firstCard[l10n.tech_content] ?? '';
              
              isToxic = icon == l10n.tech_warning || icon == '⚠️' || icon == '☠️' || icon == '💀';
              
              // If we already found the name in metadata only, we still need to check toxicity in cards if not parsed from raw
              if (plantName.isEmpty) {
                  // Validate Title: If generic, search inside Content
                  final lowerTitle = rawTitle.toLowerCase();
                  bool isGeneric = lowerTitle.contains(l10n.tech_identification) || 
                                   lowerTitle.contains(l10n.tech_analysis) || 
                                   lowerTitle.contains(l10n.tech_plant) ||
                                   lowerTitle.contains(l10n.tech_health);
                                   
                  if (!isGeneric && rawTitle.split(' ').length < 10) {
                      plantName = rawTitle.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();
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
                                  plantName = candidate.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();
                                  break;
                              }
                          }
                      }
                      // Ultimate Fallback if regex fails but title was generic
                      if (plantName.isEmpty) plantName = rawTitle.replaceAll(RegExp(r'\s*\(.*\)'), '').trim(); 
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
            isToxic = iconStr == l10n.tech_warning || iconStr == '⚠️' || iconStr == '☠️' || iconStr == '💀';
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

      // Clean cleanup and final strip of any lingering scientific names in parenthesis
      plantName = plantName.replaceAll(RegExp(r'[*_:]'), '').replaceAll(RegExp(r'\s*\(.*\)'), '').trim();

      // Format: "Name (Toxic/Safe)"
      final status = isToxic ? l10n.pet_plant_toxic : l10n.pet_plant_safe;
      return '$plantName ($status)';
  }
}

extension AppointmentTypeExt on String {
  /// Translates a raw appointment_type from the DB (e.g. 'vaccine_annual') into a localized string.
  String toAppointmentTypeDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch(this) {
      // Health
      case 'consultation_general': return l10n.pet_apt_consultation_general;
      case 'consultation_return': return l10n.pet_apt_consultation_return;
      case 'consultation_specialist': return l10n.pet_apt_consultation_specialist;
      case 'consultation_tele': return l10n.pet_apt_consultation_tele;
      case 'vaccine_annual': return l10n.pet_apt_vaccine_annual;
      case 'vaccine_specific': return l10n.pet_apt_vaccine_specific;
      case 'vaccine_booster': return l10n.pet_apt_vaccine_booster;
      case 'exam_blood': return l10n.pet_apt_exam_blood;
      case 'exam_ultrasound': return l10n.pet_apt_exam_ultrasound;
      case 'exam_xray': return l10n.pet_apt_exam_xray;
      case 'exam_lab': return l10n.pet_apt_exam_lab;
      case 'exam_periodic': return l10n.pet_apt_exam_periodic;
      case 'procedure_castration': return l10n.pet_apt_procedure_castration;
      case 'procedure_surgery': return l10n.pet_apt_procedure_surgery;
      case 'procedure_dental': return l10n.pet_apt_procedure_dental;
      case 'procedure_dressing': return l10n.pet_apt_procedure_dressing;
      case 'treatment_physio': return l10n.pet_apt_treatment_physio;
      case 'treatment_acu': return l10n.pet_apt_treatment_acu;
      case 'treatment_chemo': return l10n.pet_apt_treatment_chemo;
      case 'treatment_hemo': return l10n.pet_apt_treatment_hemo;
      
      // Wellness
      case 'wellness_bath': return l10n.pet_apt_wellness_bath;
      case 'wellness_grooming': return l10n.pet_apt_wellness_grooming;
      case 'wellness_hygienic': return l10n.pet_apt_wellness_hygienic;
      case 'wellness_hydration': return l10n.pet_apt_wellness_hydration;
      case 'wellness_daycare': return l10n.pet_apt_wellness_daycare;
      case 'wellness_hotel': return l10n.pet_apt_wellness_hotel;

      // Behavior
      case 'behavior_training': return l10n.pet_apt_behavior_training;
      case 'behavior_evaluation': return l10n.pet_apt_behavior_evaluation;
      case 'behavior_social': return l10n.pet_apt_behavior_social;

      // Nutrition
      case 'nutrition_meal': return l10n.pet_apt_nutrition_meal;
      case 'nutrition_food_change': return l10n.pet_apt_nutrition_food_change;

      // Services
      case 'service_taxi': return l10n.pet_apt_service_taxi;
      case 'service_delivery': return l10n.pet_apt_service_delivery;
      case 'service_nutrition': return l10n.pet_apt_service_nutrition;
      case 'service_mealplan': return l10n.pet_apt_service_mealplan;

      // Docs
      case 'doc_vaccine_card': return l10n.pet_apt_doc_vaccine_card;
      case 'doc_health_cert': return l10n.pet_apt_doc_health_cert;
      case 'doc_microchip': return l10n.pet_apt_doc_microchip;
      case 'doc_gta': return l10n.pet_apt_doc_gta;
      case 'doc_travel': return l10n.pet_apt_doc_travel;

      default: return l10n.pet_apt_consultation_general; // Fallback
    }
  }
}
