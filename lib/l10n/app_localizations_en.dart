// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'ScanNut+';

  @override
  String get login_title => 'Login';

  @override
  String get login_title_plus => 'ScanNut+';

  @override
  String get login_subtitle => 'Access your digital wellness universe';

  @override
  String get login_email_label => 'Email';

  @override
  String get login_email_hint => 'E-mail';

  @override
  String get login_password_label => 'Password';

  @override
  String get login_password_hint => 'Password';

  @override
  String get login_confirm_password_hint => 'Confirm Password';

  @override
  String get login_button_enter => 'Log In';

  @override
  String get login_button_biometrics => 'Log In with Biometrics';

  @override
  String get login_keep_me => 'Keep me logged in';

  @override
  String get login_no_account => 'Don\'t have an account?';

  @override
  String get login_sign_up => 'Sign Up';

  @override
  String get biometric_success => 'Biometrics verified successfully';

  @override
  String get login_error_credentials => 'Invalid credentials';

  @override
  String get error_password_short => 'Password must be at least 8 characters';

  @override
  String get error_password_weak => 'Needs uppercase, number, and special char';

  @override
  String get error_password_mismatch => 'Passwords do not match';

  @override
  String get pwd_help_title => 'Password Rules';

  @override
  String get pwd_rule_length => 'Minimum of 8 characters';

  @override
  String get pwd_rule_uppercase => 'At least one uppercase letter';

  @override
  String get pwd_rule_number => 'At least one number';

  @override
  String get pwd_rule_special => 'At least one special character';

  @override
  String get biometric_error => 'Biometric authentication failed';

  @override
  String get biometric_reason => 'Scan to authenticate';

  @override
  String get biometric_tooltip => 'Biometrics';

  @override
  String get common_copyright => 'ScanNut+ © 2026 Multiverso Digital';

  @override
  String get tabFood => 'Food';

  @override
  String get tabPlants => 'Plants';

  @override
  String get tabPets => 'Pets';

  @override
  String get splashPoweredBy => 'Powered by AI Vision';

  @override
  String get home_title => 'Home';

  @override
  String get home_welcome => 'Welcome Home';

  @override
  String get onboarding_title => 'Welcome to ScanNut+';

  @override
  String get onboarding_welcome =>
      'Your AI companion for food, plants, and pets.';

  @override
  String get onboarding_button_start => 'Get Started';

  @override
  String get debug_nav_login_forced => 'NAVIGATE_TO_LOGIN_DEBUG';

  @override
  String get debug_nav_onboarding => 'NAVIGATE_TO_ONBOARDING';

  @override
  String get debug_nav_login_no_session => 'NAVIGATE_TO_LOGIN_NO_SESSION';

  @override
  String get debug_nav_home_bio_success => 'NAVIGATE_TO_HOME_BIO_SUCCESS';

  @override
  String get debug_nav_login_bio_fail => 'NAVIGATE_TO_LOGIN_BIO_FAIL';

  @override
  String get debug_nav_home_session_active => 'NAVIGATE_TO_HOME_SESSION_ACTIVE';

  @override
  String get auth_required_fallback => 'Authentication Required';

  @override
  String get login_success => 'Login successful';

  @override
  String get signup_success => 'Registration successful';

  @override
  String home_welcome_user(Object name) {
    return 'Hello, $name';
  }

  @override
  String get tab_food => 'Food';

  @override
  String get tab_plant => 'Plants';

  @override
  String get tab_pet => 'Pets';

  @override
  String get common_logout => 'Logout';

  @override
  String get logout_success => 'Logged out successfully';

  @override
  String get food_scan_title => 'Food Scanner';

  @override
  String get food_analyzing => 'Analyzing nutritional content...';

  @override
  String get food_analysis_success => 'Analysis Complete';

  @override
  String get food_calories => 'Calories';

  @override
  String get food_protein => 'Protein';

  @override
  String get food_carbs => 'Carbs';

  @override
  String get food_fat => 'Fat';

  @override
  String get food_btn_scan => 'Scan Food';

  @override
  String get food_btn_gallery => 'Gallery';

  @override
  String get food_empty_history => 'No food scans yet.';

  @override
  String get domain_pets_navigation => 'Pets Navigation';

  @override
  String get pets_navigation_subtitle => 'Pet Directions Assistant';

  @override
  String get menu_profile => 'Profile';

  @override
  String get menu_settings => 'Settings';

  @override
  String get menu_help => 'Help';

  @override
  String get stub_map_module => 'Map Module Coming Soon';

  @override
  String get user_demo_name => 'User Demo';

  @override
  String get user_default_name => 'User';

  @override
  String get food_mock_grilled_chicken => 'Grilled Chicken Salad';

  @override
  String get food_key_calories => 'calories';

  @override
  String get food_key_protein => 'protein';

  @override
  String get food_key_carbs => 'carbs';

  @override
  String get food_key_fat => 'fat';

  @override
  String get food_key_name => 'name';

  @override
  String get test_food => 'Test: Food';

  @override
  String get test_plants => 'Test: Plants';

  @override
  String get test_pets => 'Test: Pets';

  @override
  String get test_navigation => 'Test: Navigation';

  @override
  String get debug_gallery_title => 'Color Gallery';

  @override
  String get auth_biometric_reason => 'Scan to verify your identity';

  @override
  String get app_name_plus => 'ScanNut+';

  @override
  String get pdf_copyright => '© 2026 ScanNut+ Multiverso Digital';

  @override
  String get pdf_page => 'Page';

  @override
  String get dev_name => 'Multiverso Digital';

  @override
  String get dev_email => 'contato@multiversodigital.com.br';

  @override
  String get about_title => 'About';

  @override
  String get version_label => 'Version';

  @override
  String get contact_label => 'Contact';

  @override
  String get copyright_label => '© 2026 Multiverso Digital';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_email_label => 'Email';

  @override
  String get profile_biometric_enable => 'Enable Biometric Auth';

  @override
  String get common_confirm_exit => 'Do you really want to exit?';

  @override
  String get profile_change_password => 'Change Password';

  @override
  String get password_current => 'Current Password';

  @override
  String get password_new => 'New Password';

  @override
  String get password_confirm => 'Confirm Password';

  @override
  String get password_save => 'Save New Password';

  @override
  String get password_match_error => 'Passwords do not match';

  @override
  String get password_success => 'Password changed successfully';

  @override
  String get default_user_name => 'User';

  @override
  String get pet_capture_title => 'Pet Capture';

  @override
  String get action_take_photo => 'Take Photo';

  @override
  String get action_upload_gallery => 'Upload from Gallery';

  @override
  String get species_label => 'Species';

  @override
  String get species_dog => 'Dog';

  @override
  String get species_cat => 'Cat';

  @override
  String get image_type_label => 'Image Type';

  @override
  String get type_pet => 'Pet';

  @override
  String get type_label => 'Food';

  @override
  String get pet_saved_success => 'Pet saved successfully';

  @override
  String get label_analysis_pending => 'Label analysis coming soon';

  @override
  String get action_retake => 'Retake';

  @override
  String get label_name => 'Name';

  @override
  String get label_email => 'Email';

  @override
  String get hint_user_name => 'Enter your name';

  @override
  String get section_account_data => 'Account Data';

  @override
  String get help_title => 'Help & Support';

  @override
  String get help_how_to_use => 'How to Use';

  @override
  String get help_pet_scan_tip =>
      'Scan your pet or food labels for nutritional analysis.';

  @override
  String get help_privacy_policy => 'Privacy Policy';

  @override
  String get help_contact_support => 'Contact Support';

  @override
  String get help_dev_info => 'Developed by Multiverso Digital';

  @override
  String get help_privacy_content =>
      'Your data is processed locally whenever possible. We respect your privacy.';

  @override
  String get help_email_subject => 'ScanNut+ Support';

  @override
  String get help_story_title => 'Our Story';

  @override
  String get help_origin_story =>
      'The name of this app is a tribute to my pet, Nut. My idea was to create a tool for complete management of his life, from routine organization to the creation of healthy menus. In daily life, ScanNut helps me record every occurrence. For stool, urine, and blood tests, I use AI to get initial insights through image analysis — a technological support I always share with the vet. Additionally, I included a plant guide to identify toxic species and ensure his safety. Thinking about my own health, I added the Food Scan to monitor calories, vitamins, and generate meal plans with shopping lists. I feel that, now, the app is complete for both of us.';

  @override
  String get help_analysis_guide_title => 'AI Analysis Guide';

  @override
  String get help_disclaimer =>
      'This analysis is visual only and does not replace a veterinary evaluation.';

  @override
  String get help_section_pet_title => 'General Pet Analysis';

  @override
  String get help_section_pet_desc =>
      'Analyzes species, size estimate, body posture (pain/comfort signs), and environment safety.';

  @override
  String get help_section_wound_title => 'Wounds & Injuries';

  @override
  String get help_section_wound_desc =>
      'Evaluates size, visual aspect (pus/blood presence), redness, and signs of inflammation.';

  @override
  String get help_section_stool_title => 'Stool Analysis';

  @override
  String get help_section_stool_desc =>
      'Checks consistency (Bristol scale), color changes, and visible presence of mucus or worms.';

  @override
  String get help_section_mouth_title => 'Dental & Mouth';

  @override
  String get help_section_mouth_desc =>
      'Inspects gum color (pale/red), tartar buildup, and broken teeth indicators.';

  @override
  String get help_section_eyes_title => 'Eyes Health';

  @override
  String get help_section_eyes_desc =>
      'Detects secretion, redness, cloudiness (opacity), and potential irritation signs.';

  @override
  String get help_section_skin_title => 'Skin & Coat';

  @override
  String get help_section_skin_desc =>
      'Identifies hair loss patches, redness, flakes, and unusual spots or lumps.';

  @override
  String get help_can_do => 'What AI can detect';

  @override
  String get help_cannot_do => 'Limit: Needs Vet confirmation';

  @override
  String get pet_capture_instructions =>
      'The AI analyzes images of the pet, wounds, stool, mouth, eyes, and skin. One at a time.';

  @override
  String get help_domain_pet_title => 'Pet Domain';

  @override
  String get help_domain_pet_desc =>
      'Complete management for Dogs and Cats: AI for visual analysis, health routines, and toxic plant safety guide.';

  @override
  String get help_domain_food_title => 'Food Domain';

  @override
  String get help_domain_food_desc =>
      'Your health management: Food scanning, nutrient counting, and healthy meal plan creation.';

  @override
  String get help_domain_plant_title => 'Plant Domain';

  @override
  String get help_domain_plant_desc =>
      'Plant Guide: Identify species in your garden or home and know instantly if they are toxic to your pet, based on real botanical data.';

  @override
  String get pet_capture_info_title => 'ScanNut+ AI Capabilities';

  @override
  String get pet_capture_capability_labels =>
      'Food Label & Ingredient Analysis';

  @override
  String get pet_capture_capability_exams => 'Clinical Reports & Lab Exams';

  @override
  String get pet_capture_capability_biometrics =>
      'Posture & Biometric Monitoring';

  @override
  String get pet_capture_capability_visual => 'Visual Health Inspection';

  @override
  String get pet_input_name_hint => 'What is the pet\'s name?';

  @override
  String get pet_result_status_stable => 'Status: Stable';

  @override
  String get pet_result_summary_title => 'Analysis Summary';

  @override
  String get pet_result_visual_empty => 'No visual anomalies detected';

  @override
  String pet_analysis_error_generic(Object error) {
    return 'Analysis Error: $error';
  }

  @override
  String get pet_urgency_red => 'urgency: red';

  @override
  String get pet_urgency_immediate => 'immediate attention';

  @override
  String get pet_urgency_critical => 'critical';

  @override
  String get pet_urgency_yellow => 'urgency: yellow';

  @override
  String get pet_urgency_monitor => 'monitor';

  @override
  String get pet_status_critical => 'Status: Critical Attention';

  @override
  String get pet_status_monitor => 'Status: Monitor';

  @override
  String get pet_mock_visual_confirm => 'Visual analysis confirms structure...';

  @override
  String get pet_label_pet => 'Pet';

  @override
  String get pet_section_species => 'Species Identification';

  @override
  String get pet_section_health => 'General Health & Behavior';

  @override
  String get pet_section_coat => 'General Coat Condition';

  @override
  String get pet_section_skin => 'Skin Appearance';

  @override
  String get pet_action_share => 'Share';

  @override
  String get source_merck => 'Merck Veterinary Manual (MSD Digital 2026)';

  @override
  String get source_scannut => 'ScanNut+ Biometry & Phenotyping Protocol';

  @override
  String get source_aaha => 'AAHA/WSAVA Physical Exam Guidelines';

  @override
  String get pet_section_ears => 'Ears';

  @override
  String get pet_section_nose => 'Nose';

  @override
  String get pet_section_eyes => 'Eyes';

  @override
  String get pet_section_body => 'Body Conditions';

  @override
  String get pet_section_issues => 'Potential Issues';

  @override
  String get pet_status_healthy => 'HEALTHY STATUS';

  @override
  String get pet_status_attention => 'ATTENTION REQUIRED';

  @override
  String get key_green => 'Monitor';

  @override
  String get key_yellow => 'Attention';

  @override
  String get key_red => 'Critical';

  @override
  String get value_unknown => 'Unknown';

  @override
  String error_database_load(String error) {
    return 'Error loading database: $error';
  }

  @override
  String get pet_section_mouth => 'Mouth';

  @override
  String get pet_section_posture => 'Posture';

  @override
  String get pet_section_exams => 'Exams';

  @override
  String get category_feces => 'Stool';

  @override
  String get category_food_label => 'Food Label';

  @override
  String get pet_type_general => 'General';

  @override
  String get category_wound => 'Wound';

  @override
  String get pet_dialog_new_title => 'New Profile';

  @override
  String get category_clinical => 'Clinical';

  @override
  String get category_lab => 'Lab';

  @override
  String get pet_section_general => 'General Analysis';

  @override
  String get pet_section_biometrics => 'Biometrics';

  @override
  String get pet_section_weight => 'Weight';

  @override
  String get pet_ui_my_pets => 'My Pets';

  @override
  String get pet_my_pets_title => 'My Pets';

  @override
  String get pet_no_pets_registered => 'No pets registered yet.';

  @override
  String get pet_dashboard_title => 'Pet Dashboard';

  @override
  String get pet_action_biometrics => 'Biometrics';

  @override
  String get pet_action_history => 'Analysis history';

  @override
  String get pet_type_label => 'Food';

  @override
  String get pet_type_wound => 'Wound';

  @override
  String get pet_type_stool => 'Stool';

  @override
  String get pet_type_mouth => 'Mouth';

  @override
  String get pet_type_eyes => 'Eyes';

  @override
  String get pet_type_skin => 'Skin';

  @override
  String get pet_type_lab => 'Lab Results';

  @override
  String get pet_select_context => 'Select analysis type:';

  @override
  String get pet_unknown => 'Unknown';

  @override
  String pet_analyzing_x(String name) {
    return 'Analyzing: $name';
  }

  @override
  String pet_id_format(String id) {
    return 'ID: $id...';
  }

  @override
  String get pet_section_visual => 'Visual Inspection';

  @override
  String get pet_type_safety => 'Safety';

  @override
  String get pet_type_new_profile => 'New Profile';

  @override
  String get pet_waze_title => 'Pet Waze';

  @override
  String get pet_waze_desc => 'Community alerts near you';

  @override
  String get pet_partners_title => 'Partners';

  @override
  String get pet_partners_desc => 'Discounts and services';

  @override
  String get pet_tab_history => 'History';

  @override
  String get pet_history_empty => 'No history available';

  @override
  String get pet_analysis_result_title => 'Analysis Result';

  @override
  String get pet_status_healthy_simple => 'Healthy';

  @override
  String get pet_status_critical_simple => 'Critical';

  @override
  String get pet_status_attention_simple => 'Attention';

  @override
  String get pet_section_sources => 'References & Protocol';

  @override
  String get pet_action_new_analysis => 'New Analysis';

  @override
  String get source_scannut_db => 'ScanNut+ Database';

  @override
  String get pet_unknown_name => 'Unnamed';

  @override
  String get pet_footer_brand => 'ScanNut+ Pet Intelligence';

  @override
  String get pet_label_status => 'Status';

  @override
  String get pet_history_title => 'Analysis History';

  @override
  String get pet_breed_unknown => 'Unknown Breed';

  @override
  String get pet_label_breed => 'Breed';

  @override
  String get pet_label_sex => 'Sex';

  @override
  String get pet_sex_male => 'Male';

  @override
  String get pet_sex_female => 'Female';

  @override
  String get pet_delete_title => 'Delete Pet';

  @override
  String get pet_delete_content =>
      'Are you sure you want to delete this pet and all its history?';

  @override
  String get pet_delete_confirm => 'Delete';

  @override
  String get pet_delete_cancel => 'Cancel';

  @override
  String get pet_history_delete_success => 'History deleted successfully!';

  @override
  String get pet_ai_overloaded_message =>
      'AI overloaded! Please try again in a few moments.';

  @override
  String get pet_delete_success => 'Pet deleted successfully';

  @override
  String get pet_recent_analyses => 'Recent Analyses';

  @override
  String get pet_no_history => 'No recent analyses.';

  @override
  String get pet_new_pet => 'New Pet';

  @override
  String get val_unknown_date => 'Unknown Date';

  @override
  String get report_generated_on => 'Generated on';

  @override
  String get pet_analysis_skin => 'Skin & Coat';

  @override
  String get pet_analysis_mouth => 'Oral Health';

  @override
  String get pet_analysis_stool => 'Stool Screening';

  @override
  String get pet_analysis_lab => 'Lab Report Reading';

  @override
  String get pet_analysis_label => 'Nutrition & Labels';

  @override
  String get pet_analysis_posture => 'Body Condition';

  @override
  String get ai_feedback_no_oral_layout =>
      'No oral structures visible for analysis.';

  @override
  String get ai_feedback_no_derm_abnormalities =>
      'No dermatological abnormalities detected based on visual evidence.';

  @override
  String get ai_feedback_invalid_gastro =>
      'INVALID_CONTEXT: Image does not appear to be gastrointestinal output.';

  @override
  String get ai_feedback_invalid_lab =>
      'INVALID_CONTEXT: Image is not a lab report.';

  @override
  String get ai_feedback_lab_disclaimer =>
      'Interpretation is based on visible text. Verify with original document.';

  @override
  String get ai_feedback_eyes_not_visible => 'Eyes not fully visible.';

  @override
  String get ai_feedback_inconclusive_angle => 'Inconclusive visual angle.';

  @override
  String get pet_module_dentistry => 'Oral Health (Teeth & Gums)';

  @override
  String get pet_module_dermatology => 'Skin, Coat & Wounds';

  @override
  String get pet_module_gastro => 'Stool & Digestion';

  @override
  String get pet_module_lab => 'Lab Report Reading';

  @override
  String get pet_module_nutrition => 'Labels';

  @override
  String get pet_module_ophthalmology => 'Ophthalmology (Eyes)';

  @override
  String get pet_module_physique => 'Body Condition & Weight';

  @override
  String get pet_module_nutrition_programs =>
      'Label Analysis, Nutritional Table';

  @override
  String get pet_module_vocal => 'Vocal';

  @override
  String get pet_module_vocal_programs => 'Barks, Meows, Coughs, Breathing';

  @override
  String get pet_module_behavior => 'Behavior';

  @override
  String get pet_module_behavior_programs => 'Breed, Posture, Anxiety, Tremors';

  @override
  String get pet_module_plant => 'Plants';

  @override
  String get pet_module_plant_programs => 'Toxic Plant Identification';

  @override
  String get pet_module_food_bowl => 'Food Bowl';

  @override
  String get action_record_video_audio => 'Record Audio/Video';

  @override
  String get action_select_audio => 'Select Audio';

  @override
  String get action_upload_video_audio => 'Upload File';

  @override
  String get pet_mode_my_pet => 'My Pet';

  @override
  String get pet_mode_friend => 'Friend Pet';

  @override
  String get pet_label_tutor => 'Tutor Name';

  @override
  String get pet_hint_select_friend => 'Select';

  @override
  String get pet_new_friend_option => 'New Friend';

  @override
  String get pet_friend_list_label => 'Friend List';

  @override
  String get pet_error_fill_friend_fields => 'Fill all.';

  @override
  String pet_result_title_my_pet(Object name) {
    return 'My Pet: $name';
  }

  @override
  String pet_result_title_friend_pet(Object name, Object tutor) {
    return 'Friend Pet: $name (Tutor: $tutor)';
  }

  @override
  String get pet_action_edit_friend => 'Edit Friend';

  @override
  String get pet_action_delete_friend => 'Delete Friend';

  @override
  String get pet_msg_confirm_delete_friend =>
      'Are you sure you want to delete this friend?';

  @override
  String get pet_msg_friend_updated => 'Friend updated successfully!';

  @override
  String get pet_msg_friend_deleted => 'Friend deleted successfully!';

  @override
  String get pet_dialog_edit_title => 'Edit Friend Pet';

  @override
  String get pet_plant_toxic => 'TOXIC ⚠️';

  @override
  String get pet_plant_safe => 'SAFE ✅';

  @override
  String get pet_msg_confirm_delete_entry =>
      'Are you sure you want to delete this analysis?';

  @override
  String get pet_event_type_activity => 'Activity';

  @override
  String get health_plan_label_card_number => 'Card Number';

  @override
  String get pet_analysis_visual_title => 'Visual Analysis';

  @override
  String get pet_label_whatsapp => 'WhatsApp';

  @override
  String get label_photo => 'Photo';

  @override
  String get label_gallery => 'Gallery';

  @override
  String get label_video => 'Video';

  @override
  String get label_sounds => 'Sounds';

  @override
  String get label_vocal => 'Vocalization';

  @override
  String get pet_journal_recording => 'Recording journal...';

  @override
  String get pet_journal_audio_saved => 'Audio saved successfully';

  @override
  String get pet_journal_photo_saved => 'Photo saved successfully';

  @override
  String get pet_journal_video_saved => 'Video saved successfully';

  @override
  String get error_file_too_large => 'File too large';

  @override
  String get pet_journal_searching_address => 'Searching address...';

  @override
  String get pet_journal_address_not_found => 'Address not found';

  @override
  String get pet_journal_report_action => 'Report';

  @override
  String get pet_journal_question => 'What happened?';

  @override
  String get pet_journal_hint_text => 'Write here...';

  @override
  String get pet_journal_register_button => 'Register';

  @override
  String get help_guide_title => 'Help Guide';

  @override
  String get btn_got_it => 'Got it';

  @override
  String get map_alert_title => 'Map Alert';

  @override
  String get map_type_normal => 'Normal';

  @override
  String get map_type_satellite => 'Satellite';

  @override
  String get common_delete_confirm_title => 'Confirm Delete';

  @override
  String get common_delete_confirm_message =>
      'Are you sure you want to delete?';

  @override
  String get pet_profile_title_simple => 'Profile';

  @override
  String get pet_action_save_profile_simple => 'Save';

  @override
  String get funeral_save_success => 'Saved!';

  @override
  String get health_plan_saved_success => 'Health plan saved!';

  @override
  String pet_age_years(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get keywordFriend => 'Friend';

  @override
  String get keywordGuest => 'Guest';

  @override
  String get pet_agenda_view_calendar => 'View Calendar';

  @override
  String get pet_module_dentistry_programs =>
      'Tartar, Gingivitis, Broken Teeth';

  @override
  String get pet_module_dermatology_programs =>
      'Alopecia, Dermatitis, Wounds, Parasites';

  @override
  String get pet_module_gastro_programs =>
      'Consistency, Color, Parasites, Blood';

  @override
  String get pet_module_ophthalmology_programs =>
      'Secretion, Redness, Cataracts, Spots';

  @override
  String get pet_module_otology_programs => 'Wax, Itching, Odor, Redness';

  @override
  String get pet_module_physique_programs => 'Body Score, Muscle Mass, Obesity';

  @override
  String get pet_module_lab_programs => 'CBC, Biochemistry, Urine, Stool';

  @override
  String get pet_module_food_bowl_programs => 'Kibble Quality, Natural Food';

  @override
  String get pet_journal_audio_saved_success => 'Audio saved!';

  @override
  String get pet_journal_photo_saved_success => 'Photo saved!';

  @override
  String get pet_journal_video_saved_success => 'Video saved!';

  @override
  String get funeral_save_success_simple => 'Funeral saved!';

  @override
  String get health_plan_saved_success_simple => 'Health plan saved!';

  @override
  String get pet_module_ears => 'Ears';

  @override
  String get pet_label_size => 'Size';

  @override
  String get pet_size_small => 'Small';

  @override
  String get pet_size_medium => 'Medium';

  @override
  String get pet_size_large => 'Large';

  @override
  String get pet_label_estimated_weight => 'Est. Weight';

  @override
  String get pet_weight_unit => 'kg';

  @override
  String get pet_label_neutered => 'Neutered';

  @override
  String get pet_clinical_title => 'Clinical Conditions';

  @override
  String get pet_label_allergies => 'Allergies';

  @override
  String get pet_label_chronic => 'Chronic Conditions';

  @override
  String get pet_label_disabilities => 'Disabilities';

  @override
  String get pet_label_observations => 'Notes';

  @override
  String get pet_id_external_title => 'External ID';

  @override
  String get pet_label_microchip => 'Microchip';

  @override
  String get pet_label_registry => 'Registry ID';

  @override
  String get pet_label_qrcode => 'QR Code';

  @override
  String get pet_qrcode_future => 'Coming Soon';

  @override
  String get pet_plans_title => 'Plans';

  @override
  String get pet_action_manage_health_plan => 'Manage Health Plan';

  @override
  String get health_plan_title => 'Health Plan';

  @override
  String get health_plan_section_identification => '1. Identification';

  @override
  String get health_plan_section_coverages => '2. Coverages';

  @override
  String get health_plan_section_limits => '3. Rules';

  @override
  String get health_plan_section_support => '4. Support';

  @override
  String get health_plan_action_save => 'SAVE';

  @override
  String get health_plan_label_operator => 'Operator';

  @override
  String get health_plan_label_plan_name => 'Name';

  @override
  String get health_plan_label_holder_name => 'Holder';

  @override
  String get health_plan_label_grace_period => 'Grace Period';

  @override
  String get health_plan_label_annual_limit => 'Limit';

  @override
  String get health_plan_label_copay => 'Copay';

  @override
  String get health_plan_label_reimburse => 'Reimburse';

  @override
  String get health_plan_label_deductible => 'Deductible';

  @override
  String get health_plan_label_main_clinic => 'Clinic';

  @override
  String get health_plan_label_city => 'City';

  @override
  String get health_plan_label_24h => '24h';

  @override
  String get health_plan_label_phone => 'Phone';

  @override
  String get health_plan_label_whatsapp => 'WhatsApp';

  @override
  String get health_plan_label_email => 'Email';

  @override
  String get health_cov_consultations => 'Consultations';

  @override
  String get health_cov_vaccines => 'Vaccines';

  @override
  String get health_cov_lab_exams => 'Lab Exams';

  @override
  String get health_cov_imaging => 'Imaging';

  @override
  String get health_cov_surgery => 'Surgery';

  @override
  String get health_cov_hospitalization => 'Hospitalization';

  @override
  String get health_cov_emergency => 'Emergency';

  @override
  String get health_cov_pre_existing => 'Pre-existing';

  @override
  String get health_cov_dentistry => 'Dentistry';

  @override
  String get health_cov_physiotherapy => 'Physio';

  @override
  String get pet_db_sync_error => 'Sync Error';

  @override
  String get pet_action_manage_funeral_plan => 'Funeral';

  @override
  String get funeral_plan_title => 'Funeral Plan';

  @override
  String get funeral_section_identity => '1. Identification';

  @override
  String get funeral_section_services => '2. Services';

  @override
  String get funeral_section_rules => '3. Rules';

  @override
  String get funeral_section_emergency => '4. EMERGENCY';

  @override
  String get funeral_label_company => 'Company';

  @override
  String get funeral_label_plan_name => 'Plan';

  @override
  String get funeral_label_contract => 'Contract';

  @override
  String get funeral_label_start_date => 'Start';

  @override
  String get funeral_label_status => 'Status';

  @override
  String get funeral_label_grace_period => 'Grace Period';

  @override
  String get funeral_label_max_weight => 'Max Weight';

  @override
  String get funeral_label_24h => '24h';

  @override
  String get funeral_label_phone => 'Phone';

  @override
  String get funeral_label_whatsapp => 'WhatsApp';

  @override
  String get funeral_label_value => 'Value';

  @override
  String get funeral_label_extra_fees => 'Fees';

  @override
  String get funeral_svc_removal => 'Removal';

  @override
  String get funeral_svc_viewing => 'Viewing';

  @override
  String get funeral_svc_cremation_ind => 'Cremation Ind.';

  @override
  String get funeral_svc_cremation_col => 'Cremation Col.';

  @override
  String get funeral_svc_burial => 'Burial';

  @override
  String get funeral_svc_urn => 'Urn';

  @override
  String get funeral_svc_ashes => 'Ashes';

  @override
  String get funeral_svc_certificate => 'Certificate';

  @override
  String get funeral_action_call_emergency => 'EMERGENCY';

  @override
  String get funeral_action_save => 'SAVE';

  @override
  String get pet_action_analyses => 'Analyses';

  @override
  String get pet_action_health => 'Health';

  @override
  String get pet_action_agenda => 'Agenda';

  @override
  String get pet_history_button => 'History';

  @override
  String ai_assistant_title(Object name) {
    return 'AI $name';
  }

  @override
  String get ai_input_hint => 'Ask here...';

  @override
  String get ai_listening => 'Listening...';

  @override
  String get ai_error_mic => 'Mic denied';

  @override
  String get ai_thinking => 'Thinking...';

  @override
  String pet_age_months(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get pet_age_estimate_label => 'Est. Age:';

  @override
  String get pet_event_type_food => 'Food';

  @override
  String get pet_event_type_health => 'Health';

  @override
  String get pet_event_type_weight => 'Weight';

  @override
  String get pet_event_type_hygiene => 'Hygiene';

  @override
  String get pet_event_type_other => 'Other';

  @override
  String pet_agenda_coming_soon(Object name) {
    return 'Agenda Module for $name';
  }

  @override
  String get pet_medical_history_empty => 'No medical history.';

  @override
  String get pet_share_not_implemented => 'Coming soon.';

  @override
  String get pet_ai_brain_not_ready => 'AI loading...';

  @override
  String pet_ai_connection_error(Object error) {
    return 'AI Error: $error';
  }

  @override
  String get pet_ai_trouble_thinking => 'Trouble processing.';

  @override
  String get pet_stt_not_available => 'STT unavailable';

  @override
  String pet_stt_error(Object error) {
    return 'STT Error: $error';
  }

  @override
  String get pet_entry_deleted => 'Deleted';

  @override
  String pet_error_history_load(Object error) {
    return 'History Error: $error';
  }

  @override
  String pet_ai_greeting(Object name) {
    return 'Hi! I am $name\'s AI.';
  }

  @override
  String get pet_event_food => 'Food';

  @override
  String get pet_event_health => 'Health';

  @override
  String get pet_event_weight => 'Weight';

  @override
  String get pet_event_walk => 'Walk';

  @override
  String get pet_event_hygiene => 'Bath';

  @override
  String get pet_event_behavior => 'Behavior';

  @override
  String get pet_event_medication => 'Meds';

  @override
  String get pet_event_note => 'Note';

  @override
  String get pet_ai_thinking_status => 'AI Thinking...';

  @override
  String get pet_agenda_title => 'Agenda';

  @override
  String pet_agenda_title_dynamic(String petName) {
    return 'Agenda: $petName';
  }

  @override
  String pet_walk_title_dynamic(String petName) {
    return 'Passeio: $petName';
  }

  @override
  String get pet_agenda_empty => 'Empty Agenda';

  @override
  String pet_agenda_add_event_dynamic(Object petName) {
    return 'Event for $petName';
  }

  @override
  String get pet_agenda_today => 'Today';

  @override
  String get pet_agenda_yesterday => 'Yesterday';

  @override
  String get pet_agenda_select_type => 'Type';

  @override
  String get pet_agenda_event_date => 'Date';

  @override
  String get pet_agenda_event_time => 'Time';

  @override
  String get pet_agenda_notes_hint => 'Notes';

  @override
  String get pet_agenda_save => 'Save';

  @override
  String pet_journal_add_event(Object petName) {
    return 'Journal $petName';
  }

  @override
  String get pet_journal_placeholder => 'Describe...';

  @override
  String get pet_journal_register => 'Register';

  @override
  String get label_friend_name => 'Friend';

  @override
  String get label_tutor_name => 'Tutor';

  @override
  String get ai_simulating_analysis => 'Analyzing...';

  @override
  String get pet_journal_location_loading => 'GPS...';

  @override
  String get pet_journal_location_captured => 'Location saved';

  @override
  String get pet_journal_audio_recording => 'Recording...';

  @override
  String get ai_audio_analysis_cough_detected => 'Cough detected.';

  @override
  String get ai_suggest_health_category => 'Health?';

  @override
  String get pet_journal_location_name_simulated => 'Simulated Loc';

  @override
  String get journal_guide_title => 'AI Journal';

  @override
  String get journal_guide_voice => 'Speak and AI organizes.';

  @override
  String get journal_guide_camera => 'Analyze photos.';

  @override
  String get journal_guide_audio => 'Record clinical sounds.';

  @override
  String get journal_guide_location => 'Log location.';

  @override
  String get common_ok => 'OK';

  @override
  String get pet_journal_analyzed_by_nano => 'Nano Banana Analysis';

  @override
  String get pet_journal_social_context => 'Social Context';

  @override
  String get journal_guide_unlock_hint => 'Start reporting.';

  @override
  String get pet_journal_mic_permission_denied => 'Mic denied.';

  @override
  String get label_relate => 'Report';

  @override
  String get label_place => 'Place';

  @override
  String get label_audio => 'Audio';

  @override
  String get label_alert => 'Alert';

  @override
  String get alert_poison => 'Poison';

  @override
  String get alert_dog_loose => 'Angry Dog';

  @override
  String get alert_risk_area => 'Danger';

  @override
  String get alert_noise => 'Noise';

  @override
  String error_gps(Object error) {
    return 'GPS: $error';
  }

  @override
  String get gps_error_snack => 'GPS Error.';

  @override
  String get map_type_hybrid => 'Hybrid';

  @override
  String get map_type_terrain => 'Terrain';

  @override
  String get label_map_type => 'Map';

  @override
  String get map_alert_dog => 'Angry Dog';

  @override
  String get map_alert_poison => 'Poison';

  @override
  String get map_alert_noise => 'Noise';

  @override
  String get map_alert_risk => 'Risk';

  @override
  String get map_alert_success => 'Success!';

  @override
  String get pet_agenda_tab_scheduled => 'Appointments';

  @override
  String get pet_agenda_tab_timeline => 'History & Walks';

  @override
  String get map_alert_description_user => 'By user';

  @override
  String get pet_journal_gps_error => 'GPS Error';

  @override
  String get pet_journal_loading_gps => 'GPS...';

  @override
  String get pet_journal_location_unknown => 'Unknown';

  @override
  String get pet_journal_location_approx => 'Approximate';

  @override
  String pet_journal_file_selected(Object name) {
    return 'File: $name';
  }

  @override
  String pet_journal_file_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get pet_journal_help_title => 'Help';

  @override
  String get pet_journal_help_photo_title => 'Photos';

  @override
  String get pet_journal_help_photo_desc => 'Send photos.';

  @override
  String get pet_journal_help_audio_title => 'Audio';

  @override
  String get pet_journal_help_audio_desc => 'Record sounds.';

  @override
  String get pet_journal_help_map_title => 'Map';

  @override
  String get pet_journal_help_map_desc => 'Auto location.';

  @override
  String get pet_journal_help_notes_title => 'Notes';

  @override
  String get pet_journal_help_notes_desc => 'Describe everything.';

  @override
  String get pet_journal_help_videos_title => 'Video';

  @override
  String get pet_journal_help_videos_desc => 'Coming soon.';

  @override
  String get pet_journal_help_ai_title => 'AI';

  @override
  String get pet_journal_help_ai_desc => 'AI Clinical Opinion.';

  @override
  String pet_error_ai_analysis_failed(Object error) {
    return 'AI Error: $error';
  }

  @override
  String pet_error_repository_failure(Object status) {
    return 'Failure: $status';
  }

  @override
  String pet_error_saving_event(Object error) {
    return 'Save Error: $error';
  }

  @override
  String pet_agenda_summary_format(int count) {
    return '$count events';
  }

  @override
  String get common_delete => 'Delete';

  @override
  String get pet_error_delete_event => 'Delete Error';

  @override
  String get pet_label_address => 'Address';

  @override
  String get pet_label_ai_summary => 'AI Summary';

  @override
  String get pet_analysis_data_not_found => 'No data.';

  @override
  String get pet_logic_keywords_health => 'vomit,diarrhea,cough';

  @override
  String get pet_ai_language => 'en_US';

  @override
  String get map_gps_disabled => 'Enable GPS.';

  @override
  String get map_permission_denied => 'No permission.';

  @override
  String get map_permission_denied_forever => 'Open settings.';

  @override
  String map_error_location(Object error) {
    return 'Error: $error';
  }

  @override
  String get map_title_pet_location => 'Location';

  @override
  String get action_open_settings => 'Settings';

  @override
  String get map_sync_satellites => 'Satellites...';

  @override
  String get pet_journal_audio_processing => 'Processing...';

  @override
  String get pet_journal_audio_error_file_not_found => 'No audio.';

  @override
  String get pet_journal_audio_error_generic => 'No result.';

  @override
  String get pet_journal_audio_pending => 'Pending.';

  @override
  String get pet_journal_video_processing => 'Analyzing...';

  @override
  String get pet_journal_video_error => 'Video Error.';

  @override
  String get error_video_too_long => 'Max 60s';

  @override
  String get btn_scan_image => 'Scan Image';

  @override
  String get generic_analyzing => 'Analyzing...';

  @override
  String get pet_error_image_not_found => 'Image not found.';

  @override
  String get btn_go => 'Go';

  @override
  String get pet_created_at_label => 'Created at';

  @override
  String get pet_initial_assessment => 'Initial Assessment';

  @override
  String get pet_hint_select_type => 'Select Type';

  @override
  String get pet_label_info => 'Info';

  @override
  String get pet_type_profile => 'Profile';

  @override
  String get pet_action_profile_short => 'Profile';

  @override
  String get pet_action_walk => 'Walk';

  @override
  String get pet_profile_title => 'Pet Profile';

  @override
  String get pet_management_title => 'Management';

  @override
  String get pet_label_health_plan => 'Health Plan';

  @override
  String get pet_label_funeral_plan => 'Funeral Plan';

  @override
  String get pet_label_weight => 'Weight';

  @override
  String get pet_label_birth_date => 'Birth Date';

  @override
  String get pet_btn_add_metric => 'Add Metric';

  @override
  String get pet_agenda_add_event => 'Add Event';

  @override
  String get error_unexpected_title => 'Unexpected Error';

  @override
  String get error_unexpected_message => 'Restart the app.';

  @override
  String get error_try_recover => 'Recover';

  @override
  String get pet_profile_save_success => 'Profile saved';

  @override
  String get pet_action_save_profile => 'SAVE PROFILE';

  @override
  String get pet_not_found => 'Pet not found';

  @override
  String pet_analyses_title(Object name) {
    return 'Analyses: $name';
  }

  @override
  String pet_profile_title_dynamic(Object name) {
    return 'Profile: $name';
  }

  @override
  String pet_health_title(Object name) {
    return 'Health: $name';
  }

  @override
  String pet_health_plan_title(Object name) {
    return 'Health Plan: $name';
  }

  @override
  String pet_funeral_plan_title(Object name) {
    return 'Funeral Plan: $name';
  }

  @override
  String pet_analysis_title(Object name) {
    return 'Analysis: $name';
  }

  @override
  String get label_file => 'File';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get pet_agenda_dialog_title => 'Agenda';

  @override
  String get pet_agenda_dialog_walk => 'Walk';

  @override
  String get pet_agenda_dialog_appointment => 'Schedule';

  @override
  String get pet_appointment_screen_title => 'New Appointment';

  @override
  String get pet_appointment_label_professional => 'Professional/Place';

  @override
  String get pet_appointment_save_success => 'Appointment scheduled!';

  @override
  String get pet_appointment_type_vaccine => 'Vaccine';

  @override
  String get pet_appointment_type_consultation => 'Consultation';

  @override
  String get pet_appointment_type_grooming => 'Grooming';

  @override
  String get pet_appointment_type_exam => 'Exam';

  @override
  String get pet_scheduled_list_title => 'Scheduled';

  @override
  String get pet_scheduled_empty => 'No future appointments.';

  @override
  String get pet_notification_label => 'Notify in Advance';

  @override
  String get pet_notification_1h => '1 hour before';

  @override
  String get pet_notification_2h => '2 hours before';

  @override
  String get pet_notification_1d => '1 day before';

  @override
  String get pet_notification_2d => '2 days before';

  @override
  String get pet_notification_1w => '1 week before';

  @override
  String get pet_notification_none => 'No notification';

  @override
  String get pet_delete_confirmation_title =>
      'Are you sure you want to delete?';

  @override
  String get pet_appointment_tab_data => 'Appointment';

  @override
  String get pet_appointment_tab_partner => 'Partner Data';

  @override
  String get common_save => 'Save';

  @override
  String get pdf_footer_text =>
      '© 2026 ScanNut Multiverso Digital | contato@multiversodigital.com.br';

  @override
  String get pdf_page_label => 'Page';

  @override
  String get pdf_of_label => 'of';
}
