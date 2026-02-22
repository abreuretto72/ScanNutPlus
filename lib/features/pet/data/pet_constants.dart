

enum PetImageType { 
  general, profile, wound, stool, mouth, eyes, ears, skin, label, lab, posture, safety, newProfile, vocal, behavior, plantCheck, foodBowl
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
  static const String keyPageTitle = 'page_title'; // Added for PDF Title Transport
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
  
  // --- DATA KEYS (METRICS/JSON) ---
  static const String keyLatitude = 'latitude';
  static const String keyLongitude = 'longitude';
  static const String keyAddress = 'address';
  static const String keyAudioPath = 'audio_path';
  static const String keyAiSummary = 'ai_summary';
  
  // Chat Keys
  static const String keySender = 'sender';
  static const String keyMapTypeIndex = 'pet_map_type_index';

  // Hero Tags
  static const String heroQuickAlertFab = 'quick_alert_fab';
  static const String heroLayersFab = 'layers_fab';
  static const String keyText = 'text';
  static const String keyUser = 'user';
  static const String keyAi = 'ai';

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
  static const String statusActive = 'Active';
  static const String typeVaccine = 'vaccine';

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
  static const String valVocal = 'vocal';
  static const String valBehavior = 'behavior';
  static const String valPlantCheck = 'plantCheck';
  static const String valFoodBowl = 'foodBowl'; // New: Visual Food Analysis
  static const String catHealthSummary = 'health_summary';
  static const String catNutritionPlan = 'nutrition_plan';

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
  
