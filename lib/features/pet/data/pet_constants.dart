

enum PetImageType { 
  general, profile, wound, stool, mouth, eyes, skin, label, lab, posture, safety, newProfile 
}

class PetConstants {
  // --- BOXES E PERSISTÊNCIA ---
  static const String boxPetProfiles = 'pet_profiles';
  static const String boxPetHistory = 'pet_history';
  static const String boxPetRagIdentity = 'pet_rag_identity';
  static const String boxPetAnalyses = 'pet_analyses_storage';

  // --- CAMPOS DE DADOS (FIELDS) ---
  static const String fieldUuid = 'pet_uuid';
  static const String fieldName = 'pet_name';
  static const String legacyUnknownBreed = 'Raça não informada'; // Legacy fallback
  static const String fieldImagePath = 'imagePath';
  static const String fieldActiveModel = 'active_model';
  static const String fieldApiEndpoint = 'api_endpoint';
  static const String fieldTimestamp = 'pet_timestamp'; // Last modification
  static const String fieldCreatedAt = 'pet_created_at'; // Immutable creation date
  static const String fieldIsNeutered = 'is_neutered';
  static const String fieldResult = 'pet_analysis_result';
  static const String fieldAnalysisType = 'analysis_type';
  static const String fieldAge = 'age';
  static const String fieldWeight = 'weight';
  static const String fieldBreed = 'breed';
  static const String fieldColor = 'color';
  static const String fieldHistory = 'pet_history_log'; // New Key for History Isolation

  // --- CHAVES DE NAVEGAÇÃO E ARGUMENTOS ---
  static const String argUuid = 'uuid';
  static const String argName = 'name';
  static const String argBreed = 'breed';
  static const String argImagePath = 'image_path';
  static const String argType = 'type';
  static const String argSource = 'source';
  static const String argPetDetails = 'petDetails'; // Added for Dashboard -> Result flow
  static const String argResult = 'analysisResult'; // Added for Dashboard -> Result flow
  static const String argIsAddingNewPet = 'is_adding_new_pet'; // Added for Explicit State Control

  // --- CHAVES DE PARSING E UI ---
  static const String keyTitle = 'title';
  static const String keyContent = 'content';
  static const String keyIcon = 'icon';
  // --- CARD PARSING KEYS ---
  static const String keyCardTitle = 'title';
  static const String keyCardIcon = 'icon';
  static const String keyCardContent = 'content';
  static const String valIconInfo = 'info';
  static const String valIconPet = 'pet';
  static const String keyAnalysis = 'analysis';
  static const String keyAttention = 'attention';
  static const String keyResult = 'result';
  static const String keyDate = 'date';
  static const String keyCategory = 'category';
  static const String keyAnalysisSummary = 'Analysis Summary';
  static const String keyAnalyse = 'Analysis';
  static const String keyInfo = 'info';

  // --- TAGS DE COMUNICAÇÃO LLM ---
  static const String tagVisualSummary = '[VISUAL_SUMMARY]';
  static const String tagEndSummary = '[END_SUMMARY]';
  static const String tagCardStart = '[CARD_START]';
  static const String tagCardEnd = '[CARD_END]';
  static const String tagSources = '[SOURCES]';
  static const String tagEndSources = '[END_SOURCES]';
  static const String visualSummaryStart = '[VISUAL_SUMMARY]';
  static const String visualSummaryEnd = '[END_SUMMARY]';

  // --- LOGS ---
  static const String prefixPet = '[PET]';
  static const String logTagPetAi = '[PET_LOG]';
  static const String logTagPetError = '[PET_ERROR]';
  static const String logTagPetRag = '[PET_RAG]';
  static const String logTagPetData = '[PET_DATA_LOG]';
  static const String logTagPetFatal = '[PET_FATAL]';
  
  static const String keyRawAiResponse = 'RAW_AI_RESPONSE';
  static const String keyPetAiService = 'PetAiService';
  
  // Traces
  static const String traceSkinAnalysis = 'PetDermatologyAnalysis';
  static const String traceMouthAnalysis = 'PetDentistryAnalysis';
  static const String traceGastroAnalysis = 'PetGastroAnalysis';
  static const String traceLabAnalysis = 'PetLabAnalysis';
  static const String traceNutritionAnalysis = 'PetNutritionAnalysis';
  static const String tracePhysiqueAnalysis = 'PetPhysiqueAnalysis';
  static const String traceEyesAnalysis = 'PetOphthalmologyAnalysis';

  static const String collectionPets = 'pets';

