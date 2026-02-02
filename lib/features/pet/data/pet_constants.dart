class PetConstants {
  static const String speciesDog = 'dog';
  static const String speciesCat = 'cat';
  static const String typePet = 'pet';
  static const String typeLabel = 'label';

  // Persistence & RAG
  static const String boxPetAnalyses = 'pet_analyses_storage';
  static const String keyPetAnalysisResult = 'pet_analysis_result';
  static const String keyPetSources = 'pet_sources';
  static const String keyPetUuid = 'pet_uuid';
  static const String keyPetName = 'pet_name';
  static const String keyPetTimestamp = 'pet_timestamp';
  
  static const String sourceExtracted = 'Extracted from Analysis Content';
  
  // Logs
  static const String logTagPetData = '[PET_DATA_LOG]';
  static const String logTagPetAi = '[PET_LOG]';
  static const String logTagPetFatal = '[PET_FATAL]';
  
  // Remote Config
  static const String remoteConfigUrl = 'https://multiversodigital.com.br/scannut/config/food_config.json';
  
  // Fields for Persistence & Config
  static const String fieldActiveModel = 'active_model';
  static const String fieldApiEndpoint = 'api_endpoint';
  static const String fieldUuid = 'pet_uuid';
  static const String fieldName = 'pet_name';
  static const String fieldIsNeutered = 'is_neutered';
  static const String fieldResult = 'pet_analysis_result';
  static const String fieldTimestamp = 'pet_timestamp';
  static const String fieldConfigModel = 'config_model';
  static const String fieldAnalysisType = 'analysis_type'; // clinical, lab, nutrition

  static const String typeClinical = 'clinical';
  static const String typeLab = 'lab_result';
  static const String typeNutrition = 'nutrition';

  static const String defaultPetName = 'Unknown Pet';
  static const String defaultPetUuid = 'temp_uuid';
  static const String contextLab = 'Lab Report Analysis (Blood/Urine/Feces)';
  
  static const String keyPetEmbeddings = 'pet_embeddings';
  static const String logTagPetRag = '[PET_RAG]';

  static const String visualSummaryStart = '[VISUAL_SUMMARY]';
  static const String visualSummaryEnd = '[END_SUMMARY]';
  
  static const String urgencyData = 'Urgency:';
  static const String systemData = 'System:';
  static const String summaryData = 'Summary:';
  
  static const String parseGreen = 'green';
  static const String parseVerde = 'verde';
  static const String parseYellow = 'yellow';
  static const String parseAmarelo = 'amarelo';
  static const String parseRed = 'red';
  static const String parseVermelho = 'vermelho';
  
  static const String errorNewPet = 'NEW_PET_DETECTED';
  
  static const String parseNeutered = 'castrado';
  static const String parseNeuteredFem = 'castrada';
  static const String parseIntact = 'inteiro';
  static const String parseNotNeutered = 'nao castrado';
  
  static const String parseMacho = 'macho';
  static const String parseMale = 'male';
  static const String parseFemea = 'fêmea';
  static const String parseFemea2 = 'femea';
  static const String parseFemale = 'female';
  static const String parseSex = 'sex';
  static const String parseMaleResult = 'Male';
  static const String parseFemaleResult = 'Female';
  
  static const String parseWeight = 'weight';
  static const String parseAge = 'age';
  
  static const String valTrue = 'true';
  static const String valFalse = 'false';
}

class PetPrompts {
  static const String expertRole = 'Expert Veterinary AI Agent. Analyze:';
  static const String truthDirective = 'Grounding: Base analysis strictly on visual evidence. If unclear, state insufficient evidence.';
  static const String sourceMandatory = 'Mandatory: List 3 main academic/veterinary sources at the end. Identify if it is Blood/Urine/Feces Exam or Food Label.';
  static const String visualSummary = 'Start response strictly with: [VISUAL_SUMMARY] \\nLine 1: Urgency: (Green/Yellow/Red)\\nLine 2: System: [Emoji]\\nLine 3: Summary: [One sentence].\\n[END_SUMMARY]\\nThen details.';
  static const String multimodalInstruction = 'Multimodal Support: If image is a Food Label, analyze nutritional quality. If Lab Report (Blood/Urine/Feces), perform OCR, compare with reference values, highlight deviations. Do NOT diagnose.';
  static const String outputLang = 'Respond in the language: '; // Dynamic
}