  // --- AUDIO EXTENSIONS ---
  static const List<String> audioExtensions = ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'flac'];

  // --- GALLERY EXTENSIONS (Images + Videos) ---
  static const List<String> galleryExtensions = [
    'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', // Images
    'mp4', 'mov', 'mpeg4', 'avi', 'webm' // Videos
  ];
  
  static const List<String> videoExtensions = ['mp4', 'mov', 'mpeg4', 'avi', 'webm'];
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'];

  // --- CLASSIFICATION CONSTANTS ---
  static const List<String> healthKeywords = []; // Deprecated: Use l10n.pet_logic_keywords_health

  // --- VOCAL / AUDIO CONSTANTS (Pilar 0) ---
  static const String keyLatido = 'latido';
  static const String keyUivo = 'uivo';
  static const String keyChorando = 'chorando';
  static const String keyTosse = 'tosse';
  static const String keyEngasgo = 'engasgo';
  static const String keyEspirro = 'espirro';
  static const String keyRespiracao = 'respiração';
  static const String keyBark = 'bark';
  static const String keyHowl = 'howl';
  static const String keyCrying = 'crying';
  static const String keyCough = 'cough';
  static const String keyChoking = 'choking';
  static const String keySneeze = 'sneeze';
  static const String keyBreathing = 'breathing';

  static const String errApiKeyMissing = "API Key Missing";
  static const String errNoAnalysisReturned = "No analysis returned.";
  static const String errVocalAnalysis = "Erro na análise vocal: ";
  static const String defaultNoNotes = "No notes";
  static const String mimeMp3 = 'audio/mpeg';
  static const String mimeMp4 = 'audio/mp4';
  static const String mimeWav = 'audio/wav';
  static const String mimeAac = 'audio/aac';
  static const String mimeOgg = 'audio/ogg';

  // --- VIDEO CONSTANTS (Pilar 0) ---
  static const String keyVideoPath = 'video_path';
  static const String errVideoAnalysis = "Erro na análise de vídeo: ";
  
  // Behavior/Posture Keywords
  static const String keyClaudicacao = 'claudicação';
  static const String keyMancando = 'mancando';
  static const String keyTremor = 'tremor';
  static const String keyEspasmo = 'espasmo';
  static const String keyCircular = 'andando em círculos';
  static const String keyCabecaPressionada = 'pressionando cabeça';
  static const String keyProstracao = 'prostração';
  static const String keyLetargia = 'letargia';

  // --- REGEX ---
  static const String regexCardStart = r'\[CARD_START\]\s*(.*?)\s*(?:\[CARD_END\]|\[SOURCES\]|$)';
  static const String regexTitle = r'TITLE:\s*(.*?)(?:\s*ICON:|\s*CONTENT:|\n|$)';
  static const String regexContent = r'CONTENT:\s*(.*?)$';
  static const String regexIcon = r'ICON:\s*(.*?)(?:\s*CONTENT:|\n|$)';
  static const String regexBreed = r'\[BREED\]:\s*(.*?)(?:\n|$)';


  // --- CONFIGURAÇÕES ---
  static const String envGeminiApiKey = 'GEMINI_API_KEY';
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

  // --- ERROR CODES & LOGIC STRINGS (Pilar 0) ---
  static const String err500 = '500';
  static const String errInternal = 'Internal';
  static const String errOverloaded = 'Overloaded';
  static const String errTimeout = 'Timeout';
  static const String msgAiOverloaded = 'AI Overloaded';

  // --- RESTORED LEGACY KEYS (SYNC IDENTITY) ---
  static const String tagEnvironment = 'environment'; // restored
  static const String typeClinical = 'clinical'; // restored
  static const String typeLab = 'lab_result'; // restored/synced
  static const String typeLabel = 'label'; // New: Food Label
  static const String typeNutrition = 'nutrition'; // restored
  static const String typePet = 'pet'; // restored
  static const String typeFriend = 'friend'; // Module 2026: Friend Pet
  static const String valNewFriend = 'new_friend'; // Dropdown option
  static const String keyIsFriend = 'is_friend';
  static const String keyTutorName = 'tutor_name';
  static const String speciesDog = 'dog';
  static const String speciesDogPt = 'cão';
  static const String speciesCat = 'cat';
  static const String speciesCatPt = 'gato';
  static const String speciesUnknown = 'Unknown';
  static const String typeNewProfile = 'newProfile'; // New Constant to fix Hardcoded String
  static const String typeVocal = 'vocal';
  
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
  static const String regexBreedPt = r'Raça:\s*([^\n]*)';
  static const String regexBreedEn = r'Race:\s*([^\n]*)';

  // --- COMMON BREEDS LIST (Fallback) ---
  static const List<String> commonBreedsList = [
    breedChihuahua, breedGolden, breedLabrador, breedPoodle, breedBulldog, breedShihTzu, 
    breedYorkshire, breedPug, breedSchnauzer, breedCocker, breedBeagle, breedDachshund, breedBoxer, 
    breedHusky, breedMaltese, breedPinscher, breedSpitz, breedBorderCollie, breedPastorAlemao, 
    breedGermanShepherd, breedRhodesian, breedSrd, breedViralata
  ];
  static const String commonBreedsListEnd = 'END_LIST'; // Anchor

  // --- PILAR 0: MISSING CONSTANTS ---
  static const String valNull = 'null';
  static const String valYes = 'SIM';
  static const String valNo = 'NÃO';
  
  // LOGS
  // static const String logTagPetData = 'SCAN_NUT_DATA'; // Duplicate removed
  static const String logBlockedEmpty = 'SCAN_NUT_TRACE: [BLOCKED] Attempt to save profile with empty name.';
  static const String logDbWriteNew = 'SCAN_NUT_TRACE: [DB_WRITE] Tentando salvar pet (New Profile Logic).';
  static const String logDbWriteUpdate = 'SCAN_NUT_TRACE: [DB_WRITE] Tentando atualizar pet (UPDATE Logic).';
  static const String logDbWriteData = 'SCAN_NUT_TRACE: [DB_WRITE] Dados: ';
  static const String logDbWriteExist = 'SCAN_NUT_TRACE: [DB_WRITE] Já existe no banco? ';
  static const String logNavHistory = 'SCAN_NUT_TRACE: [NAV] Navegando para o Histórico do Pet: ';
  static const String logResetAddingPet = 'SCAN_NUT_TRACE: [RESET] Resetting _isAddingNewPet to FALSE';
  static const String logAnalysisClick = 'SCAN_NUT_TRACE: [CLIQUE] Iniciando análise para o Pet.';
  static const String logUiBuild = 'SCAN_NUT_TRACE: [UI_BUILD] Renderizando My Pets. Total no banco: ';
  static const String logUiItem = 'SCAN_NUT_TRACE: [UI_ITEM] Pet no Banco -> ';
  static const String logNavHealthPlaceholder = 'SCAN_NUT_TRACE: [NAV] Health clicked for UUID: ';
  static const String logNavAgenda = 'SCAN_NUT_TRACE: Navigation to [Agenda] for UUID: ';
  static const String logSanitization = 'SCAN_NUT_TRACE: [SANITIZATION] Removing {} ghost pets found.';
  static const String logHistorySearch = 'SCAN_NUT_TRACE: [HISTORY] Buscando para UUID: ';
  static const String logHistoryFound = 'SCAN_NUT_TRACE: [HISTORY] Encontrados: ';
  
  // AI CHAT LOGS
  static const String logErrorGeminiEnv = 'SCAN_NUT_ERROR: GEMINI_API_KEY not found in .env';
  static const String logTraceAiModel = 'SCAN_NUT_TRACE: AI Model initialized with: ';
  static const String logWarnAiModel = 'SCAN_NUT_WARN: Failed to fetch remote model config. Using default. Error: ';
  static const String logErrorGeminiInit = 'SCAN_NUT_ERROR: Failed to init Gemini: ';
  static const String logSttStatus = 'STT Status: ';
  static const String logSttError = 'STT Error: ';

  // RAG
  static const String ragProfileHeader = '--- PET PROFILE ---';
  static const String ragHistoryHeader = '--- MEDICAL HISTORY ---';
  static const String ragNoHistory = '(No history available)';
  static const String ragUnknownProfile = 'Unknown Profile';
  static const String ragSeparator = '-------------------';
  static const String ragEndBlock = '--- END CONTEXT ---';
  
  static const String labelName = 'Name: ';
  static const String labelBreed = 'Breed: ';
  static const String labelSpecies = 'Species: ';
  static const String labelDate = 'Date: ';
  static const String labelCategory = 'Category: ';
  static const String labelSummary = 'Summary: ';

  // --- MAP ALERTS ---
  static const String alertPoison = 'poison';
  static const String alertDogLoose = 'dog_loose'; // Cão Bravo / Solto
  static const String alertDangerousHole = 'dangerous_hole'; // Buraco Perigoso
  static const String alertRiskArea = 'risk_area'; // Assalto/Perigo
  static const String alertNoise = 'noise'; // Barulho Excessivo

  static const String logErrorMapLoad = 'Error loading map alerts: ';
  static const String logErrorGps = 'GPS Error: ';
}

