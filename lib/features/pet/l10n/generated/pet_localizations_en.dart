// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'pet_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class PetLocalizationsEn extends PetLocalizations {
  PetLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pet_capture_title => 'Pet Capture';

  @override
  String get pet_capture_instructions => 'The AI analyzes images of the pet, wounds, stool, mouth, eyes, and skin. One at a time.';

  @override
  String get pet_saved_success => 'Pet saved successfully';

  @override
  String get pet_analysis_error => 'Analysis failed';

  @override
  String get pet_history_empty => 'No history found';

  @override
  String get pet_tab_history => 'History';

  @override
  String get pet_tab_capture => 'Capture';

  @override
  String get pet_label_species => 'Species';

  @override
  String get pet_label_dog => 'Dog';

  @override
  String get pet_label_cat => 'Cat';

  @override
  String get pet_result_title => 'Analysis Result';

  @override
  String get pet_section_observations => 'Visual Observations';

  @override
  String get pet_section_sources => 'Consulted Sources';

  @override
  String get pet_disclaimer => 'The analysis is visual only and does not replace veterinary evaluation.';

  @override
  String get pet_action_share => 'Share with Vet';

  @override
  String get pet_action_new_analysis => 'New Analysis';

  @override
  String get pet_footer_text => 'Result Page | © 2026 Multiverso Digital';

  @override
  String get pet_action_analyze => 'Analyze Now';

  @override
  String get pet_status_analyzing => 'Analyzing...';

  @override
  String get pet_voice_title => 'Voice Identification';

  @override
  String get pet_voice_instruction => 'New friend detected! Say name, sex, weight, and age.';

  @override
  String get pet_voice_hint => 'Ex: Thor, Male, 12kg, 4 years';

  @override
  String get pet_voice_action => 'Send Voice';

  @override
  String get pet_voice_retry => 'Retry';

  @override
  String pet_rag_new_identity(Object name) {
    return 'Identity saved: $name';
  }

  @override
  String pet_analysis_for(Object name) {
    return 'Analysis: $name';
  }

  @override
  String get pet_voice_who_is_this => 'Who is this pet?';
}
