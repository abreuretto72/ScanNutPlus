class PetEventConstants {
  // Social Metrics
  static const String friendName = 'friendName';
  static const String tutorName = 'tutorName';

  // Location Metrics
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String locationName = 'location_name'; // Kept snake_case for consistency with previous usage
  static const String timestamp = 'timestamp';
  static const String provider = 'provider';

  // Audio Metrics
  static const String audioType = 'audio_type';
  static const String rawVoiceNote = 'raw_voice_note';
  static const String audioAnalysisResult = 'audio_analysis_result';
  static const String detectedPattern = 'detected_pattern';
  static const String severity = 'severity';
  static const String confidence = 'confidence';

  // Audio Analysis Values
  static const String valCough = 'cough';
  static const String valMedium = 'medium';

  // Providers
  // Providers
  static const String providerSimulated = 'simulated';

  // Speech to Text Status
  static const String sttStatusDone = 'done';
  static const String sttStatusNotListening = 'notListening';
  
  // Debug Tags
  static const String debugTagStt = 'STT Error:';
  static const String debugTagSttInit = 'STT Init Error:';
  static const String debugTagSttStatus = 'STT Status:';
  static const String debugTagGps = 'SCAN_NUT_TRACE: GPS Status: Fixed';
}