class PetPrompts {
  // --- PROTOCOL 2026: CONCISE PROMPTS ---
  static const String expertRole = 'Role: Senior Veterinary Pathologist.';
  static const String chatSystemContext = '''
ROLE: You are the dedicated AI Veterinary Assistant for {petName}.
DATE: {date}

[DATABASE CONTEXT]
{context}
[END CONTEXT]

INSTRUCTIONS:
1. TRUTH: Base your answers PRIMARILY on the [DATABASE CONTEXT]. Do not hallucinate data not present there.
2. SOURCES: You MUST cite the source of your information.
   - If from DB: "Found in profile..." or "[Source: Medical History]" (Translate to user language)
   - If general knowledge: "[Source: Veterinary Protocol]" or "[Source: Merck Manual]" (Translate to user language)
   - If insurance: "[Source: Health Plan]" (Translate to user language)
3. EMPATHY: Be helpful, caring, but professional.
4. LANGUAGE: Answer in the same language as the user's question.

User Question: {question}
''';
  static const String truthDirective = 'Analysis: Visual Only. Be direct.';
  
  // --- MOCK DATA ---
  static const String mockAiHealthAlert = "AI Alert: Potential Health Issue Detected based on keywords/image.\nRecommendation: Monitor hydration and consult a vet if symptoms persist.";

  static const String sourceMandatory = '''
  OUTPUT FORMAT (Strict):
  1. Urgency: [Low/Med/High]
  2. [VISUAL_SUMMARY] ... [END_SUMMARY]
  3. [CARD_START] TITLE:... ICON:... CONTENT:... [CARD_END] (Max 4 cards)
  4. [SOURCES]
  - Source 1
  - Source 2
  - Source 3
  [END_SOURCES]
  5. [METADATA] breed_name: ... | species: ... [END_METADATA]
  * CRITICAL: For plants, 'breed_name' MUST be the Popular Name ONLY. Do NOT include the scientific name or parenthesis. ''';

  static const String visualSummary = 'Summary: Technical & Concise.';
  static const String multimodalInstruction = 'Task: Analyze Image/Text.';
  static const String outputLang = 'Lang: ';
  
  static const String breedInstruction = 'Metadata required. Cards required.';
  
  static const String jsonFormat = 'Style: Technical. Use **bold**.'; 
  static const String noMarkdown = 'NO Markdown blocks. Pure text + Tags.';

  static const String promptWalkSummary = '''
  ROLE: Veterinary Behaviorist & Health Analyst.
  TASK: Analyze the following timeline of events from a pet's walk/day.
  
  INPUT DATA:
  - List of events with: Time, Type (Urine, Stool, Water, Photo), and Notes.
  - SPECIAL EVENTS: Look for "Google" tags (Telemetry, Altimetry, Weather).
  - Context: [Pet Name], [Breed], [Age].

  OUTPUT OBJECTIVES:
  1. TELEMETRY: Mention Distance & Pace if available (e.g., "Active walk: 3.2km").
  2. CALORIES: Use Elevation Gain (Altimetry) to estimate effort (e.g., "High burn due to 45m climb").
  3. CONTEXT: Note environment (Park, Urban) and how it affects behavior.
  4. PHYSIOLOGY: Correlate Weather (Temp/UV) with hydration needs.
  5. HIGHLIGHT anomalies (e.g., loose stool, lethargy).
  6. FORMAT:
     - Use [VISUAL_SUMMARY] ... [END_SUMMARY] for a brief overview (2-3 lines).
     - Use [CARD_START] TITLE:... ICON:... CONTENT:... [CARD_END] for detailed sections (Telemetry, Effort, Environment, Health).
     - Icons: 'map' (Telemetry), 'fire' (Calories/Effort), 'tree' (Context), 'heart' (Physiology).
  
  LANGUAGE: Respond in the same language as the input notes (usually Portuguese/English/Spanish).
  ''';
}