  // --- VALORES E ESTADOS ---
  static const String valGeneral = 'general';
  static const String valStable = 'stable';
  static const String valCritical = 'critical';
  static const String valAttention = 'attention';
  static const String valMonitor = 'monitor';
  static const String valCamera = 'camera';
  static const String valGallery = 'gallery';
  static const String valTrue = 'true';
  static const String valFalse = 'false';
  static const String valueUnknown = 'Unknown';
  static const String valValid = 'Valid';
  static const String valInvalid = 'Invalid';
  static const String defaultPetName = 'Unknown Pet';
  static const String defaultPetUuid = 'temp_uuid';

  // --- ÍCONES ---
  static const String keyHeart = 'heart';
  static const String keyScissors = 'scissors';
  static const String keyCoat = 'coat';
  static const String keySearch = 'search';
  static const String keySkin = 'skin';
  static const String keyEar = 'ear';
  static const String keyWind = 'wind';
  static const String keyNose = 'nose';
  static const String keyEye = 'eye';
  static const String keyEyes = 'eyes';
  static const String keyScale = 'scale';
  static const String keyBody = 'body';
  static const String keyAlert = 'alert';
  static const String keyIssues = 'issues';
  static const String keyFileText = 'fileText';
  static const String keySummary = 'summary';
  static const String keyCritical = 'critical';
  static const String iconMenuBook = 'menu_book';
  static const String iconBook = 'book';
  static const String iconDoc = 'doc';
  static const String iconWarning = 'warning';

  // --- ANALYSIS TYPES (PERSISTENCE KEYS) ---
  static const String valMouth = 'mouth';
  static const String valSkin = 'skin';
  static const String valWound = 'wound';
  static const String valStool = 'stool';
  static const String valLab = 'lab';
  static const String valLabel = 'label';
  static const String valEyes = 'eyes';
  static const String valPosture = 'posture';
  static const String valProfile = 'profile';

  // --- PARSER DATA ---
  static const String parseGreen = 'green';
  static const String parseYellow = 'yellow';
  static const String parseRed = 'red';
  static const String parseMonitor = 'monitor';
  static const String parseAttention = 'attention';
  static const String parseCritical = 'critical';
  static const String parseVerde = 'verde';
  static const String parseAmarelo = 'amarelo';
  static const String parseVermelho = 'vermelho';
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
  static const String parseNeutered = 'castrado';
  static const String parseNeuteredFem = 'castrada';
  static const String parseIntact = 'inteiro';
  static const String parseNotNeutered = 'nao castrado';
  static const String urgencyData = 'Urgency:';
  static const String systemData = 'System:';
  static const String summaryData = 'Summary:';

  // --- REGEX ---
  static const String regexCardStart = r'\[CARD_START\]\s*(.*?)\s*(?:\[CARD_END\]|\[SOURCES\]|$)';
  static const String regexTitle = r'TITLE:\s*(.*?)(?:\n|$)';
  static const String regexContent = r'CONTENT:\s*(.*?)$';
  static const String regexIcon = r'ICON:\s*(.*?)(?:\n|$)';
  static const String regexBreed = r'\[BREED\]:\s*(.*?)(?:\n|$)';


  // --- CONFIGURAÇÕES ---
  static const String remoteConfigUrl = 'https://multiversodigital.com.br/scannut/config/food_config.json';
  
  // --- FONTES (SOURCES) ---
  static const String keySourceMerck = 'source_merck';
  static const String keySourceScanNut = 'source_scannut';
  static const String keySourceAaha = 'source_aaha';
  static const String sourceExtracted = 'Extracted from Analysis Content';
  
  static const List<String> defaultVerificationSources = [
    keySourceMerck, 
    keySourceAaha, 
    keySourceScanNut
  ];

  // --- MENSAGENS DE ERRO ---
  static const String errorHistorySave = 'Error saving history';
  static const String errorBoxNotOpen = 'Hive box not open';
  static const String errorUuidMismatch = 'UUID Mismatch';
  static const String msgWarnNoData = 'No data found';
  static const String errorNewPet = 'NEW_PET_DETECTED';
  static const String contextLab = 'Lab Report Analysis';
  static const String labDisclaimer = 'Interpretation is based on visible text. Verify with original document.';

  // --- RESTORED LEGACY KEYS (SYNC IDENTITY) ---
  static const String tagEnvironment = 'environment'; // restored
  static const String typeClinical = 'clinical'; // restored
  static const String typeLab = 'lab_result'; // restored/synced
  static const String typeNutrition = 'nutrition'; // restored
  static const String typePet = 'pet'; // restored
  static const String speciesDog = 'dog';
  static const String speciesCat = 'cat';
  static const String speciesUnknown = 'Unknown';
  static const String typeNewProfile = 'newProfile'; // New Constant to fix Hardcoded String
  
