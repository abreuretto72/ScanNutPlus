import 'package:scannutplus/features/pet/data/pet_constants.dart';

class PetVoiceParserService {
  Map<String, String> parse(String text) {
    if (text.isEmpty) return {};

    final result = <String, String>{};
    
    // Normalize
    final lower = text.toLowerCase();
    final parts = lower.split(RegExp(r'[\s,]+')); // Split by space or comma

    // Heuristics (Pilar 0: Simple & Robust)
    
    // 1. Name is typically the first word if it's not a keyword
    // But user might say "My dog is Thor" -> Not strict. 
    // Assumption: User says "Thor Male 12kg 4years" as per instruction.
    if (parts.isNotEmpty) {
       // Check if first word is 'o' 'a' 'is' etc.
       String possibleName = parts[0];
       // Simple cleanup
       result[PetConstants.fieldName] = possibleName[0].toUpperCase() + possibleName.substring(1);
    }

    // 2. Sex
    if (lower.contains(PetConstants.parseMacho) || lower.contains(PetConstants.parseMale)) {
      result[PetConstants.parseSex] = PetConstants.parseMaleResult;
    } else if (lower.contains(PetConstants.parseFemea) || lower.contains(PetConstants.parseFemea2) || lower.contains(PetConstants.parseFemale)) {
      result[PetConstants.parseSex] = PetConstants.parseFemaleResult;
    }

    // 3. Weight (look for digits near 'kg' or 'kilos')
    // Regex for (\d+)[ ]?(kg|kilos)
    final weightRegex = RegExp(r'(\d+([\.,]\d+)?)\s*(kg|kilos|kilo|g)');
    final weightMatch = weightRegex.firstMatch(lower);
    if (weightMatch != null) {
      result[PetConstants.parseWeight] = weightMatch.group(0) ?? '';
    }
    
    // 5. Neutered Status (Pilar Voices)
    if (lower.contains(PetConstants.parseNeutered) || lower.contains(PetConstants.parseNeuteredFem)) {
      result[PetConstants.fieldIsNeutered] = PetConstants.valTrue;
    } else if (lower.contains(PetConstants.parseIntact) || lower.contains(PetConstants.parseNotNeutered)) {
       result[PetConstants.fieldIsNeutered] = PetConstants.valFalse;
    }

    // 4. Age (look for digits near 'anos' 'years')
    final ageRegex = RegExp(r'(\d+)\s*(anos|ano|years|year|y)');
    final ageMatch = ageRegex.firstMatch(lower);
    if (ageMatch != null) {
      result[PetConstants.parseAge] = ageMatch.group(0) ?? '';
    }

    return result;
  }
}

final petVoiceParserService = PetVoiceParserService();
