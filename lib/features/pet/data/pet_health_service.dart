import 'package:scannutplus/features/pet/data/pet_repository.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart'; // Correct Repo
import 'package:scannutplus/pet/agenda/pet_event.dart'; // Correct Model
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/core/services/universal_ai_service.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';

class PetHealthService {
  final PetRepository _petRepo = PetRepository();
  final PetEventRepository _eventRepo = PetEventRepository();
  final UniversalAiService _aiService = UniversalAiService();

  Future<String> generateHealthSummary(String petUuid, {required AppLocalizations l10n}) async {
    try {
      // 1. Gather Data (RAG Source)
      debugPrint('[PetHealthService] Generating Summary for UUID: $petUuid');
      final history = await _petRepo.getPetHistory(petUuid);
      debugPrint('[PetHealthService] History entries found: ${history.length}');
      
      // Fetch Events safely
      final eventsResult = await _eventRepo.getByPetId(petUuid);
      final events = eventsResult.isSuccess ? (eventsResult.data ?? []) : <PetEvent>[];
      debugPrint('[PetHealthService] Agenda events found: ${events.length}');

      final allPets = await _petRepo.getAllRegisteredPets();
      
      final profile = allPets.firstWhere(
        (p) => p[PetConstants.fieldUuid] == petUuid, 
        orElse: () => <String, String?>{PetConstants.fieldName: "Unknown Pet", PetConstants.fieldBreed: "Unknown"}
      );
      debugPrint('[PetHealthService] Profile found: ${profile[PetConstants.fieldName]}');

      // 2. Construct Context
      StringBuffer sb = StringBuffer();
      sb.writeln('--- PET PROFILE ---');
      sb.writeln('Name: ${profile[PetConstants.fieldName]}');
      sb.writeln('Breed: ${profile[PetConstants.fieldBreed] ?? "Unknown"}');
      sb.writeln('-------------------');
      
      sb.writeln('--- RECENT MEDICAL HISTORY (Analysis Logs) ---');
      if (history.isEmpty) {
        sb.writeln('(No analysis history available)');
      } else {
        // Limit to last 10 relevant entries to fit token window
        for (var entry in history.take(10)) {
           sb.writeln('Date: ${entry[PetConstants.fieldTimestamp]}');
           sb.writeln('Category: ${entry[PetConstants.fieldAnalysisType]}');
           // Extract text content from JSON if possible, or use raw snippet
           String snippet = entry[PetConstants.keyPetAnalysisResult] ?? '';
           if (snippet.length > 300) snippet = '${snippet.substring(0, 300)}...';
           sb.writeln('Summary: $snippet');
           sb.writeln('---');
        }
      }

      sb.writeln('--- AGENDA & EVENTS ---');
      if (events.isEmpty) {
         sb.writeln('(No agenda events)');
      } else {
        for (var event in events.take(10)) {
          sb.writeln('Date: ${event.startDateTime}');
          sb.writeln('Type: ${event.eventTypeIndex} (1=Health, 6=Friend, 5=Other)');
          if (event.notes != null) sb.writeln('Notes: ${event.notes}');
          sb.writeln('---');
        }
      }

      final fullPrompt = sb.toString();
      debugPrint('[PetHealthService] RAG Context Constructed (${fullPrompt.length} chars). Sending to AI...');

      // 3. Call AI
      final result = await _aiService.analyzeText(
        systemPrompt: """
Role: Senior Veterinary Data Analyst.
Task: Analyze the provided records for this pet.
Output Format (Strict - NO Markdown Headers, ONLY Cards):

[CARD_START]
TITLE: Estado Geral 🏥
ICON: heart
CONTENT:
(Based on recent logs. Use **bold** for key findings).
[CARD_END]

[CARD_START]
TITLE: Problemas Crônicos ⚠️
ICON: alert
CONTENT:
(Identify recurring patterns).
[CARD_END]

[CARD_START]
TITLE: Histórico Recente 📅
ICON: doc
CONTENT:
(Summarize last 30 days).
[CARD_END]

[SOURCES]
(List references or 'Baseado no Histórico Clínico do Pet')
[END_SOURCES]

Language: Portuguese (Brasil).
Be concise, professional, and empathetic. Do NOT use ## Headers outside cards.
""",
        userPrompt: sb.toString(),
        l10n: l10n,
      );
      
      // [ARCHIVE] Save to History & Agenda
      if (result.isNotEmpty && !result.startsWith("Error")) {
          await _petRepo.saveHealthSummary(petUuid, result);
      }
      
      return result;
    } catch (e) {
      debugPrint('[PetHealthService] Error generating summary: $e');
      return "Não foi possível gerar o resumo no momento. Tente novamente mais tarde.";
    }
  }

