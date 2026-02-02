class AppKeys {
  // Env
  static const String geminiApiKey = 'GEMINI_API_KEY';
  static const String invalidKey = 'INVALID_KEY';
  static const String envFile = 'assets/.env';

  // AI & Logs
  static const String petAiAnalysis = 'pet_ai_analysis';
  static const String logImage = 'image';
  static const String logLang = 'lang';
  static const String logColorReset = '\x1B[0m';
  static const String logColorRed = '\x1B[31m';
  static const String logColorGreen = '\x1B[32m';
  static const String logColorYellow = '\x1B[33m';
  static const String logColorBlue = '\x1B[34m';

  static const String logColorPurple = '\x1B[35m';

  static const String logPrefixPet = '[PET_LOG]';
  static const String logPrefixPetTrace = '[PET_TRACE]';
  static const String logPrefixPetError = '[PET_ERROR]';
  static const String logPrefixPetResponse = '[PET_RESPONSE_RAW]';
  static const String logPrefixPetSource = '[PET_SOURCE]';
  static const String logTraceContext = 'context';

  // Fonts
  static const String fontMonospace = 'monospace';

  // Grounding Keywords
  static const List<String> sourceKeywords = [
    'references:', 'sources:', 'based on', 'fontes:', 'referências:', 'baseado em'
  ];

  // Errors & Logs
  static const String errorImageNotFound = 'Image not found at ';
  static const String errorNoAnalysis = 'No analysis generated.';
  static const String errorAiUnavailable = 'AI Analysis unavailable: ';
  static const String petErrorTimeout = 'pet_error_timeout';
  static const String errorEnvMissing = 'EnvService Error: .env file not found or invalid: ';

  static const String errorGeminiMissing = 'CRITICAL: GEMINI_API_KEY not found in .env';

  // Config Keys
  static const String configKeyActiveModel = 'active_model';
  static const String configKeyApiEndpoint = 'api_endpoint';

  // Preferences
  static const String onboardingCompleted = 'onboarding_completed';
}