  static const String keyPetUuid = 'pet_uuid';
  static const String keyPetName = 'pet_name';
  static const String keyPetAnalysisResult = 'pet_analysis_result';
  static const String keyPetSources = 'pet_sources';
  static const String keyPetTimestamp = 'pet_timestamp';
  
  static const String keyMonitor = 'monitor';
  static const String keyImmediateAttention = 'immediate attention';
  
  // --- JSON PARSING KEYS (Protocol 2026) ---
  static const String keyJsonBreed = 'breed_id'; // Simplified per user request
  static const String keyJsonReport = 'raw_report';
  
  // --- COMMON BREEDS (CONSTANTS) ---
  static const String breedChihuahua = 'Chihuahua';
  static const String breedGolden = 'Golden Retriever';
  static const String breedLabrador = 'Labrador';
  static const String breedPoodle = 'Poodle';
  static const String breedBulldog = 'Bulldog';
  static const String breedShihTzu = 'Shih Tzu';
  static const String breedYorkshire = 'Yorkshire';
  static const String breedPug = 'Pug';
  static const String breedSchnauzer = 'Schnauzer';
  static const String breedCocker = 'Cocker';
  static const String breedBeagle = 'Beagle';
  static const String breedDachshund = 'Dachshund';
  static const String breedBoxer = 'Boxer';
  static const String breedHusky = 'Husky';
  static const String breedMaltese = 'Maltese';
  static const String breedPinscher = 'Pinscher';
  static const String breedSpitz = 'Spitz';
  static const String breedBorderCollie = 'Border Collie';
  static const String breedPastorAlemao = 'Pastor Alemão';
  static const String breedGermanShepherd = 'German Shepherd';
  static const String breedRhodesian = 'Rhodesian';
  static const String breedSrd = 'SRD';
  static const String breedViralata = 'Vira-lata';

  // --- HARDCODED STRING REPLACEMENTS (Pilar 0) ---
  static const String typeNewProfileLegacy = 'PetImageType.newProfile'; // For legacy check
  static const String tagContent = 'CONTENT:';
  static const String regexTitleIcon = r'TITLE:|ICON:';
  static const String regexLegacyFinalBreed = r'FINAL_BREED:\s*(.*?)(?:$|\n)';

  // --- COMMON BREEDS LIST (Fallback) ---
  static const List<String> commonBreedsList = [
    breedChihuahua, breedGolden, breedLabrador, breedPoodle, breedBulldog, breedShihTzu, 
    breedYorkshire, breedPug, breedSchnauzer, breedCocker, breedBeagle, breedDachshund, breedBoxer, 
    breedHusky, breedMaltese, breedPinscher, breedSpitz, breedBorderCollie, breedPastorAlemao, 
    breedGermanShepherd, breedRhodesian, breedSrd, breedViralata
  ];
}

class PetPrompts {
  static const String expertRole = 'Expert Veterinary AI Agent. Analyze:';
  static const String truthDirective = 'Grounding: Base analysis strictly on visual evidence.';
  static const String sourceMandatory = '''
  PROTOCOL: TOTAL DELIVERY (NO TRUNCATION):
  1. Urgency (Low/Medium/High).
  2. [VISUAL_SUMMARY] (Max 3 lines).
  3. 4 Technical Cards: [CARD_START]...[CARD_END].
  4. [SOURCES] 1. Source A, 2. Source B, 3. Source C [END_SOURCES].
  5. [METADATA] breed_name: ... [END_METADATA].''';

  static const String visualSummary = 'Be concise. Technical term density: HIGH. Avoid repetition.';
  static const String multimodalInstruction = 'Multimodal Support: OCR for Lab Reports and Food Labels.';
  static const String outputLang = 'Respond in the language: ';
  
  static const String breedInstruction = '''
  MANDATORY FINAL BLOCK:
  [METADATA] breed_name: [Raça Identificada] | species: [Espécie] [END_METADATA].
  If you run out of tokens, shorten the cards but NEVER omit the Metadata or Sources.''';
  
  static const String jsonFormat = 'STRUCTURE: Use [CARD_START] TITLE: ... ICON: ... CONTENT: ... [CARD_END]. Deep technical detail required (no summaries). Use **bold** for medical terms.'; 
  static const String noMarkdown = 'FORMAT: Pure Text + Tags. NO JSON blocks. NO Markdown formatting (except bold). Ensure all tags [CARD_START], [CARD_END], [METADATA] are present.';
}