  Future<String> generateNutritionPlan(String petUuid, {
    String dietType = 'Híbrida (Ração + Natural)',
    String goal = 'Manter Peso (Equilíbrio)',
    required AppLocalizations l10n,
  }) async {
    try {
      debugPrint('[PetHealthService] Generating Nutrition Plan for UUID: $petUuid (Type: $dietType, Goal: $goal)');
      final allPets = await _petRepo.getAllRegisteredPets();
      final profile = allPets.firstWhere(
        (p) => p[PetConstants.fieldUuid] == petUuid, 
        orElse: () => <String, String?>{PetConstants.fieldName: "Unknown Pet", PetConstants.fieldBreed: "Unknown"}
      );
      debugPrint('[PetHealthService] Nutrition Profile: ${profile[PetConstants.fieldName]} (${profile[PetConstants.fieldBreed]})');

      StringBuffer sb = StringBuffer();
      sb.writeln('Name: ${profile[PetConstants.fieldName]}');
      sb.writeln('Breed: ${profile[PetConstants.fieldBreed]}');
      // In future: Add Weight, Age, Activity Level

      debugPrint('[PetHealthService] Sending Nutrition Request to AI...');
      final result = await _aiService.analyzeText(
        systemPrompt: """
Role: Senior Veterinary Specialist and Nutritionist.
Task: Create a 7-Day Nutrition Plan and Shopping List.
Pet Profile: ${sb.toString()}
Diet Preference: $dietType
Health Goal: $goal

NUTRITION STRATEGY SELECTOR (Active Goal: $goal):
- If "Weight Loss": Focus on caloric deficit, high fiber, and satiety management.
- If "Muscle Building": Focus on high bioavailability proteins and amino acid profiles.
- If "Weight Maintenance": Focus on precise macronutrient balance for life stage.
- If "Therapeutic/Disease": Focus on specific support (Renal, Hepatic, Gastro) based on history or breed risks.
- If "Exclusion Diet": Single novel protein + single carb source. STRICTLY AVOID common allergens.
- If "Senior/Cognitive": High MCTs, Omega-3, and antioxidants.
- If "Puppy/Kitten": High energy, Calcium/Phosphorus balance for growth.
- If "Gestating/Lactating": High energy density and nutrient support.
- If "Athlete/Work": High calorie, joint support, and glycogen replenishment.
- If "Recovery": Highly palatable, digestible, and energy-dense.

STRICT RESPONSE GUIDELINES:
1. FOOD SENSITIVITY (CRITICAL): Scan the profile for allergies or sensitivities (e.g., NO chicken, NO rice, NO grains). You are STRICTLY FORBIDDEN from including these ingredients. Provide safe alternatives.
2. SCIENTIFIC TRUTH: Base all findings on clinical facts and veterinary literature (NRC, WSAVA, Merck).
3. STRUCTURE: Follow this Strict Card Format (NO Markdown Headers ##):

[CARD_START]
TITLE: Estratégia ($goal) 🥗
ICON: info
CONTENT:
(Explain the strategy. Focus on $dietType).
[CARD_END]

[CARD_START]
TITLE: Segunda-Feira 📅
ICON: food
CONTENT:
(Refeições da Segunda-Feira. Formato:
* 08:00 - Item
* 12:00 - Item)
[CARD_END]

[CARD_START]
TITLE: Terça-Feira 📅
ICON: food
CONTENT:
(Refeições da Terça-Feira)
[CARD_END]

[CARD_START]
TITLE: Quarta-Feira 📅
ICON: food
CONTENT:
(Refeições da Quarta-Feira)
[CARD_END]

[CARD_START]
TITLE: Quinta-Feira 📅
ICON: food
CONTENT:
(Refeições da Quinta-Feira)
[CARD_END]

[CARD_START]
TITLE: Sexta-Feira 📅
ICON: food
CONTENT:
(Refeições da Sexta-Feira)
[CARD_END]

[CARD_START]
TITLE: Sábado 📅
ICON: food
CONTENT:
(Refeições do Sábado)
[CARD_END]

[CARD_START]
TITLE: Domingo 📅
ICON: food
CONTENT:
(Refeições do Domingo)
[CARD_END]

[CARD_START]
TITLE: Lista de Compras 🛒
ICON: doc
CONTENT:
(Categorized list).
[CARD_END]

[CARD_START]
TITLE: Precauções ⚠️
ICON: alert
CONTENT:
(Allergies, sensitivities, and warnings).
[CARD_END]

[SOURCES]
(Cite nutritional guidelines e.g. FEDIAF, NRC)
[END_SOURCES]

Language: Portuguese (Brasil).
""",
        userPrompt: "Create plan for ${profile[PetConstants.fieldName]} with diet: $dietType and goal: $goal.",
        l10n: l10n,
      );

      // [ARCHIVE] Save to History & Agenda
      // DISABLED: The user explicitly requested that Nutrition Plans
      // DO NOT generate cards in the analysis history timeline.
      // if (result.isNotEmpty && !result.startsWith("Error")) {
      //     await _petRepo.saveNutritionPlan(petUuid, result);
      // }

      return result;
    } catch (e) {
       debugPrint('[PetHealthService] Error generating nutrition: $e');
       return "Erro ao gerar plano nutricional.";
    }
  }

  Future<String?> getLatestNutritionPlan(String petUuid) async {
    return await _petRepo.getLatestNutritionPlan(petUuid);
  }
}

