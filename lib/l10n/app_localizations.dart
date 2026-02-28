import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+'**
  String get app_title;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_title;

  /// No description provided for @login_title_plus.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+'**
  String get login_title_plus;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your digital wellness universe'**
  String get login_subtitle;

  /// No description provided for @login_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get login_email_label;

  /// No description provided for @login_email_hint.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get login_email_hint;

  /// No description provided for @login_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password_label;

  /// No description provided for @login_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password_hint;

  /// No description provided for @login_confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get login_confirm_password_hint;

  /// No description provided for @login_button_enter.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login_button_enter;

  /// No description provided for @login_button_biometrics.
  ///
  /// In en, this message translates to:
  /// **'Log In with Biometrics'**
  String get login_button_biometrics;

  /// No description provided for @login_keep_me.
  ///
  /// In en, this message translates to:
  /// **'Keep me logged in'**
  String get login_keep_me;

  /// No description provided for @login_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get login_no_account;

  /// No description provided for @login_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get login_sign_up;

  /// No description provided for @biometric_success.
  ///
  /// In en, this message translates to:
  /// **'Biometrics verified successfully'**
  String get biometric_success;

  /// No description provided for @login_error_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get login_error_credentials;

  /// No description provided for @error_password_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get error_password_short;

  /// No description provided for @error_password_weak.
  ///
  /// In en, this message translates to:
  /// **'Needs uppercase, number, and special char'**
  String get error_password_weak;

  /// No description provided for @error_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get error_password_mismatch;

  /// No description provided for @pwd_help_title.
  ///
  /// In en, this message translates to:
  /// **'Password Rules'**
  String get pwd_help_title;

  /// No description provided for @pwd_rule_length.
  ///
  /// In en, this message translates to:
  /// **'Minimum of 8 characters'**
  String get pwd_rule_length;

  /// No description provided for @pwd_rule_uppercase.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get pwd_rule_uppercase;

  /// No description provided for @pwd_rule_number.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get pwd_rule_number;

  /// No description provided for @pwd_rule_special.
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get pwd_rule_special;

  /// No description provided for @biometric_error.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get biometric_error;

  /// No description provided for @biometric_reason.
  ///
  /// In en, this message translates to:
  /// **'Scan to authenticate'**
  String get biometric_reason;

  /// No description provided for @biometric_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometric_tooltip;

  /// No description provided for @common_copyright.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+ © 2026 Multiverso Digital'**
  String get common_copyright;

  /// No description provided for @tabFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get tabFood;

  /// No description provided for @tabPlants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get tabPlants;

  /// No description provided for @tabPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get tabPets;

  /// No description provided for @splashPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by AI Vision'**
  String get splashPoweredBy;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_title;

  /// No description provided for @home_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Home'**
  String get home_welcome;

  /// No description provided for @onboarding_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ScanNut+'**
  String get onboarding_title;

  /// No description provided for @onboarding_welcome.
  ///
  /// In en, this message translates to:
  /// **'Your AI companion for food, plants, and pets.'**
  String get onboarding_welcome;

  /// No description provided for @onboarding_button_start.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_button_start;

  /// No description provided for @onboarding_tou_title.
  ///
  /// In en, this message translates to:
  /// **'Analytical Terms of Use'**
  String get onboarding_tou_title;

  /// No description provided for @onboarding_tou_body.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+ provides you with an Artificial Intelligence-based Veterinary Specialist trained at a high cost.\n\n⚠️ Attention:\nNo image analysis is free. Processing each photo generates real operation costs. Therefore, we DO NOT pre-analyze images to save traffic and speed up response times. It is entirely your responsibility to be accurate in the selected category. Out-of-context photographs will generate absurd or out-of-context reports.\n\nRemember: AI is just a virtual assistant and can make mistakes. The generated report does not replace, under any circumstances, a face-to-face evaluation by a Veterinarian or Specialist. Always consult a trusted professional to evaluate exams.'**
  String get onboarding_tou_body;

  /// No description provided for @onboarding_tou_accept.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get onboarding_tou_accept;

  /// No description provided for @debug_nav_login_forced.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATE_TO_LOGIN_DEBUG'**
  String get debug_nav_login_forced;

  /// No description provided for @debug_nav_onboarding.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATE_TO_ONBOARDING'**
  String get debug_nav_onboarding;

  /// No description provided for @debug_nav_login_no_session.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATE_TO_LOGIN_NO_SESSION'**
  String get debug_nav_login_no_session;

  /// No description provided for @debug_nav_home_bio_success.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATE_TO_HOME_BIO_SUCCESS'**
  String get debug_nav_home_bio_success;

  /// No description provided for @debug_nav_login_bio_fail.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATE_TO_LOGIN_BIO_FAIL'**
  String get debug_nav_login_bio_fail;

  /// No description provided for @debug_nav_home_session_active.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATE_TO_HOME_SESSION_ACTIVE'**
  String get debug_nav_home_session_active;

  /// No description provided for @auth_required_fallback.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get auth_required_fallback;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get login_success;

  /// No description provided for @signup_success.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get signup_success;

  /// No description provided for @home_welcome_user.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String home_welcome_user(Object name);

  /// No description provided for @tab_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get tab_food;

  /// No description provided for @tab_plant.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get tab_plant;

  /// No description provided for @tab_pet.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get tab_pet;

  /// No description provided for @common_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get common_logout;

  /// No description provided for @logout_success.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logout_success;

  /// No description provided for @food_scan_title.
  ///
  /// In en, this message translates to:
  /// **'Food Scanner'**
  String get food_scan_title;

  /// No description provided for @food_analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing nutritional content...'**
  String get food_analyzing;

  /// No description provided for @food_analysis_success.
  ///
  /// In en, this message translates to:
  /// **'Analysis Complete'**
  String get food_analysis_success;

  /// No description provided for @food_calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get food_calories;

  /// No description provided for @food_protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get food_protein;

  /// No description provided for @food_carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get food_carbs;

  /// No description provided for @food_fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get food_fat;

  /// No description provided for @food_btn_scan.
  ///
  /// In en, this message translates to:
  /// **'Scan Food'**
  String get food_btn_scan;

  /// No description provided for @food_btn_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get food_btn_gallery;

  /// No description provided for @food_empty_history.
  ///
  /// In en, this message translates to:
  /// **'No food scans yet.'**
  String get food_empty_history;

  /// No description provided for @domain_pets_navigation.
  ///
  /// In en, this message translates to:
  /// **'Pets Navigation'**
  String get domain_pets_navigation;

  /// No description provided for @pets_navigation_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pet Directions Assistant'**
  String get pets_navigation_subtitle;

  /// No description provided for @menu_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menu_profile;

  /// No description provided for @menu_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menu_settings;

  /// No description provided for @menu_help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get menu_help;

  /// No description provided for @stub_map_module.
  ///
  /// In en, this message translates to:
  /// **'Map Module Coming Soon'**
  String get stub_map_module;

  /// No description provided for @user_demo_name.
  ///
  /// In en, this message translates to:
  /// **'User Demo'**
  String get user_demo_name;

  /// No description provided for @user_default_name.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user_default_name;

  /// No description provided for @food_mock_grilled_chicken.
  ///
  /// In en, this message translates to:
  /// **'Grilled Chicken Salad'**
  String get food_mock_grilled_chicken;

  /// No description provided for @food_key_calories.
  ///
  /// In en, this message translates to:
  /// **'calories'**
  String get food_key_calories;

  /// No description provided for @food_key_protein.
  ///
  /// In en, this message translates to:
  /// **'protein'**
  String get food_key_protein;

  /// No description provided for @food_key_carbs.
  ///
  /// In en, this message translates to:
  /// **'carbs'**
  String get food_key_carbs;

  /// No description provided for @food_key_fat.
  ///
  /// In en, this message translates to:
  /// **'fat'**
  String get food_key_fat;

  /// No description provided for @food_key_name.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get food_key_name;

  /// No description provided for @test_food.
  ///
  /// In en, this message translates to:
  /// **'Test: Food'**
  String get test_food;

  /// No description provided for @test_plants.
  ///
  /// In en, this message translates to:
  /// **'Test: Plants'**
  String get test_plants;

  /// No description provided for @test_pets.
  ///
  /// In en, this message translates to:
  /// **'Test: Pets'**
  String get test_pets;

  /// No description provided for @test_navigation.
  ///
  /// In en, this message translates to:
  /// **'Test: Navigation'**
  String get test_navigation;

  /// No description provided for @debug_gallery_title.
  ///
  /// In en, this message translates to:
  /// **'Color Gallery'**
  String get debug_gallery_title;

  /// No description provided for @auth_biometric_reason.
  ///
  /// In en, this message translates to:
  /// **'Scan to verify your identity'**
  String get auth_biometric_reason;

  /// No description provided for @app_name_plus.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+'**
  String get app_name_plus;

  /// No description provided for @pdf_copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 ScanNut+ Multiverso Digital'**
  String get pdf_copyright;

  /// No description provided for @pdf_page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pdf_page;

  /// No description provided for @dev_name.
  ///
  /// In en, this message translates to:
  /// **'Multiverso Digital'**
  String get dev_name;

  /// No description provided for @dev_email.
  ///
  /// In en, this message translates to:
  /// **'contato@multiversodigital.com.br'**
  String get dev_email;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about_title;

  /// No description provided for @version_label.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version_label;

  /// No description provided for @contact_label.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact_label;

  /// No description provided for @copyright_label.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Multiverso Digital'**
  String get copyright_label;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profile_email_label;

  /// No description provided for @profile_biometric_enable.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Auth'**
  String get profile_biometric_enable;

  /// No description provided for @common_confirm_exit.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to exit?'**
  String get common_confirm_exit;

  /// No description provided for @profile_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profile_change_password;

  /// No description provided for @password_current.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get password_current;

  /// No description provided for @password_new.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get password_new;

  /// No description provided for @password_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get password_confirm;

  /// No description provided for @password_save.
  ///
  /// In en, this message translates to:
  /// **'Save New Password'**
  String get password_save;

  /// No description provided for @password_match_error.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_match_error;

  /// No description provided for @password_success.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get password_success;

  /// No description provided for @default_user_name.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get default_user_name;

  /// No description provided for @pet_capture_title.
  ///
  /// In en, this message translates to:
  /// **'Pet Capture'**
  String get pet_capture_title;

  /// No description provided for @action_take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get action_take_photo;

  /// No description provided for @action_upload_gallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get action_upload_gallery;

  /// No description provided for @species_label.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species_label;

  /// No description provided for @species_dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get species_dog;

  /// No description provided for @species_cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get species_cat;

  /// No description provided for @image_type_label.
  ///
  /// In en, this message translates to:
  /// **'Image Type'**
  String get image_type_label;

  /// No description provided for @type_pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get type_pet;

  /// No description provided for @type_label.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get type_label;

  /// No description provided for @pet_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Pet saved successfully'**
  String get pet_saved_success;

  /// No description provided for @label_analysis_pending.
  ///
  /// In en, this message translates to:
  /// **'Label analysis coming soon'**
  String get label_analysis_pending;

  /// No description provided for @action_retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get action_retake;

  /// No description provided for @label_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get label_name;

  /// No description provided for @label_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get label_email;

  /// No description provided for @hint_user_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get hint_user_name;

  /// No description provided for @section_account_data.
  ///
  /// In en, this message translates to:
  /// **'Account Data'**
  String get section_account_data;

  /// No description provided for @help_title.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_title;

  /// No description provided for @help_how_to_use.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get help_how_to_use;

  /// No description provided for @help_pet_scan_tip.
  ///
  /// In en, this message translates to:
  /// **'Scan your pet or food labels for nutritional analysis.'**
  String get help_pet_scan_tip;

  /// No description provided for @help_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get help_privacy_policy;

  /// No description provided for @help_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get help_contact_support;

  /// No description provided for @help_dev_info.
  ///
  /// In en, this message translates to:
  /// **'Developed by Multiverso Digital'**
  String get help_dev_info;

  /// No description provided for @help_privacy_content.
  ///
  /// In en, this message translates to:
  /// **'Your data is processed locally whenever possible. We respect your privacy.'**
  String get help_privacy_content;

  /// No description provided for @help_email_subject.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+ Support'**
  String get help_email_subject;

  /// No description provided for @help_story_title.
  ///
  /// In en, this message translates to:
  /// **'Our Story'**
  String get help_story_title;

  /// No description provided for @help_origin_story.
  ///
  /// In en, this message translates to:
  /// **'The name of this app is a tribute to my pet, Nut. My idea was to create a tool for complete management of his life, from routine organization to the creation of healthy menus. In daily life, ScanNut helps me record every occurrence. For stool, urine, and blood tests, I use AI to get initial insights through image analysis — a technological support I always share with the vet. Additionally, I included a plant guide to identify toxic species and ensure his safety. Thinking about my own health, I added the Food Scan to monitor calories, vitamins, and generate meal plans with shopping lists. I feel that, now, the app is complete for both of us.'**
  String get help_origin_story;

  /// No description provided for @help_analysis_guide_title.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Guide'**
  String get help_analysis_guide_title;

  /// No description provided for @help_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'This analysis is visual only and does not replace a veterinary evaluation.'**
  String get help_disclaimer;

  /// No description provided for @help_section_pet_title.
  ///
  /// In en, this message translates to:
  /// **'General Pet Analysis'**
  String get help_section_pet_title;

  /// No description provided for @help_section_pet_desc.
  ///
  /// In en, this message translates to:
  /// **'Analyzes species, size estimate, body posture (pain/comfort signs), and environment safety.'**
  String get help_section_pet_desc;

  /// No description provided for @help_section_wound_title.
  ///
  /// In en, this message translates to:
  /// **'Wounds & Injuries'**
  String get help_section_wound_title;

  /// No description provided for @help_section_wound_desc.
  ///
  /// In en, this message translates to:
  /// **'Evaluates size, visual aspect (pus/blood presence), redness, and signs of inflammation.'**
  String get help_section_wound_desc;

  /// No description provided for @help_section_stool_title.
  ///
  /// In en, this message translates to:
  /// **'Stool Analysis'**
  String get help_section_stool_title;

  /// No description provided for @help_section_stool_desc.
  ///
  /// In en, this message translates to:
  /// **'Checks consistency (Bristol scale), color changes, and visible presence of mucus or worms.'**
  String get help_section_stool_desc;

  /// No description provided for @help_section_mouth_title.
  ///
  /// In en, this message translates to:
  /// **'Dental & Mouth'**
  String get help_section_mouth_title;

  /// No description provided for @help_section_mouth_desc.
  ///
  /// In en, this message translates to:
  /// **'Inspects gum color (pale/red), tartar buildup, and broken teeth indicators.'**
  String get help_section_mouth_desc;

  /// No description provided for @help_section_eyes_title.
  ///
  /// In en, this message translates to:
  /// **'Eyes Health'**
  String get help_section_eyes_title;

  /// No description provided for @pet_med_drug_name.
  ///
  /// In en, this message translates to:
  /// **'Drug Name'**
  String get pet_med_drug_name;

  /// No description provided for @pet_med_dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get pet_med_dosage;

  /// No description provided for @pet_med_unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get pet_med_unit;

  /// No description provided for @pet_med_route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get pet_med_route;

  /// No description provided for @pet_med_oral.
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get pet_med_oral;

  /// No description provided for @pet_med_injectable.
  ///
  /// In en, this message translates to:
  /// **'Injectable'**
  String get pet_med_injectable;

  /// No description provided for @pet_med_topical.
  ///
  /// In en, this message translates to:
  /// **'Topical'**
  String get pet_med_topical;

  /// No description provided for @pet_med_drops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get pet_med_drops;

  /// No description provided for @pet_med_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration (Days)'**
  String get pet_med_duration;

  /// No description provided for @pet_med_interval.
  ///
  /// In en, this message translates to:
  /// **'Interval (Hours)'**
  String get pet_med_interval;

  /// No description provided for @pet_med_duration_help.
  ///
  /// In en, this message translates to:
  /// **'How many days will the treatment last?'**
  String get pet_med_duration_help;

  /// No description provided for @pet_med_interval_help.
  ///
  /// In en, this message translates to:
  /// **'Every how many hours should the pet take the dose?'**
  String get pet_med_interval_help;

  /// No description provided for @pet_med_dosage_help.
  ///
  /// In en, this message translates to:
  /// **'Amount to be given per dose?'**
  String get pet_med_dosage_help;

  /// No description provided for @pet_nutrition_history_title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition History'**
  String get pet_nutrition_history_title;

  /// No description provided for @pet_nutrition_empty_history.
  ///
  /// In en, this message translates to:
  /// **'No plans generated yet.'**
  String get pet_nutrition_empty_history;

  /// No description provided for @pet_agenda_event_date_help.
  ///
  /// In en, this message translates to:
  /// **'Treatment start date.'**
  String get pet_agenda_event_date_help;

  /// No description provided for @pet_field_time_help.
  ///
  /// In en, this message translates to:
  /// **'Time of the first dose.'**
  String get pet_field_time_help;

  /// No description provided for @pet_med_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get pet_med_start_date;

  /// No description provided for @pet_med_start_time.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get pet_med_start_time;

  /// No description provided for @pet_med_save.
  ///
  /// In en, this message translates to:
  /// **'Schedule Treatment'**
  String get pet_med_save;

  /// No description provided for @pet_med_take_dose.
  ///
  /// In en, this message translates to:
  /// **'Take Dose'**
  String get pet_med_take_dose;

  /// No description provided for @pet_med_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Drug name is required.'**
  String get pet_med_empty_error;

  /// No description provided for @pet_med_success.
  ///
  /// In en, this message translates to:
  /// **'Medication scheduled successfully!'**
  String get pet_med_success;

  /// No description provided for @pet_med_taken_success.
  ///
  /// In en, this message translates to:
  /// **'Dose recorded successfully!'**
  String get pet_med_taken_success;

  /// No description provided for @help_section_eyes_desc.
  ///
  /// In en, this message translates to:
  /// **'Detects secretion, redness, cloudiness (opacity), and potential irritation signs.'**
  String get help_section_eyes_desc;

  /// No description provided for @help_section_skin_title.
  ///
  /// In en, this message translates to:
  /// **'Skin & Coat'**
  String get help_section_skin_title;

  /// No description provided for @help_section_skin_desc.
  ///
  /// In en, this message translates to:
  /// **'Identifies hair loss patches, redness, flakes, and unusual spots or lumps.'**
  String get help_section_skin_desc;

  /// No description provided for @help_can_do.
  ///
  /// In en, this message translates to:
  /// **'What AI can detect'**
  String get help_can_do;

  /// No description provided for @help_cannot_do.
  ///
  /// In en, this message translates to:
  /// **'Limit: Needs Vet confirmation'**
  String get help_cannot_do;

  /// No description provided for @pet_capture_instructions.
  ///
  /// In en, this message translates to:
  /// **'The AI analyzes images of the pet, wounds, stool, mouth, eyes, and skin. One at a time.'**
  String get pet_capture_instructions;

  /// No description provided for @help_domain_pet_title.
  ///
  /// In en, this message translates to:
  /// **'An exclusive AI for your Pet.'**
  String get help_domain_pet_title;

  /// No description provided for @help_domain_pet_desc.
  ///
  /// In en, this message translates to:
  /// **'Your pet has an exclusive intelligence in ScanNut+! Our AI analyzes all collected data to answer your questions and generate detailed health reports. In addition, you can perform visual image analysis to closely monitor your best friend\'s well-being.\n\nYou can also perform the same analyses for your pet\'s friend.\n\nGive your best friend a voice! With ScanNut+\'s exclusive AI, you can clarify all your doubts and receive health reports based on your pet\'s daily life. Also use our image analysis to understand what photos tell about their health and behavior.\n\nScanNut+ offers a smart assistant dedicated to your pet. It transforms data and photos into health reports and immediate answers to your questions. Everything to ensure your friend is always well cared for.'**
  String get help_domain_pet_desc;

  /// No description provided for @help_domain_food_title.
  ///
  /// In en, this message translates to:
  /// **'Food Domain'**
  String get help_domain_food_title;

  /// No description provided for @help_domain_food_desc.
  ///
  /// In en, this message translates to:
  /// **'Your health management: Food scanning, nutrient counting, and healthy meal plan creation.'**
  String get help_domain_food_desc;

  /// No description provided for @help_domain_plant_title.
  ///
  /// In en, this message translates to:
  /// **'Plant Domain'**
  String get help_domain_plant_title;

  /// No description provided for @help_domain_plant_desc.
  ///
  /// In en, this message translates to:
  /// **'Plant Guide: Identify species in your garden or home and know instantly if they are toxic to your pet, based on real botanical data.'**
  String get help_domain_plant_desc;

  /// No description provided for @pet_capture_info_title.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+ AI Capabilities'**
  String get pet_capture_info_title;

  /// No description provided for @pet_capture_capability_labels.
  ///
  /// In en, this message translates to:
  /// **'Food Label & Ingredient Analysis'**
  String get pet_capture_capability_labels;

  /// No description provided for @pet_capture_capability_exams.
  ///
  /// In en, this message translates to:
  /// **'Clinical Reports & Lab Exams'**
  String get pet_capture_capability_exams;

  /// No description provided for @pet_capture_capability_biometrics.
  ///
  /// In en, this message translates to:
  /// **'Posture & Biometric Monitoring'**
  String get pet_capture_capability_biometrics;

  /// No description provided for @pet_capture_capability_visual.
  ///
  /// In en, this message translates to:
  /// **'Visual Health Inspection'**
  String get pet_capture_capability_visual;

  /// No description provided for @pet_input_name_hint.
  ///
  /// In en, this message translates to:
  /// **'What is the pet\'s name?'**
  String get pet_input_name_hint;

  /// No description provided for @pet_result_status_stable.
  ///
  /// In en, this message translates to:
  /// **'Status: Stable'**
  String get pet_result_status_stable;

  /// No description provided for @pet_result_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Analysis Summary'**
  String get pet_result_summary_title;

  /// No description provided for @pet_result_visual_empty.
  ///
  /// In en, this message translates to:
  /// **'No visual anomalies detected'**
  String get pet_result_visual_empty;

  /// No description provided for @pet_analysis_error_generic.
  ///
  /// In en, this message translates to:
  /// **'We had a slight technical difficulty during the analysis. Please try again. ({error})'**
  String pet_analysis_error_generic(Object error);

  /// No description provided for @pet_urgency_red.
  ///
  /// In en, this message translates to:
  /// **'urgency: red'**
  String get pet_urgency_red;

  /// No description provided for @pet_urgency_immediate.
  ///
  /// In en, this message translates to:
  /// **'immediate attention'**
  String get pet_urgency_immediate;

  /// No description provided for @pet_urgency_critical.
  ///
  /// In en, this message translates to:
  /// **'critical'**
  String get pet_urgency_critical;

  /// No description provided for @pet_urgency_yellow.
  ///
  /// In en, this message translates to:
  /// **'urgency: yellow'**
  String get pet_urgency_yellow;

  /// No description provided for @pet_urgency_monitor.
  ///
  /// In en, this message translates to:
  /// **'monitor'**
  String get pet_urgency_monitor;

  /// No description provided for @pet_status_critical.
  ///
  /// In en, this message translates to:
  /// **'Status: Critical Attention'**
  String get pet_status_critical;

  /// No description provided for @pet_status_monitor.
  ///
  /// In en, this message translates to:
  /// **'Status: Monitor'**
  String get pet_status_monitor;

  /// No description provided for @pet_mock_visual_confirm.
  ///
  /// In en, this message translates to:
  /// **'Visual analysis confirms structure...'**
  String get pet_mock_visual_confirm;

  /// No description provided for @pet_label_pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get pet_label_pet;

  /// No description provided for @pet_section_species.
  ///
  /// In en, this message translates to:
  /// **'Species Identification'**
  String get pet_section_species;

  /// No description provided for @pet_section_health.
  ///
  /// In en, this message translates to:
  /// **'General Health & Behavior'**
  String get pet_section_health;

  /// No description provided for @pet_section_coat.
  ///
  /// In en, this message translates to:
  /// **'General Coat Condition'**
  String get pet_section_coat;

  /// No description provided for @pet_section_skin.
  ///
  /// In en, this message translates to:
  /// **'Skin Appearance'**
  String get pet_section_skin;

  /// No description provided for @pet_action_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pet_action_share;

  /// No description provided for @source_merck.
  ///
  /// In en, this message translates to:
  /// **'Merck Veterinary Manual (MSD Digital 2026)'**
  String get source_merck;

  /// No description provided for @source_scannut.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+ Biometry & Phenotyping Protocol'**
  String get source_scannut;

  /// No description provided for @source_aaha.
  ///
  /// In en, this message translates to:
  /// **'AAHA/WSAVA Physical Exam Guidelines'**
  String get source_aaha;

  /// No description provided for @pet_section_ears.
  ///
  /// In en, this message translates to:
  /// **'Ears'**
  String get pet_section_ears;

  /// No description provided for @pet_section_nose.
  ///
  /// In en, this message translates to:
  /// **'Nose'**
  String get pet_section_nose;

  /// No description provided for @pet_section_eyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get pet_section_eyes;

  /// No description provided for @pet_section_body.
  ///
  /// In en, this message translates to:
  /// **'Body Conditions'**
  String get pet_section_body;

  /// No description provided for @pet_section_issues.
  ///
  /// In en, this message translates to:
  /// **'Potential Issues'**
  String get pet_section_issues;

  /// No description provided for @pet_status_healthy.
  ///
  /// In en, this message translates to:
  /// **'HEALTHY STATUS'**
  String get pet_status_healthy;

  /// No description provided for @pet_status_attention.
  ///
  /// In en, this message translates to:
  /// **'ATTENTION REQUIRED'**
  String get pet_status_attention;

  /// No description provided for @key_green.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get key_green;

  /// No description provided for @key_yellow.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get key_yellow;

  /// No description provided for @key_red.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get key_red;

  /// No description provided for @value_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get value_unknown;

  /// No description provided for @error_database_load.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t access your data right now. How about trying again? ({error})'**
  String error_database_load(String error);

  /// No description provided for @pet_section_mouth.
  ///
  /// In en, this message translates to:
  /// **'Mouth'**
  String get pet_section_mouth;

  /// No description provided for @pet_section_posture.
  ///
  /// In en, this message translates to:
  /// **'Posture'**
  String get pet_section_posture;

  /// No description provided for @pet_section_exams.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get pet_section_exams;

  /// No description provided for @category_feces.
  ///
  /// In en, this message translates to:
  /// **'Stool'**
  String get category_feces;

  /// No description provided for @category_food_label.
  ///
  /// In en, this message translates to:
  /// **'Food Label'**
  String get category_food_label;

  /// No description provided for @pet_type_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get pet_type_general;

  /// No description provided for @category_wound.
  ///
  /// In en, this message translates to:
  /// **'Wound'**
  String get category_wound;

  /// No description provided for @pet_dialog_new_title.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get pet_dialog_new_title;

  /// No description provided for @category_clinical.
  ///
  /// In en, this message translates to:
  /// **'Clinical'**
  String get category_clinical;

  /// No description provided for @category_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get category_lab;

  /// No description provided for @pet_section_general.
  ///
  /// In en, this message translates to:
  /// **'General Analysis'**
  String get pet_section_general;

  /// No description provided for @pet_section_biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get pet_section_biometrics;

  /// No description provided for @pet_section_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get pet_section_weight;

  /// No description provided for @pet_ui_my_pets.
  ///
  /// In en, this message translates to:
  /// **'My Pets'**
  String get pet_ui_my_pets;

  /// No description provided for @pet_my_pets_title.
  ///
  /// In en, this message translates to:
  /// **'My Pets'**
  String get pet_my_pets_title;

  /// No description provided for @pet_no_pets_registered.
  ///
  /// In en, this message translates to:
  /// **'No pets registered yet.'**
  String get pet_no_pets_registered;

  /// No description provided for @pet_dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Pet Dashboard'**
  String get pet_dashboard_title;

  /// No description provided for @pet_action_biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get pet_action_biometrics;

  /// No description provided for @pet_action_history.
  ///
  /// In en, this message translates to:
  /// **'Analysis history'**
  String get pet_action_history;

  /// No description provided for @pet_type_label.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get pet_type_label;

  /// No description provided for @pet_type_wound.
  ///
  /// In en, this message translates to:
  /// **'Wound'**
  String get pet_type_wound;

  /// No description provided for @pet_type_stool.
  ///
  /// In en, this message translates to:
  /// **'Stool'**
  String get pet_type_stool;

  /// No description provided for @pet_type_mouth.
  ///
  /// In en, this message translates to:
  /// **'Mouth'**
  String get pet_type_mouth;

  /// No description provided for @pet_type_eyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get pet_type_eyes;

  /// No description provided for @pet_type_skin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get pet_type_skin;

  /// No description provided for @pet_type_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab Results'**
  String get pet_type_lab;

  /// No description provided for @pet_select_context.
  ///
  /// In en, this message translates to:
  /// **'Select analysis type:'**
  String get pet_select_context;

  /// No description provided for @pet_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get pet_unknown;

  /// No description provided for @pet_analyzing_x.
  ///
  /// In en, this message translates to:
  /// **'Analyzing: {name}'**
  String pet_analyzing_x(String name);

  /// No description provided for @pet_id_format.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}...'**
  String pet_id_format(String id);

  /// No description provided for @pet_section_visual.
  ///
  /// In en, this message translates to:
  /// **'Visual Inspection'**
  String get pet_section_visual;

  /// No description provided for @pet_type_safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get pet_type_safety;

  /// No description provided for @pet_type_new_profile.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get pet_type_new_profile;

  /// No description provided for @pet_waze_title.
  ///
  /// In en, this message translates to:
  /// **'Pet Waze'**
  String get pet_waze_title;

  /// No description provided for @pet_waze_desc.
  ///
  /// In en, this message translates to:
  /// **'Community alerts near you'**
  String get pet_waze_desc;

  /// No description provided for @pet_partners_title.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get pet_partners_title;

  /// No description provided for @pet_partners_desc.
  ///
  /// In en, this message translates to:
  /// **'Discounts and services'**
  String get pet_partners_desc;

  /// No description provided for @pet_tab_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get pet_tab_history;

  /// No description provided for @pet_appointment_new_partner.
  ///
  /// In en, this message translates to:
  /// **'[New Partner]'**
  String get pet_appointment_new_partner;

  /// No description provided for @pet_appointment_searching_partners.
  ///
  /// In en, this message translates to:
  /// **'Searching nearby partners...'**
  String get pet_appointment_searching_partners;

  /// No description provided for @pet_appointment_manual_entry.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get pet_appointment_manual_entry;

  /// No description provided for @pet_appointment_no_partner_title.
  ///
  /// In en, this message translates to:
  /// **'No Partner Selected'**
  String get pet_appointment_no_partner_title;

  /// No description provided for @pet_appointment_no_partner_msg.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t specified a location or professional. Do you want to save the appointment anyway?'**
  String get pet_appointment_no_partner_msg;

  /// No description provided for @pet_appointment_no_partner_confirm.
  ///
  /// In en, this message translates to:
  /// **'Save without partner'**
  String get pet_appointment_no_partner_confirm;

  /// No description provided for @pet_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get pet_history_empty;

  /// No description provided for @pet_analysis_result_title.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get pet_analysis_result_title;

  /// No description provided for @pet_status_healthy_simple.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get pet_status_healthy_simple;

  /// No description provided for @pet_status_critical_simple.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get pet_status_critical_simple;

  /// No description provided for @pet_status_attention_simple.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get pet_status_attention_simple;

  /// No description provided for @pet_section_sources.
  ///
  /// In en, this message translates to:
  /// **'References & Protocol'**
  String get pet_section_sources;

  /// No description provided for @pet_action_new_analysis.
  ///
  /// In en, this message translates to:
  /// **'New Analysis'**
  String get pet_action_new_analysis;

  /// No description provided for @source_scannut_db.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+ Database'**
  String get source_scannut_db;

  /// No description provided for @pet_unknown_name.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get pet_unknown_name;

  /// No description provided for @pet_footer_brand.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+ Pet Intelligence'**
  String get pet_footer_brand;

  /// No description provided for @pet_label_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get pet_label_status;

  /// No description provided for @pet_history_title.
  ///
  /// In en, this message translates to:
  /// **'Analysis History'**
  String get pet_history_title;

  /// No description provided for @pet_breed_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Breed'**
  String get pet_breed_unknown;

  /// No description provided for @pet_label_breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get pet_label_breed;

  /// No description provided for @pet_label_sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get pet_label_sex;

  /// No description provided for @pet_sex_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get pet_sex_male;

  /// No description provided for @pet_sex_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get pet_sex_female;

  /// No description provided for @pet_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Pet'**
  String get pet_delete_title;

  /// No description provided for @pet_delete_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this pet and all its history?'**
  String get pet_delete_content;

  /// No description provided for @pet_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pet_delete_confirm;

  /// No description provided for @pet_delete_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pet_delete_cancel;

  /// No description provided for @pet_history_delete_success.
  ///
  /// In en, this message translates to:
  /// **'History deleted successfully!'**
  String get pet_history_delete_success;

  /// No description provided for @pet_ai_overloaded_message.
  ///
  /// In en, this message translates to:
  /// **'AI overloaded! Please try again in a few moments.'**
  String get pet_ai_overloaded_message;

  /// No description provided for @pet_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Pet deleted successfully'**
  String get pet_delete_success;

  /// No description provided for @pet_recent_analyses.
  ///
  /// In en, this message translates to:
  /// **'Recent Analyses'**
  String get pet_recent_analyses;

  /// No description provided for @pet_no_history.
  ///
  /// In en, this message translates to:
  /// **'No recent analyses.'**
  String get pet_no_history;

  /// No description provided for @pet_new_pet.
  ///
  /// In en, this message translates to:
  /// **'New Pet'**
  String get pet_new_pet;

  /// No description provided for @val_unknown_date.
  ///
  /// In en, this message translates to:
  /// **'Unknown Date'**
  String get val_unknown_date;

  /// No description provided for @report_generated_on.
  ///
  /// In en, this message translates to:
  /// **'Generated on'**
  String get report_generated_on;

  /// No description provided for @pet_analysis_skin.
  ///
  /// In en, this message translates to:
  /// **'Skin & Coat'**
  String get pet_analysis_skin;

  /// No description provided for @pet_analysis_mouth.
  ///
  /// In en, this message translates to:
  /// **'Oral Health'**
  String get pet_analysis_mouth;

  /// No description provided for @pet_analysis_stool.
  ///
  /// In en, this message translates to:
  /// **'Stool Screening'**
  String get pet_analysis_stool;

  /// No description provided for @pet_analysis_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab Report Reading'**
  String get pet_analysis_lab;

  /// No description provided for @pet_analysis_label.
  ///
  /// In en, this message translates to:
  /// **'Nutrition & Labels'**
  String get pet_analysis_label;

  /// No description provided for @pet_analysis_posture.
  ///
  /// In en, this message translates to:
  /// **'Body Condition'**
  String get pet_analysis_posture;

  /// No description provided for @ai_feedback_no_oral_layout.
  ///
  /// In en, this message translates to:
  /// **'No oral structures visible for analysis.'**
  String get ai_feedback_no_oral_layout;

  /// No description provided for @ai_feedback_no_derm_abnormalities.
  ///
  /// In en, this message translates to:
  /// **'No dermatological abnormalities detected based on visual evidence.'**
  String get ai_feedback_no_derm_abnormalities;

  /// No description provided for @ai_feedback_invalid_gastro.
  ///
  /// In en, this message translates to:
  /// **'INVALID_CONTEXT: Image does not appear to be gastrointestinal output.'**
  String get ai_feedback_invalid_gastro;

  /// No description provided for @ai_feedback_invalid_lab.
  ///
  /// In en, this message translates to:
  /// **'INVALID_CONTEXT: Image is not a lab report.'**
  String get ai_feedback_invalid_lab;

  /// No description provided for @ai_feedback_lab_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Interpretation is based on visible text. Verify with original document.'**
  String get ai_feedback_lab_disclaimer;

  /// No description provided for @ai_feedback_eyes_not_visible.
  ///
  /// In en, this message translates to:
  /// **'Eyes not fully visible.'**
  String get ai_feedback_eyes_not_visible;

  /// No description provided for @ai_feedback_inconclusive_angle.
  ///
  /// In en, this message translates to:
  /// **'Inconclusive visual angle.'**
  String get ai_feedback_inconclusive_angle;

  /// No description provided for @pet_module_dentistry.
  ///
  /// In en, this message translates to:
  /// **'Oral Health (Teeth & Gums)'**
  String get pet_module_dentistry;

  /// No description provided for @pet_module_dermatology.
  ///
  /// In en, this message translates to:
  /// **'Skin, Coat & Wounds'**
  String get pet_module_dermatology;

  /// No description provided for @pet_module_gastro.
  ///
  /// In en, this message translates to:
  /// **'Stool & Digestion'**
  String get pet_module_gastro;

  /// No description provided for @pet_module_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab Report Reading'**
  String get pet_module_lab;

  /// No description provided for @pet_module_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get pet_module_nutrition;

  /// No description provided for @pet_module_ophthalmology.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology (Eyes)'**
  String get pet_module_ophthalmology;

  /// No description provided for @pet_module_physique.
  ///
  /// In en, this message translates to:
  /// **'Body Condition & Weight'**
  String get pet_module_physique;

  /// No description provided for @pet_module_nutrition_programs.
  ///
  /// In en, this message translates to:
  /// **'Label Analysis, Nutritional Table'**
  String get pet_module_nutrition_programs;

  /// No description provided for @pet_module_vocal.
  ///
  /// In en, this message translates to:
  /// **'Vocal'**
  String get pet_module_vocal;

  /// No description provided for @pet_module_vocal_programs.
  ///
  /// In en, this message translates to:
  /// **'Barks, Meows, Coughs, Breathing'**
  String get pet_module_vocal_programs;

  /// No description provided for @pet_module_behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get pet_module_behavior;

  /// No description provided for @pet_module_behavior_programs.
  ///
  /// In en, this message translates to:
  /// **'Breed, Posture, Anxiety, Tremors'**
  String get pet_module_behavior_programs;

  /// No description provided for @pet_module_plant.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get pet_module_plant;

  /// No description provided for @pet_module_plant_programs.
  ///
  /// In en, this message translates to:
  /// **'Toxic Plant Identification'**
  String get pet_module_plant_programs;

  /// No description provided for @pet_module_food_bowl.
  ///
  /// In en, this message translates to:
  /// **'Food Bowl'**
  String get pet_module_food_bowl;

  /// No description provided for @action_record_video_audio.
  ///
  /// In en, this message translates to:
  /// **'Record Audio/Video'**
  String get action_record_video_audio;

  /// No description provided for @action_select_audio.
  ///
  /// In en, this message translates to:
  /// **'Select Audio'**
  String get action_select_audio;

  /// No description provided for @action_upload_video_audio.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get action_upload_video_audio;

  /// No description provided for @pet_mode_my_pet.
  ///
  /// In en, this message translates to:
  /// **'My Pet'**
  String get pet_mode_my_pet;

  /// No description provided for @pet_mode_friend.
  ///
  /// In en, this message translates to:
  /// **'Friend Pet'**
  String get pet_mode_friend;

  /// No description provided for @pet_label_tutor.
  ///
  /// In en, this message translates to:
  /// **'Tutor Name'**
  String get pet_label_tutor;

  /// No description provided for @pet_hint_select_friend.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get pet_hint_select_friend;

  /// No description provided for @pet_new_friend_option.
  ///
  /// In en, this message translates to:
  /// **'New Friend'**
  String get pet_new_friend_option;

  /// No description provided for @pet_friend_list_label.
  ///
  /// In en, this message translates to:
  /// **'Friend List'**
  String get pet_friend_list_label;

  /// No description provided for @pet_error_fill_friend_fields.
  ///
  /// In en, this message translates to:
  /// **'Fill all.'**
  String get pet_error_fill_friend_fields;

  /// No description provided for @pet_result_title_my_pet.
  ///
  /// In en, this message translates to:
  /// **'My Pet: {name}'**
  String pet_result_title_my_pet(Object name);

  /// No description provided for @pet_result_title_friend_pet.
  ///
  /// In en, this message translates to:
  /// **'Friend Pet: {name} (Tutor: {tutor})'**
  String pet_result_title_friend_pet(Object name, Object tutor);

  /// No description provided for @pet_action_edit_friend.
  ///
  /// In en, this message translates to:
  /// **'Edit Friend'**
  String get pet_action_edit_friend;

  /// No description provided for @pet_action_delete_friend.
  ///
  /// In en, this message translates to:
  /// **'Delete Friend'**
  String get pet_action_delete_friend;

  /// No description provided for @pet_msg_confirm_delete_friend.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this friend?'**
  String get pet_msg_confirm_delete_friend;

  /// No description provided for @pet_msg_friend_updated.
  ///
  /// In en, this message translates to:
  /// **'Friend updated successfully!'**
  String get pet_msg_friend_updated;

  /// No description provided for @pet_msg_friend_deleted.
  ///
  /// In en, this message translates to:
  /// **'Friend deleted successfully!'**
  String get pet_msg_friend_deleted;

  /// No description provided for @pet_dialog_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Friend Pet'**
  String get pet_dialog_edit_title;

  /// No description provided for @pet_plant_toxic.
  ///
  /// In en, this message translates to:
  /// **'TOXIC ⚠️'**
  String get pet_plant_toxic;

  /// No description provided for @pet_plant_safe.
  ///
  /// In en, this message translates to:
  /// **'SAFE ✅'**
  String get pet_plant_safe;

  /// No description provided for @pet_msg_confirm_delete_entry.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this analysis?'**
  String get pet_msg_confirm_delete_entry;

  /// No description provided for @pet_event_type_activity.
  ///
  /// In en, this message translates to:
  /// **'Walks'**
  String get pet_event_type_activity;

  /// No description provided for @pet_event_type_ai_chat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get pet_event_type_ai_chat;

  /// No description provided for @pet_event_type_appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get pet_event_type_appointment;

  /// No description provided for @pet_event_type_partner.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get pet_event_type_partner;

  /// No description provided for @pet_event_type_behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get pet_event_type_behavior;

  /// No description provided for @pet_event_type_plant.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get pet_event_type_plant;

  /// No description provided for @health_plan_label_card_number.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get health_plan_label_card_number;

  /// No description provided for @pet_analysis_visual_title.
  ///
  /// In en, this message translates to:
  /// **'Visual Analysis'**
  String get pet_analysis_visual_title;

  /// No description provided for @pet_label_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get pet_label_whatsapp;

  /// No description provided for @label_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get label_photo;

  /// No description provided for @label_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get label_gallery;

  /// No description provided for @label_video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get label_video;

  /// No description provided for @label_sounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get label_sounds;

  /// No description provided for @label_vocal.
  ///
  /// In en, this message translates to:
  /// **'Vocalization'**
  String get label_vocal;

  /// No description provided for @pet_journal_recording.
  ///
  /// In en, this message translates to:
  /// **'Recording journal...'**
  String get pet_journal_recording;

  /// No description provided for @pet_journal_audio_saved.
  ///
  /// In en, this message translates to:
  /// **'Audio saved successfully'**
  String get pet_journal_audio_saved;

  /// No description provided for @pet_journal_photo_saved.
  ///
  /// In en, this message translates to:
  /// **'Photo saved successfully'**
  String get pet_journal_photo_saved;

  /// No description provided for @pet_journal_video_saved.
  ///
  /// In en, this message translates to:
  /// **'Video saved successfully'**
  String get pet_journal_video_saved;

  /// No description provided for @error_file_too_large.
  ///
  /// In en, this message translates to:
  /// **'This file is too large (Max 20MB).'**
  String get error_file_too_large;

  /// No description provided for @pet_journal_searching_address.
  ///
  /// In en, this message translates to:
  /// **'Searching address...'**
  String get pet_journal_searching_address;

  /// No description provided for @pet_journal_address_not_found.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get pet_journal_address_not_found;

  /// No description provided for @pet_journal_report_action.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get pet_journal_report_action;

  /// No description provided for @pet_journal_question.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get pet_journal_question;

  /// No description provided for @pet_journal_hint_text.
  ///
  /// In en, this message translates to:
  /// **'Write here...'**
  String get pet_journal_hint_text;

  /// No description provided for @pet_journal_register_button.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get pet_journal_register_button;

  /// No description provided for @help_guide_title.
  ///
  /// In en, this message translates to:
  /// **'Help Guide'**
  String get help_guide_title;

  /// No description provided for @btn_got_it.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get btn_got_it;

  /// No description provided for @map_alert_title.
  ///
  /// In en, this message translates to:
  /// **'Map Alert'**
  String get map_alert_title;

  /// No description provided for @map_type_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get map_type_normal;

  /// No description provided for @map_type_satellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get map_type_satellite;

  /// No description provided for @common_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get common_delete_confirm_title;

  /// No description provided for @common_delete_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get common_delete_confirm_message;

  /// No description provided for @pet_profile_title_simple.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get pet_profile_title_simple;

  /// No description provided for @pet_action_save_profile_simple.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pet_action_save_profile_simple;

  /// No description provided for @funeral_save_success.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get funeral_save_success;

  /// No description provided for @health_plan_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Health plan saved!'**
  String get health_plan_saved_success;

  /// No description provided for @pet_age_years.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String pet_age_years(int count);

  /// No description provided for @keywordFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get keywordFriend;

  /// No description provided for @keywordGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get keywordGuest;

  /// No description provided for @pet_agenda_view_calendar.
  ///
  /// In en, this message translates to:
  /// **'View Calendar'**
  String get pet_agenda_view_calendar;

  /// No description provided for @pet_module_dentistry_programs.
  ///
  /// In en, this message translates to:
  /// **'Tartar, Gingivitis, Broken Teeth'**
  String get pet_module_dentistry_programs;

  /// No description provided for @pet_module_dermatology_programs.
  ///
  /// In en, this message translates to:
  /// **'Alopecia, Dermatitis, Wounds, Parasites'**
  String get pet_module_dermatology_programs;

  /// No description provided for @pet_module_gastro_programs.
  ///
  /// In en, this message translates to:
  /// **'Consistency, Color, Parasites, Blood'**
  String get pet_module_gastro_programs;

  /// No description provided for @pet_module_ophthalmology_programs.
  ///
  /// In en, this message translates to:
  /// **'Secretion, Redness, Cataracts, Spots'**
  String get pet_module_ophthalmology_programs;

  /// No description provided for @pet_module_otology_programs.
  ///
  /// In en, this message translates to:
  /// **'Wax, Itching, Odor, Redness'**
  String get pet_module_otology_programs;

  /// No description provided for @pet_module_physique_programs.
  ///
  /// In en, this message translates to:
  /// **'Body Score, Muscle Mass, Obesity'**
  String get pet_module_physique_programs;

  /// No description provided for @pet_module_lab_programs.
  ///
  /// In en, this message translates to:
  /// **'CBC, Biochemistry, Urine, Stool'**
  String get pet_module_lab_programs;

  /// No description provided for @pet_error_ai_unhandled_format.
  ///
  /// In en, this message translates to:
  /// **'The AI generated a complex response on this attempt. Please click analyze again.'**
  String get pet_error_ai_unhandled_format;

  /// No description provided for @pet_module_food_bowl_programs.
  ///
  /// In en, this message translates to:
  /// **'Kibble Quality, Natural Food'**
  String get pet_module_food_bowl_programs;

  /// No description provided for @pet_journal_audio_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Audio saved!'**
  String get pet_journal_audio_saved_success;

  /// No description provided for @pet_journal_photo_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Photo saved!'**
  String get pet_journal_photo_saved_success;

  /// No description provided for @pet_journal_video_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Video saved!'**
  String get pet_journal_video_saved_success;

  /// No description provided for @funeral_save_success_simple.
  ///
  /// In en, this message translates to:
  /// **'Funeral saved!'**
  String get funeral_save_success_simple;

  /// No description provided for @health_plan_saved_success_simple.
  ///
  /// In en, this message translates to:
  /// **'Health plan saved!'**
  String get health_plan_saved_success_simple;

  /// No description provided for @pet_module_ears.
  ///
  /// In en, this message translates to:
  /// **'Ears'**
  String get pet_module_ears;

  /// No description provided for @pet_label_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get pet_label_size;

  /// No description provided for @pet_size_small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get pet_size_small;

  /// No description provided for @pet_size_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get pet_size_medium;

  /// No description provided for @pet_size_large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get pet_size_large;

  /// No description provided for @pet_label_estimated_weight.
  ///
  /// In en, this message translates to:
  /// **'Est. Weight'**
  String get pet_label_estimated_weight;

  /// No description provided for @pet_weight_unit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get pet_weight_unit;

  /// No description provided for @pet_label_neutered.
  ///
  /// In en, this message translates to:
  /// **'Neutered'**
  String get pet_label_neutered;

  /// No description provided for @pet_clinical_title.
  ///
  /// In en, this message translates to:
  /// **'Clinical Conditions'**
  String get pet_clinical_title;

  /// No description provided for @pet_label_allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get pet_label_allergies;

  /// No description provided for @pet_label_chronic.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get pet_label_chronic;

  /// No description provided for @pet_label_disabilities.
  ///
  /// In en, this message translates to:
  /// **'Disabilities'**
  String get pet_label_disabilities;

  /// No description provided for @pet_label_observations.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get pet_label_observations;

  /// No description provided for @pet_id_external_title.
  ///
  /// In en, this message translates to:
  /// **'External ID'**
  String get pet_id_external_title;

  /// No description provided for @pet_label_microchip.
  ///
  /// In en, this message translates to:
  /// **'Microchip'**
  String get pet_label_microchip;

  /// No description provided for @pet_label_registry.
  ///
  /// In en, this message translates to:
  /// **'Registry ID'**
  String get pet_label_registry;

  /// No description provided for @pet_label_qrcode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get pet_label_qrcode;

  /// No description provided for @pet_qrcode_future.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get pet_qrcode_future;

  /// No description provided for @pet_plans_title.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get pet_plans_title;

  /// No description provided for @pet_action_manage_health_plan.
  ///
  /// In en, this message translates to:
  /// **'Manage Health Plan'**
  String get pet_action_manage_health_plan;

  /// No description provided for @health_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Health Plan'**
  String get health_plan_title;

  /// No description provided for @health_plan_section_identification.
  ///
  /// In en, this message translates to:
  /// **'1. Identification'**
  String get health_plan_section_identification;

  /// No description provided for @health_plan_section_coverages.
  ///
  /// In en, this message translates to:
  /// **'2. Coverages'**
  String get health_plan_section_coverages;

  /// No description provided for @health_plan_section_limits.
  ///
  /// In en, this message translates to:
  /// **'3. Rules'**
  String get health_plan_section_limits;

  /// No description provided for @health_plan_section_support.
  ///
  /// In en, this message translates to:
  /// **'4. Support'**
  String get health_plan_section_support;

  /// No description provided for @health_plan_action_save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get health_plan_action_save;

  /// No description provided for @health_plan_label_operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get health_plan_label_operator;

  /// No description provided for @health_plan_label_plan_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get health_plan_label_plan_name;

  /// No description provided for @health_plan_label_holder_name.
  ///
  /// In en, this message translates to:
  /// **'Holder'**
  String get health_plan_label_holder_name;

  /// No description provided for @health_plan_label_grace_period.
  ///
  /// In en, this message translates to:
  /// **'Grace Period'**
  String get health_plan_label_grace_period;

  /// No description provided for @health_plan_label_annual_limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get health_plan_label_annual_limit;

  /// No description provided for @health_plan_label_copay.
  ///
  /// In en, this message translates to:
  /// **'Copay'**
  String get health_plan_label_copay;

  /// No description provided for @health_plan_label_reimburse.
  ///
  /// In en, this message translates to:
  /// **'Reimburse'**
  String get health_plan_label_reimburse;

  /// No description provided for @health_plan_label_deductible.
  ///
  /// In en, this message translates to:
  /// **'Deductible'**
  String get health_plan_label_deductible;

  /// No description provided for @health_plan_label_main_clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get health_plan_label_main_clinic;

  /// No description provided for @health_plan_label_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get health_plan_label_city;

  /// No description provided for @health_plan_label_24h.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get health_plan_label_24h;

  /// No description provided for @health_plan_label_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get health_plan_label_phone;

  /// No description provided for @health_plan_label_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get health_plan_label_whatsapp;

  /// No description provided for @health_plan_label_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get health_plan_label_email;

  /// No description provided for @health_cov_consultations.
  ///
  /// In en, this message translates to:
  /// **'Consultations'**
  String get health_cov_consultations;

  /// No description provided for @health_cov_vaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get health_cov_vaccines;

  /// No description provided for @health_cov_lab_exams.
  ///
  /// In en, this message translates to:
  /// **'Lab Exams'**
  String get health_cov_lab_exams;

  /// No description provided for @health_cov_imaging.
  ///
  /// In en, this message translates to:
  /// **'Imaging'**
  String get health_cov_imaging;

  /// No description provided for @health_cov_surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get health_cov_surgery;

  /// No description provided for @health_cov_hospitalization.
  ///
  /// In en, this message translates to:
  /// **'Hospitalization'**
  String get health_cov_hospitalization;

  /// No description provided for @health_cov_emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get health_cov_emergency;

  /// No description provided for @health_cov_pre_existing.
  ///
  /// In en, this message translates to:
  /// **'Pre-existing'**
  String get health_cov_pre_existing;

  /// No description provided for @health_cov_dentistry.
  ///
  /// In en, this message translates to:
  /// **'Dentistry'**
  String get health_cov_dentistry;

  /// No description provided for @health_cov_physiotherapy.
  ///
  /// In en, this message translates to:
  /// **'Physio'**
  String get health_cov_physiotherapy;

  /// No description provided for @pet_db_sync_error.
  ///
  /// In en, this message translates to:
  /// **'Sync Error'**
  String get pet_db_sync_error;

  /// No description provided for @pet_action_manage_funeral_plan.
  ///
  /// In en, this message translates to:
  /// **'Funeral'**
  String get pet_action_manage_funeral_plan;

  /// No description provided for @funeral_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Funeral Plan'**
  String get funeral_plan_title;

  /// No description provided for @funeral_section_identity.
  ///
  /// In en, this message translates to:
  /// **'1. Identification'**
  String get funeral_section_identity;

  /// No description provided for @funeral_section_services.
  ///
  /// In en, this message translates to:
  /// **'2. Services'**
  String get funeral_section_services;

  /// No description provided for @funeral_section_rules.
  ///
  /// In en, this message translates to:
  /// **'3. Rules'**
  String get funeral_section_rules;

  /// No description provided for @funeral_section_emergency.
  ///
  /// In en, this message translates to:
  /// **'4. EMERGENCY'**
  String get funeral_section_emergency;

  /// No description provided for @funeral_label_company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get funeral_label_company;

  /// No description provided for @funeral_label_plan_name.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get funeral_label_plan_name;

  /// No description provided for @funeral_label_contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get funeral_label_contract;

  /// No description provided for @funeral_label_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get funeral_label_start_date;

  /// No description provided for @funeral_label_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get funeral_label_status;

  /// No description provided for @funeral_label_grace_period.
  ///
  /// In en, this message translates to:
  /// **'Grace Period'**
  String get funeral_label_grace_period;

  /// No description provided for @funeral_label_max_weight.
  ///
  /// In en, this message translates to:
  /// **'Max Weight'**
  String get funeral_label_max_weight;

  /// No description provided for @funeral_label_24h.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get funeral_label_24h;

  /// No description provided for @funeral_label_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get funeral_label_phone;

  /// No description provided for @funeral_label_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get funeral_label_whatsapp;

  /// No description provided for @funeral_label_value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get funeral_label_value;

  /// No description provided for @funeral_label_extra_fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get funeral_label_extra_fees;

  /// No description provided for @funeral_svc_removal.
  ///
  /// In en, this message translates to:
  /// **'Removal'**
  String get funeral_svc_removal;

  /// No description provided for @funeral_svc_viewing.
  ///
  /// In en, this message translates to:
  /// **'Viewing'**
  String get funeral_svc_viewing;

  /// No description provided for @funeral_svc_cremation_ind.
  ///
  /// In en, this message translates to:
  /// **'Cremation Ind.'**
  String get funeral_svc_cremation_ind;

  /// No description provided for @funeral_svc_cremation_col.
  ///
  /// In en, this message translates to:
  /// **'Cremation Col.'**
  String get funeral_svc_cremation_col;

  /// No description provided for @funeral_svc_burial.
  ///
  /// In en, this message translates to:
  /// **'Burial'**
  String get funeral_svc_burial;

  /// No description provided for @funeral_svc_urn.
  ///
  /// In en, this message translates to:
  /// **'Urn'**
  String get funeral_svc_urn;

  /// No description provided for @funeral_svc_ashes.
  ///
  /// In en, this message translates to:
  /// **'Ashes'**
  String get funeral_svc_ashes;

  /// No description provided for @funeral_svc_certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get funeral_svc_certificate;

  /// No description provided for @funeral_action_call_emergency.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY'**
  String get funeral_action_call_emergency;

  /// No description provided for @funeral_action_save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get funeral_action_save;

  /// No description provided for @pet_action_analyses.
  ///
  /// In en, this message translates to:
  /// **'Analyses'**
  String get pet_action_analyses;

  /// No description provided for @pet_action_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get pet_action_health;

  /// No description provided for @pet_action_agenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get pet_action_agenda;

  /// No description provided for @pet_history_button.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get pet_history_button;

  /// No description provided for @ai_assistant_title.
  ///
  /// In en, this message translates to:
  /// **'AI {name}'**
  String ai_assistant_title(Object name);

  /// No description provided for @ai_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Ask here...'**
  String get ai_input_hint;

  /// No description provided for @ai_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get ai_listening;

  /// No description provided for @ai_error_mic.
  ///
  /// In en, this message translates to:
  /// **'Mic denied'**
  String get ai_error_mic;

  /// No description provided for @ai_thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get ai_thinking;

  /// No description provided for @pet_age_months.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String pet_age_months(int count);

  /// No description provided for @pet_age_estimate_label.
  ///
  /// In en, this message translates to:
  /// **'Est. Age:'**
  String get pet_age_estimate_label;

  /// No description provided for @pet_event_type_food.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get pet_event_type_food;

  /// No description provided for @pet_event_type_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get pet_event_type_health;

  /// No description provided for @pet_event_type_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get pet_event_type_weight;

  /// No description provided for @pet_event_type_hygiene.
  ///
  /// In en, this message translates to:
  /// **'Hygiene'**
  String get pet_event_type_hygiene;

  /// No description provided for @pet_event_type_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pet_event_type_other;

  /// No description provided for @pet_agenda_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Agenda Module for {name}'**
  String pet_agenda_coming_soon(Object name);

  /// No description provided for @pet_medical_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No medical history.'**
  String get pet_medical_history_empty;

  /// No description provided for @pet_share_not_implemented.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get pet_share_not_implemented;

  /// No description provided for @pet_ai_brain_not_ready.
  ///
  /// In en, this message translates to:
  /// **'AI loading...'**
  String get pet_ai_brain_not_ready;

  /// No description provided for @pet_ai_connection_error.
  ///
  /// In en, this message translates to:
  /// **'AI Error: {error}'**
  String pet_ai_connection_error(Object error);

  /// No description provided for @pet_ai_trouble_thinking.
  ///
  /// In en, this message translates to:
  /// **'Trouble processing.'**
  String get pet_ai_trouble_thinking;

  /// No description provided for @pet_stt_not_available.
  ///
  /// In en, this message translates to:
  /// **'STT unavailable'**
  String get pet_stt_not_available;

  /// No description provided for @pet_stt_error.
  ///
  /// In en, this message translates to:
  /// **'STT Error: {error}'**
  String pet_stt_error(Object error);

  /// No description provided for @pet_entry_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get pet_entry_deleted;

  /// No description provided for @pet_error_history_load.
  ///
  /// In en, this message translates to:
  /// **'History Error: {error}'**
  String pet_error_history_load(Object error);

  /// No description provided for @pet_ai_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I am {name}\'s AI.'**
  String pet_ai_greeting(Object name);

  /// No description provided for @pet_event_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get pet_event_food;

  /// No description provided for @pet_event_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get pet_event_health;

  /// No description provided for @pet_event_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get pet_event_weight;

  /// No description provided for @pet_event_walk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get pet_event_walk;

  /// No description provided for @pet_event_ai_chat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get pet_event_ai_chat;

  /// No description provided for @pet_event_appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get pet_event_appointment;

  /// No description provided for @pet_event_partner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get pet_event_partner;

  /// No description provided for @pet_event_behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get pet_event_behavior;

  /// No description provided for @pet_event_hygiene.
  ///
  /// In en, this message translates to:
  /// **'Bath'**
  String get pet_event_hygiene;

  /// No description provided for @pet_event_medication.
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get pet_event_medication;

  /// No description provided for @pet_event_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get pet_event_note;

  /// No description provided for @pet_ai_thinking_status.
  ///
  /// In en, this message translates to:
  /// **'AI Thinking...'**
  String get pet_ai_thinking_status;

  /// No description provided for @pet_agenda_title.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get pet_agenda_title;

  /// Title for the Pet Agenda screen with dynamic pet name
  ///
  /// In en, this message translates to:
  /// **'Agenda: {petName}'**
  String pet_agenda_title_dynamic(String petName);

  /// Title for the Pet Walk screen with dynamic pet name
  ///
  /// In en, this message translates to:
  /// **'Walk: {petName}'**
  String pet_walk_title_dynamic(String petName);

  /// Dynamic friend walk title
  ///
  /// In en, this message translates to:
  /// **'Friend Walk: {petName}'**
  String pet_friend_walk_title_dynamic(String petName);

  /// No description provided for @pet_agenda_empty.
  ///
  /// In en, this message translates to:
  /// **'Empty Agenda'**
  String get pet_agenda_empty;

  /// No description provided for @pet_agenda_add_event_dynamic.
  ///
  /// In en, this message translates to:
  /// **'Event for {petName}'**
  String pet_agenda_add_event_dynamic(Object petName);

  /// No description provided for @pet_agenda_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get pet_agenda_today;

  /// No description provided for @pet_agenda_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get pet_agenda_yesterday;

  /// No description provided for @pet_agenda_select_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pet_agenda_select_type;

  /// No description provided for @pet_agenda_event_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pet_agenda_event_date;

  /// No description provided for @pet_agenda_event_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get pet_agenda_event_time;

  /// No description provided for @pet_agenda_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get pet_agenda_notes_hint;

  /// No description provided for @pet_agenda_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pet_agenda_save;

  /// No description provided for @pet_journal_add_event.
  ///
  /// In en, this message translates to:
  /// **'Journal {petName}'**
  String pet_journal_add_event(Object petName);

  /// No description provided for @pet_journal_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Describe...'**
  String get pet_journal_placeholder;

  /// No description provided for @pet_journal_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get pet_journal_register;

  /// No description provided for @label_friend_name.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get label_friend_name;

  /// No description provided for @pet_friend_prefix.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get pet_friend_prefix;

  /// No description provided for @pet_friend_of_prefix.
  ///
  /// In en, this message translates to:
  /// **'Friend of'**
  String get pet_friend_of_prefix;

  /// No description provided for @pdf_friend_name_prefix.
  ///
  /// In en, this message translates to:
  /// **'Friend\'s name'**
  String get pdf_friend_name_prefix;

  /// No description provided for @pdf_my_pet_name_prefix.
  ///
  /// In en, this message translates to:
  /// **'My pet\'s name'**
  String get pdf_my_pet_name_prefix;

  /// No description provided for @label_tutor_name.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get label_tutor_name;

  /// No description provided for @ai_simulating_analysis.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get ai_simulating_analysis;

  /// No description provided for @pet_journal_location_loading.
  ///
  /// In en, this message translates to:
  /// **'GPS...'**
  String get pet_journal_location_loading;

  /// No description provided for @pet_journal_location_captured.
  ///
  /// In en, this message translates to:
  /// **'Location saved'**
  String get pet_journal_location_captured;

  /// No description provided for @pet_journal_audio_recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get pet_journal_audio_recording;

  /// No description provided for @ai_audio_analysis_cough_detected.
  ///
  /// In en, this message translates to:
  /// **'Cough detected.'**
  String get ai_audio_analysis_cough_detected;

  /// No description provided for @ai_suggest_health_category.
  ///
  /// In en, this message translates to:
  /// **'Health?'**
  String get ai_suggest_health_category;

  /// No description provided for @pet_journal_location_name_simulated.
  ///
  /// In en, this message translates to:
  /// **'Simulated Loc'**
  String get pet_journal_location_name_simulated;

  /// No description provided for @journal_guide_title.
  ///
  /// In en, this message translates to:
  /// **'AI Journal'**
  String get journal_guide_title;

  /// No description provided for @journal_guide_voice.
  ///
  /// In en, this message translates to:
  /// **'Speak and AI organizes.'**
  String get journal_guide_voice;

  /// No description provided for @journal_guide_camera.
  ///
  /// In en, this message translates to:
  /// **'Analyze photos.'**
  String get journal_guide_camera;

  /// No description provided for @journal_guide_audio.
  ///
  /// In en, this message translates to:
  /// **'Record clinical sounds.'**
  String get journal_guide_audio;

  /// No description provided for @journal_guide_location.
  ///
  /// In en, this message translates to:
  /// **'Log location.'**
  String get journal_guide_location;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get common_new;

  /// No description provided for @pet_journal_analyzed_by_nano.
  ///
  /// In en, this message translates to:
  /// **'Nano Banana Analysis'**
  String get pet_journal_analyzed_by_nano;

  /// No description provided for @pet_journal_social_context.
  ///
  /// In en, this message translates to:
  /// **'Social Context'**
  String get pet_journal_social_context;

  /// No description provided for @journal_guide_unlock_hint.
  ///
  /// In en, this message translates to:
  /// **'Start reporting.'**
  String get journal_guide_unlock_hint;

  /// No description provided for @pet_journal_mic_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Mic denied.'**
  String get pet_journal_mic_permission_denied;

  /// No description provided for @label_relate.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get label_relate;

  /// No description provided for @label_place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get label_place;

  /// No description provided for @label_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get label_audio;

  /// No description provided for @label_alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get label_alert;

  /// No description provided for @alert_poison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get alert_poison;

  /// No description provided for @alert_dog_loose.
  ///
  /// In en, this message translates to:
  /// **'Angry Dog'**
  String get alert_dog_loose;

  /// No description provided for @alert_risk_area.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get alert_risk_area;

  /// No description provided for @alert_noise.
  ///
  /// In en, this message translates to:
  /// **'Noise'**
  String get alert_noise;

  /// No description provided for @error_gps.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t locate your device right now. Please check your connection ({error})'**
  String error_gps(Object error);

  /// No description provided for @gps_error_snack.
  ///
  /// In en, this message translates to:
  /// **'GPS Error.'**
  String get gps_error_snack;

  /// No description provided for @map_type_hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get map_type_hybrid;

  /// No description provided for @map_type_terrain.
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get map_type_terrain;

  /// No description provided for @label_map_type.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get label_map_type;

  /// No description provided for @map_alert_dog.
  ///
  /// In en, this message translates to:
  /// **'Angry Dog'**
  String get map_alert_dog;

  /// No description provided for @map_alert_poison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get map_alert_poison;

  /// No description provided for @map_alert_noise.
  ///
  /// In en, this message translates to:
  /// **'Noise'**
  String get map_alert_noise;

  /// No description provided for @map_alert_risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get map_alert_risk;

  /// No description provided for @map_alert_success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get map_alert_success;

  /// No description provided for @pet_agenda_tab_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get pet_agenda_tab_scheduled;

  /// No description provided for @pet_agenda_tab_timeline.
  ///
  /// In en, this message translates to:
  /// **'History & Walks'**
  String get pet_agenda_tab_timeline;

  /// No description provided for @map_alert_description_user.
  ///
  /// In en, this message translates to:
  /// **'By user'**
  String get map_alert_description_user;

  /// No description provided for @pet_journal_gps_error.
  ///
  /// In en, this message translates to:
  /// **'GPS Error'**
  String get pet_journal_gps_error;

  /// No description provided for @pet_journal_loading_gps.
  ///
  /// In en, this message translates to:
  /// **'GPS...'**
  String get pet_journal_loading_gps;

  /// No description provided for @pet_journal_location_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get pet_journal_location_unknown;

  /// No description provided for @pet_journal_location_approx.
  ///
  /// In en, this message translates to:
  /// **'Approximate'**
  String get pet_journal_location_approx;

  /// No description provided for @pet_journal_file_selected.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String pet_journal_file_selected(Object name);

  /// No description provided for @pet_journal_file_error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String pet_journal_file_error(Object error);

  /// No description provided for @pet_journal_help_title.
  ///
  /// In en, this message translates to:
  /// **'How to use this screen?'**
  String get pet_journal_help_title;

  /// No description provided for @pet_journal_help_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Camera & Gallery'**
  String get pet_journal_help_photo_title;

  /// No description provided for @pet_journal_help_photo_desc.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose one from your gallery. Use it to log wounds, feces, identify toxic plants on your path, or even analyze pet food labels, food photos, and lab test results. Our AI focuses on the image to generate deep technical analyses. Max size: 20MB.'**
  String get pet_journal_help_photo_desc;

  /// No description provided for @pet_journal_help_audio_title.
  ///
  /// In en, this message translates to:
  /// **'Sound Recorder'**
  String get pet_journal_help_audio_title;

  /// No description provided for @pet_journal_help_audio_desc.
  ///
  /// In en, this message translates to:
  /// **'Press and hold the microphone icon near the camera button to record ambient sounds, barks, cries, or coughing. The AI will listen to the audio to detect stress or pain signals. Max size: 20MB.'**
  String get pet_journal_help_audio_desc;

  /// No description provided for @pet_journal_help_map_title.
  ///
  /// In en, this message translates to:
  /// **'Map & Alerts'**
  String get pet_journal_help_map_title;

  /// No description provided for @pet_journal_help_map_desc.
  ///
  /// In en, this message translates to:
  /// **'The map automatically saves your current location. If you see danger on your route (like aggressive dogs or poison), tap the alert icon on the map to log it and warn the community.'**
  String get pet_journal_help_map_desc;

  /// No description provided for @pet_journal_help_notes_title.
  ///
  /// In en, this message translates to:
  /// **'Notes & Voice Typing'**
  String get pet_journal_help_notes_title;

  /// No description provided for @pet_journal_help_notes_desc.
  ///
  /// In en, this message translates to:
  /// **'You can type details manually in the text box. If you prefer, tap the microphone inside the text field to just speak; the app will transcribe your words automatically.'**
  String get pet_journal_help_notes_desc;

  /// No description provided for @pet_journal_help_videos_title.
  ///
  /// In en, this message translates to:
  /// **'Short Videos'**
  String get pet_journal_help_videos_title;

  /// No description provided for @pet_journal_help_videos_desc.
  ///
  /// In en, this message translates to:
  /// **'Record short clips directly in the app. This is perfect for showing the AI vet how your pet is walking (if they\'re limping) or to capture unusual behavior in motion. Max size: 20MB.'**
  String get pet_journal_help_videos_desc;

  /// No description provided for @pet_journal_help_ai_title.
  ///
  /// In en, this message translates to:
  /// **'AI Veterinarian'**
  String get pet_journal_help_ai_title;

  /// No description provided for @pet_journal_help_ai_desc.
  ///
  /// In en, this message translates to:
  /// **'When you provide any of the items above, our Artificial Intelligence acts like a vet and analyzes the data instantly! It generates a clinical report that is saved right in your pet\'s history.'**
  String get pet_journal_help_ai_desc;

  /// No description provided for @pet_journal_help_friends_title.
  ///
  /// In en, this message translates to:
  /// **'Walking with Friends'**
  String get pet_journal_help_friends_title;

  /// No description provided for @pet_journal_help_friends_desc.
  ///
  /// In en, this message translates to:
  /// **'When the switch is on the friend, the app can perform all available analyses for the friend pet and also issue a PDF report.'**
  String get pet_journal_help_friends_desc;

  /// No description provided for @pet_journal_help_specialized_ai_title.
  ///
  /// In en, this message translates to:
  /// **'Specialized Pet AI'**
  String get pet_journal_help_specialized_ai_title;

  /// No description provided for @pet_journal_help_specialized_ai_desc.
  ///
  /// In en, this message translates to:
  /// **'There is an Artificial Intelligence specially designed to know, learn, and understand all of your pet\'s data (like in Pet Chat). This allows it to answer anything you ask about your pet in a personalized way!'**
  String get pet_journal_help_specialized_ai_desc;

  /// No description provided for @pet_error_ai_analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'AI Error: {error}'**
  String pet_error_ai_analysis_failed(Object error);

  /// No description provided for @pet_error_repository_failure.
  ///
  /// In en, this message translates to:
  /// **'Oops, we couldn\'t save your changes at the moment ({status})'**
  String pet_error_repository_failure(Object status);

  /// No description provided for @pet_error_saving_event.
  ///
  /// In en, this message translates to:
  /// **'Save Error: {error}'**
  String pet_error_saving_event(Object error);

  /// No description provided for @pet_agenda_summary_format.
  ///
  /// In en, this message translates to:
  /// **'{count} events'**
  String pet_agenda_summary_format(int count);

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @pet_error_delete_event.
  ///
  /// In en, this message translates to:
  /// **'Delete Error'**
  String get pet_error_delete_event;

  /// No description provided for @pet_label_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get pet_label_address;

  /// No description provided for @pet_label_ai_summary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get pet_label_ai_summary;

  /// No description provided for @pet_analysis_data_not_found.
  ///
  /// In en, this message translates to:
  /// **'No data.'**
  String get pet_analysis_data_not_found;

  /// No description provided for @pet_logic_keywords_health.
  ///
  /// In en, this message translates to:
  /// **'poop, feces, stool, pee, urine, vomit, diarrhea, blood, wound, injury, pain, limping, choking'**
  String get pet_logic_keywords_health;

  /// No description provided for @pet_ai_language.
  ///
  /// In en, this message translates to:
  /// **'en_US'**
  String get pet_ai_language;

  /// No description provided for @map_gps_disabled.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS.'**
  String get map_gps_disabled;

  /// No description provided for @map_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'No permission.'**
  String get map_permission_denied;

  /// No description provided for @map_permission_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'Open settings.'**
  String get map_permission_denied_forever;

  /// No description provided for @map_error_location.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String map_error_location(Object error);

  /// No description provided for @map_title_pet_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get map_title_pet_location;

  /// No description provided for @action_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get action_open_settings;

  /// No description provided for @map_sync_satellites.
  ///
  /// In en, this message translates to:
  /// **'Satellites...'**
  String get map_sync_satellites;

  /// No description provided for @pet_journal_audio_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get pet_journal_audio_processing;

  /// No description provided for @pet_journal_audio_error_file_not_found.
  ///
  /// In en, this message translates to:
  /// **'No audio.'**
  String get pet_journal_audio_error_file_not_found;

  /// No description provided for @pet_journal_audio_error_generic.
  ///
  /// In en, this message translates to:
  /// **'No result.'**
  String get pet_journal_audio_error_generic;

  /// No description provided for @pet_journal_audio_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending.'**
  String get pet_journal_audio_pending;

  /// No description provided for @pet_journal_video_processing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get pet_journal_video_processing;

  /// No description provided for @pet_journal_video_error.
  ///
  /// In en, this message translates to:
  /// **'Video Error.'**
  String get pet_journal_video_error;

  /// No description provided for @error_video_too_long.
  ///
  /// In en, this message translates to:
  /// **'Max 60s'**
  String get error_video_too_long;

  /// No description provided for @pet_expense_scan_btn.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get pet_expense_scan_btn;

  /// No description provided for @pet_expense_gallery_btn.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get pet_expense_gallery_btn;

  /// No description provided for @pet_expense_analyzing.
  ///
  /// In en, this message translates to:
  /// **'Extracting values...'**
  String get pet_expense_analyzing;

  /// No description provided for @pet_expense_ocr_success.
  ///
  /// In en, this message translates to:
  /// **'Data extracted successfully!'**
  String get pet_expense_ocr_success;

  /// No description provided for @pet_expense_ocr_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read receipt.'**
  String get pet_expense_ocr_failed;

  /// No description provided for @btn_scan_image.
  ///
  /// In en, this message translates to:
  /// **'Scan Image'**
  String get btn_scan_image;

  /// No description provided for @generic_analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get generic_analyzing;

  /// No description provided for @pet_error_image_not_found.
  ///
  /// In en, this message translates to:
  /// **'Image not found.'**
  String get pet_error_image_not_found;

  /// No description provided for @btn_go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get btn_go;

  /// No description provided for @pet_created_at_label.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get pet_created_at_label;

  /// No description provided for @pet_initial_assessment.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get pet_initial_assessment;

  /// No description provided for @pet_hint_select_type.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get pet_hint_select_type;

  /// No description provided for @pet_label_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get pet_label_info;

  /// No description provided for @pet_type_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get pet_type_profile;

  /// No description provided for @pet_action_profile_short.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get pet_action_profile_short;

  /// No description provided for @pet_action_walk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get pet_action_walk;

  /// No description provided for @pet_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Pet Profile'**
  String get pet_profile_title;

  /// No description provided for @pet_management_title.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get pet_management_title;

  /// No description provided for @pet_label_health_plan.
  ///
  /// In en, this message translates to:
  /// **'Health Plan'**
  String get pet_label_health_plan;

  /// No description provided for @pet_label_funeral_plan.
  ///
  /// In en, this message translates to:
  /// **'Funeral Plan'**
  String get pet_label_funeral_plan;

  /// No description provided for @pet_label_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get pet_label_weight;

  /// No description provided for @pet_label_birth_date.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get pet_label_birth_date;

  /// No description provided for @pet_btn_add_metric.
  ///
  /// In en, this message translates to:
  /// **'Add Metric'**
  String get pet_btn_add_metric;

  /// No description provided for @pet_agenda_add_event.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get pet_agenda_add_event;

  /// No description provided for @error_unexpected_title.
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error'**
  String get error_unexpected_title;

  /// No description provided for @error_unexpected_message.
  ///
  /// In en, this message translates to:
  /// **'We had a little technical issue. We\'re working on fixing it.'**
  String get error_unexpected_message;

  /// No description provided for @error_try_recover.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get error_try_recover;

  /// No description provided for @pet_profile_save_success.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get pet_profile_save_success;

  /// No description provided for @pet_action_save_profile.
  ///
  /// In en, this message translates to:
  /// **'SAVE PROFILE'**
  String get pet_action_save_profile;

  /// No description provided for @pet_metric_title.
  ///
  /// In en, this message translates to:
  /// **'Clinical Metrics'**
  String get pet_metric_title;

  /// No description provided for @pet_metric_section_vitals.
  ///
  /// In en, this message translates to:
  /// **'1. Vital and Clinical Signs'**
  String get pet_metric_section_vitals;

  /// No description provided for @pet_metric_weight.
  ///
  /// In en, this message translates to:
  /// **'Body Weight (kg)'**
  String get pet_metric_weight;

  /// No description provided for @pet_metric_bpm.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate (BPM)'**
  String get pet_metric_bpm;

  /// No description provided for @pet_metric_mpm.
  ///
  /// In en, this message translates to:
  /// **'Respiratory Rate (MPM)'**
  String get pet_metric_mpm;

  /// No description provided for @pet_metric_temp.
  ///
  /// In en, this message translates to:
  /// **'Rectal Temperature (°C)'**
  String get pet_metric_temp;

  /// No description provided for @pet_metric_tpc.
  ///
  /// In en, this message translates to:
  /// **'Capillary Refill Time (Secs)'**
  String get pet_metric_tpc;

  /// No description provided for @pet_metric_glycemia.
  ///
  /// In en, this message translates to:
  /// **'Glycemia Level (mg/dL)'**
  String get pet_metric_glycemia;

  /// No description provided for @pet_metric_section_structure.
  ///
  /// In en, this message translates to:
  /// **'2. Structure and Composition'**
  String get pet_metric_section_structure;

  /// No description provided for @pet_metric_ecc.
  ///
  /// In en, this message translates to:
  /// **'Body Condition Score (1 to 9)'**
  String get pet_metric_ecc;

  /// No description provided for @pet_metric_abd_circ.
  ///
  /// In en, this message translates to:
  /// **'Abdominal Circumference (cm)'**
  String get pet_metric_abd_circ;

  /// No description provided for @pet_metric_neck_circ.
  ///
  /// In en, this message translates to:
  /// **'Neck Circumference (cm)'**
  String get pet_metric_neck_circ;

  /// No description provided for @pet_metric_height.
  ///
  /// In en, this message translates to:
  /// **'Height at Withers (cm)'**
  String get pet_metric_height;

  /// No description provided for @pet_metric_section_hydration.
  ///
  /// In en, this message translates to:
  /// **'3. Hydration and Excretion'**
  String get pet_metric_section_hydration;

  /// No description provided for @pet_metric_water.
  ///
  /// In en, this message translates to:
  /// **'Water Intake (ml/24h)'**
  String get pet_metric_water;

  /// No description provided for @pet_metric_urine_vol.
  ///
  /// In en, this message translates to:
  /// **'Urinary Volume (ml or Text)'**
  String get pet_metric_urine_vol;

  /// No description provided for @pet_metric_urine_dens.
  ///
  /// In en, this message translates to:
  /// **'Urine Specific Gravity'**
  String get pet_metric_urine_dens;

  /// No description provided for @pet_metric_section_activity.
  ///
  /// In en, this message translates to:
  /// **'4. Activity and Biometrics'**
  String get pet_metric_section_activity;

  /// No description provided for @pet_metric_distance.
  ///
  /// In en, this message translates to:
  /// **'Distance Traveled (km)'**
  String get pet_metric_distance;

  /// No description provided for @pet_metric_speed.
  ///
  /// In en, this message translates to:
  /// **'Average Speed (km/h)'**
  String get pet_metric_speed;

  /// No description provided for @pet_metric_sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep/Rest Time (hours)'**
  String get pet_metric_sleep;

  /// No description provided for @pet_metric_stand_latency.
  ///
  /// In en, this message translates to:
  /// **'Stand Latency (seconds)'**
  String get pet_metric_stand_latency;

  /// No description provided for @pet_metric_save_success.
  ///
  /// In en, this message translates to:
  /// **'Metrics saved successfully!'**
  String get pet_metric_save_success;

  /// No description provided for @pet_metric_source_clinical.
  ///
  /// In en, this message translates to:
  /// **'Origin: Recorded in Clinical Metrics'**
  String get pet_metric_source_clinical;

  /// No description provided for @pet_metric_empty_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in at least one metric.'**
  String get pet_metric_empty_fields;

  /// No description provided for @pet_not_found.
  ///
  /// In en, this message translates to:
  /// **'Pet not found'**
  String get pet_not_found;

  /// No description provided for @pet_analyses_title.
  ///
  /// In en, this message translates to:
  /// **'Analyses: {name}'**
  String pet_analyses_title(Object name);

  /// No description provided for @pet_profile_title_dynamic.
  ///
  /// In en, this message translates to:
  /// **'Profile: {name}'**
  String pet_profile_title_dynamic(Object name);

  /// No description provided for @pet_health_title.
  ///
  /// In en, this message translates to:
  /// **'Health: {name}'**
  String pet_health_title(Object name);

  /// No description provided for @pet_health_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Health Plan: {name}'**
  String pet_health_plan_title(Object name);

  /// No description provided for @pet_funeral_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Funeral Plan: {name}'**
  String pet_funeral_plan_title(Object name);

  /// No description provided for @pet_analysis_title.
  ///
  /// In en, this message translates to:
  /// **'New Profile: {name}'**
  String pet_analysis_title(Object name);

  /// No description provided for @label_file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get label_file;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @pet_agenda_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get pet_agenda_dialog_title;

  /// No description provided for @pet_agenda_dialog_walk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get pet_agenda_dialog_walk;

  /// No description provided for @pet_agenda_dialog_appointment.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get pet_agenda_dialog_appointment;

  /// No description provided for @pet_appointment_screen_title.
  ///
  /// In en, this message translates to:
  /// **'New Appointment'**
  String get pet_appointment_screen_title;

  /// No description provided for @pet_appointment_label_professional.
  ///
  /// In en, this message translates to:
  /// **'Professional/Place'**
  String get pet_appointment_label_professional;

  /// No description provided for @pet_appointment_save_success.
  ///
  /// In en, this message translates to:
  /// **'Appointment scheduled!'**
  String get pet_appointment_save_success;

  /// No description provided for @pet_appointment_type_vaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get pet_appointment_type_vaccine;

  /// No description provided for @pet_appointment_type_consultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get pet_appointment_type_consultation;

  /// No description provided for @pet_appointment_type_grooming.
  ///
  /// In en, this message translates to:
  /// **'Grooming'**
  String get pet_appointment_type_grooming;

  /// No description provided for @pet_appointment_type_exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get pet_appointment_type_exam;

  /// No description provided for @pet_scheduled_list_title.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get pet_scheduled_list_title;

  /// No description provided for @pet_scheduled_empty.
  ///
  /// In en, this message translates to:
  /// **'No future appointments.'**
  String get pet_scheduled_empty;

  /// No description provided for @pet_notification_label.
  ///
  /// In en, this message translates to:
  /// **'Notify in Advance'**
  String get pet_notification_label;

  /// No description provided for @pet_notification_1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get pet_notification_1h;

  /// No description provided for @pet_notification_2h.
  ///
  /// In en, this message translates to:
  /// **'2 hours before'**
  String get pet_notification_2h;

  /// No description provided for @pet_notification_1d.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get pet_notification_1d;

  /// No description provided for @pet_notification_2d.
  ///
  /// In en, this message translates to:
  /// **'2 days before'**
  String get pet_notification_2d;

  /// No description provided for @pet_notification_1w.
  ///
  /// In en, this message translates to:
  /// **'1 week before'**
  String get pet_notification_1w;

  /// No description provided for @pet_notification_none.
  ///
  /// In en, this message translates to:
  /// **'No notification'**
  String get pet_notification_none;

  /// No description provided for @pet_delete_confirmation_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get pet_delete_confirmation_title;

  /// No description provided for @pet_appointment_tab_data.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get pet_appointment_tab_data;

  /// No description provided for @pet_appointment_tab_partner.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get pet_appointment_tab_partner;

  /// No description provided for @pet_appointment_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment'**
  String get pet_appointment_edit;

  /// No description provided for @pet_appointment_outcome.
  ///
  /// In en, this message translates to:
  /// **'Register Outcome'**
  String get pet_appointment_outcome;

  /// No description provided for @pet_appointment_outcome_title.
  ///
  /// In en, this message translates to:
  /// **'Event Outcome'**
  String get pet_appointment_outcome_title;

  /// No description provided for @pet_appointment_outcome_hint.
  ///
  /// In en, this message translates to:
  /// **'What happened during the appointment? Add notes, recommendations, etc.'**
  String get pet_appointment_outcome_hint;

  /// No description provided for @pet_appointment_outcome_save.
  ///
  /// In en, this message translates to:
  /// **'Save Outcome'**
  String get pet_appointment_outcome_save;

  /// No description provided for @parse_part.
  ///
  /// In en, this message translates to:
  /// **'PART '**
  String get parse_part;

  /// No description provided for @parse_title_en.
  ///
  /// In en, this message translates to:
  /// **'TITLE:'**
  String get parse_title_en;

  /// No description provided for @parse_title_pt.
  ///
  /// In en, this message translates to:
  /// **'TÍTULO:'**
  String get parse_title_pt;

  /// No description provided for @parse_content_en.
  ///
  /// In en, this message translates to:
  /// **'CONTENT:'**
  String get parse_content_en;

  /// No description provided for @parse_content_pt.
  ///
  /// In en, this message translates to:
  /// **'CONTEÚDO:'**
  String get parse_content_pt;

  /// No description provided for @parse_icon_en.
  ///
  /// In en, this message translates to:
  /// **'ICON:'**
  String get parse_icon_en;

  /// No description provided for @parse_icon_pt.
  ///
  /// In en, this message translates to:
  /// **'ÍCONE:'**
  String get parse_icon_pt;

  /// No description provided for @pdf_preview_title.
  ///
  /// In en, this message translates to:
  /// **'PDF Preview'**
  String get pdf_preview_title;

  /// No description provided for @pdf_button_generate.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get pdf_button_generate;

  /// No description provided for @tech_true.
  ///
  /// In en, this message translates to:
  /// **'true'**
  String get tech_true;

  /// No description provided for @tech_is_friend.
  ///
  /// In en, this message translates to:
  /// **'is_friend'**
  String get tech_is_friend;

  /// No description provided for @tech_tutor_name.
  ///
  /// In en, this message translates to:
  /// **'tutor_name'**
  String get tech_tutor_name;

  /// No description provided for @tech_my_pet_name.
  ///
  /// In en, this message translates to:
  /// **'my_pet_name'**
  String get tech_my_pet_name;

  /// No description provided for @tech_is_new_friend.
  ///
  /// In en, this message translates to:
  /// **'is_new_friend'**
  String get tech_is_new_friend;

  /// No description provided for @tech_title.
  ///
  /// In en, this message translates to:
  /// **'title'**
  String get tech_title;

  /// No description provided for @tech_icon.
  ///
  /// In en, this message translates to:
  /// **'icon'**
  String get tech_icon;

  /// No description provided for @tech_content.
  ///
  /// In en, this message translates to:
  /// **'content'**
  String get tech_content;

  /// No description provided for @tech_warning.
  ///
  /// In en, this message translates to:
  /// **'warning'**
  String get tech_warning;

  /// No description provided for @tech_identification.
  ///
  /// In en, this message translates to:
  /// **'identificação'**
  String get tech_identification;

  /// No description provided for @tech_analysis.
  ///
  /// In en, this message translates to:
  /// **'análise'**
  String get tech_analysis;

  /// No description provided for @tech_plant.
  ///
  /// In en, this message translates to:
  /// **'plant'**
  String get tech_plant;

  /// No description provided for @tech_health.
  ///
  /// In en, this message translates to:
  /// **'saúde'**
  String get tech_health;

  /// No description provided for @tech_dental.
  ///
  /// In en, this message translates to:
  /// **'dental'**
  String get tech_dental;

  /// No description provided for @tech_skin.
  ///
  /// In en, this message translates to:
  /// **'skin'**
  String get tech_skin;

  /// No description provided for @tech_dermatology.
  ///
  /// In en, this message translates to:
  /// **'dermatology'**
  String get tech_dermatology;

  /// No description provided for @tech_fur.
  ///
  /// In en, this message translates to:
  /// **'fur'**
  String get tech_fur;

  /// No description provided for @tech_ears.
  ///
  /// In en, this message translates to:
  /// **'ears'**
  String get tech_ears;

  /// No description provided for @tech_stool.
  ///
  /// In en, this message translates to:
  /// **'stool'**
  String get tech_stool;

  /// No description provided for @tech_feces.
  ///
  /// In en, this message translates to:
  /// **'feces'**
  String get tech_feces;

  /// No description provided for @tech_gastro.
  ///
  /// In en, this message translates to:
  /// **'gastro'**
  String get tech_gastro;

  /// No description provided for @tech_posture.
  ///
  /// In en, this message translates to:
  /// **'posture'**
  String get tech_posture;

  /// No description provided for @tech_body.
  ///
  /// In en, this message translates to:
  /// **'body'**
  String get tech_body;

  /// No description provided for @tech_vocal.
  ///
  /// In en, this message translates to:
  /// **'vocal'**
  String get tech_vocal;

  /// No description provided for @tech_behavior.
  ///
  /// In en, this message translates to:
  /// **'behavior'**
  String get tech_behavior;

  /// No description provided for @tech_walk.
  ///
  /// In en, this message translates to:
  /// **'walk'**
  String get tech_walk;

  /// No description provided for @tech_exercise.
  ///
  /// In en, this message translates to:
  /// **'exercise'**
  String get tech_exercise;

  /// No description provided for @tech_activity.
  ///
  /// In en, this message translates to:
  /// **'activity'**
  String get tech_activity;

  /// No description provided for @tech_chat.
  ///
  /// In en, this message translates to:
  /// **'chat'**
  String get tech_chat;

  /// No description provided for @tech_ai_chat.
  ///
  /// In en, this message translates to:
  /// **'ai_chat'**
  String get tech_ai_chat;

  /// No description provided for @tech_message.
  ///
  /// In en, this message translates to:
  /// **'message'**
  String get tech_message;

  /// No description provided for @tech_foodbowl.
  ///
  /// In en, this message translates to:
  /// **'foodbowl'**
  String get tech_foodbowl;

  /// No description provided for @tech_food_bowl.
  ///
  /// In en, this message translates to:
  /// **'food_bowl'**
  String get tech_food_bowl;

  /// No description provided for @tech_nutrition.
  ///
  /// In en, this message translates to:
  /// **'nutrition'**
  String get tech_nutrition;

  /// No description provided for @tech_lab.
  ///
  /// In en, this message translates to:
  /// **'lab'**
  String get tech_lab;

  /// No description provided for @tech_label.
  ///
  /// In en, this message translates to:
  /// **'label'**
  String get tech_label;

  /// No description provided for @tech_plantcheck.
  ///
  /// In en, this message translates to:
  /// **'plantcheck'**
  String get tech_plantcheck;

  /// No description provided for @tech_newprofile.
  ///
  /// In en, this message translates to:
  /// **'newprofile'**
  String get tech_newprofile;

  /// No description provided for @tech_general.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get tech_general;

  /// No description provided for @tech_health_summary.
  ///
  /// In en, this message translates to:
  /// **'health_summary'**
  String get tech_health_summary;

  /// No description provided for @tech_other.
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get tech_other;

  /// No description provided for @tech_clinical_summary.
  ///
  /// In en, this message translates to:
  /// **'clinical_summary'**
  String get tech_clinical_summary;

  /// No description provided for @tech_ai_analysis.
  ///
  /// In en, this message translates to:
  /// **'ai_analysis'**
  String get tech_ai_analysis;

  /// No description provided for @tech_friend.
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get tech_friend;

  /// No description provided for @tech_friend_detection.
  ///
  /// In en, this message translates to:
  /// **'friend_detection'**
  String get tech_friend_detection;

  /// No description provided for @tech_nutrition_analysis.
  ///
  /// In en, this message translates to:
  /// **'nutrition_analysis'**
  String get tech_nutrition_analysis;

  /// No description provided for @tech_eyes.
  ///
  /// In en, this message translates to:
  /// **'eyes'**
  String get tech_eyes;

  /// No description provided for @tech_mouth.
  ///
  /// In en, this message translates to:
  /// **'mouth'**
  String get tech_mouth;

  /// No description provided for @tech_lab_result.
  ///
  /// In en, this message translates to:
  /// **'lab_result'**
  String get tech_lab_result;

  /// No description provided for @tech_scannut_report.
  ///
  /// In en, this message translates to:
  /// **'ScanNut_Report_'**
  String get tech_scannut_report;

  /// No description provided for @tech_pdf_ext.
  ///
  /// In en, this message translates to:
  /// **'.pdf'**
  String get tech_pdf_ext;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @pdf_footer_text.
  ///
  /// In en, this message translates to:
  /// **'© 2026 ScanNut Multiverso Digital | contato@multiversodigital.com.br'**
  String get pdf_footer_text;

  /// No description provided for @pdf_page_label.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pdf_page_label;

  /// No description provided for @pdf_of_label.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get pdf_of_label;

  /// No description provided for @source_analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get source_analysis;

  /// No description provided for @source_walk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get source_walk;

  /// No description provided for @source_appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get source_appointment;

  /// No description provided for @source_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get source_nutrition;

  /// No description provided for @source_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get source_health;

  /// No description provided for @source_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get source_profile;

  /// No description provided for @source_journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get source_journal;

  /// No description provided for @pet_appointment_type_vermifuge.
  ///
  /// In en, this message translates to:
  /// **'Deworming/Flea Control'**
  String get pet_appointment_type_vermifuge;

  /// No description provided for @pet_appointment_type_medication.
  ///
  /// In en, this message translates to:
  /// **'Continuous Medication'**
  String get pet_appointment_type_medication;

  /// No description provided for @pet_appointment_type_training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get pet_appointment_type_training;

  /// No description provided for @pet_appointment_type_daycare.
  ///
  /// In en, this message translates to:
  /// **'Daycare'**
  String get pet_appointment_type_daycare;

  /// No description provided for @pet_appointment_type_nails_ears.
  ///
  /// In en, this message translates to:
  /// **'Nails/Ears Cleaning'**
  String get pet_appointment_type_nails_ears;

  /// No description provided for @pet_appointment_type_dental.
  ///
  /// In en, this message translates to:
  /// **'Teeth Brushing'**
  String get pet_appointment_type_dental;

  /// No description provided for @pet_appointment_type_food_change.
  ///
  /// In en, this message translates to:
  /// **'Food Change'**
  String get pet_appointment_type_food_change;

  /// No description provided for @pet_appointment_type_travel.
  ///
  /// In en, this message translates to:
  /// **'Pet Friendly Travel'**
  String get pet_appointment_type_travel;

  /// No description provided for @pet_appointment_type_accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories Change'**
  String get pet_appointment_type_accessories;

  /// No description provided for @pet_appointment_cat_health.
  ///
  /// In en, this message translates to:
  /// **'Health (Essential)'**
  String get pet_appointment_cat_health;

  /// No description provided for @pet_appointment_cat_wellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness & Aesthetics'**
  String get pet_appointment_cat_wellness;

  /// No description provided for @pet_appointment_cat_behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior & Training'**
  String get pet_appointment_cat_behavior;

  /// No description provided for @pet_appointment_cat_services.
  ///
  /// In en, this message translates to:
  /// **'Extra Services'**
  String get pet_appointment_cat_services;

  /// No description provided for @pet_appointment_cat_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get pet_appointment_cat_nutrition;

  /// No description provided for @pet_appointment_cat_docs.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get pet_appointment_cat_docs;

  /// No description provided for @pet_apt_consultation_general.
  ///
  /// In en, this message translates to:
  /// **'General Practitioner'**
  String get pet_apt_consultation_general;

  /// No description provided for @pet_apt_consultation_return.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get pet_apt_consultation_return;

  /// No description provided for @pet_apt_consultation_specialist.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get pet_apt_consultation_specialist;

  /// No description provided for @pet_apt_consultation_tele.
  ///
  /// In en, this message translates to:
  /// **'Teleconsultation'**
  String get pet_apt_consultation_tele;

  /// No description provided for @pet_apt_vaccine_annual.
  ///
  /// In en, this message translates to:
  /// **'Annual Vaccine'**
  String get pet_apt_vaccine_annual;

  /// No description provided for @pet_apt_vaccine_specific.
  ///
  /// In en, this message translates to:
  /// **'Specific Vaccine'**
  String get pet_apt_vaccine_specific;

  /// No description provided for @pet_apt_vaccine_booster.
  ///
  /// In en, this message translates to:
  /// **'Booster'**
  String get pet_apt_vaccine_booster;

  /// No description provided for @pet_apt_exam_blood.
  ///
  /// In en, this message translates to:
  /// **'Complete Blood Count'**
  String get pet_apt_exam_blood;

  /// No description provided for @pet_apt_exam_ultrasound.
  ///
  /// In en, this message translates to:
  /// **'Ultrasound'**
  String get pet_apt_exam_ultrasound;

  /// No description provided for @pet_apt_exam_xray.
  ///
  /// In en, this message translates to:
  /// **'X-Ray'**
  String get pet_apt_exam_xray;

  /// No description provided for @pet_apt_exam_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab Exam'**
  String get pet_apt_exam_lab;

  /// No description provided for @pet_apt_exam_periodic.
  ///
  /// In en, this message translates to:
  /// **'Periodic'**
  String get pet_apt_exam_periodic;

  /// No description provided for @pet_apt_procedure_castration.
  ///
  /// In en, this message translates to:
  /// **'Neutering/Spaying'**
  String get pet_apt_procedure_castration;

  /// No description provided for @pet_apt_procedure_surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get pet_apt_procedure_surgery;

  /// No description provided for @pet_apt_procedure_dental.
  ///
  /// In en, this message translates to:
  /// **'Dental Cleaning'**
  String get pet_apt_procedure_dental;

  /// No description provided for @pet_apt_procedure_dressing.
  ///
  /// In en, this message translates to:
  /// **'Dressing Change'**
  String get pet_apt_procedure_dressing;

  /// No description provided for @pet_apt_treatment_physio.
  ///
  /// In en, this message translates to:
  /// **'Physiotherapy'**
  String get pet_apt_treatment_physio;

  /// No description provided for @pet_apt_treatment_acu.
  ///
  /// In en, this message translates to:
  /// **'Acupuncture'**
  String get pet_apt_treatment_acu;

  /// No description provided for @pet_apt_treatment_chemo.
  ///
  /// In en, this message translates to:
  /// **'Chemotherapy'**
  String get pet_apt_treatment_chemo;

  /// No description provided for @pet_apt_treatment_hemo.
  ///
  /// In en, this message translates to:
  /// **'Hemodialysis'**
  String get pet_apt_treatment_hemo;

  /// No description provided for @pet_apt_wellness_bath.
  ///
  /// In en, this message translates to:
  /// **'Bath'**
  String get pet_apt_wellness_bath;

  /// No description provided for @pet_apt_wellness_grooming.
  ///
  /// In en, this message translates to:
  /// **'Grooming'**
  String get pet_apt_wellness_grooming;

  /// No description provided for @pet_apt_wellness_hygienic.
  ///
  /// In en, this message translates to:
  /// **'Hygienic Trim'**
  String get pet_apt_wellness_hygienic;

  /// No description provided for @pet_apt_wellness_hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get pet_apt_wellness_hydration;

  /// No description provided for @pet_apt_wellness_daycare.
  ///
  /// In en, this message translates to:
  /// **'Day Care'**
  String get pet_apt_wellness_daycare;

  /// No description provided for @pet_apt_wellness_hotel.
  ///
  /// In en, this message translates to:
  /// **'Pet Hotel'**
  String get pet_apt_wellness_hotel;

  /// No description provided for @pet_apt_behavior_training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get pet_apt_behavior_training;

  /// No description provided for @pet_apt_behavior_evaluation.
  ///
  /// In en, this message translates to:
  /// **'Behavioral Eval'**
  String get pet_apt_behavior_evaluation;

  /// No description provided for @pet_apt_behavior_social.
  ///
  /// In en, this message translates to:
  /// **'Socialization'**
  String get pet_apt_behavior_social;

  /// No description provided for @pet_apt_service_taxi.
  ///
  /// In en, this message translates to:
  /// **'Pet Taxi'**
  String get pet_apt_service_taxi;

  /// No description provided for @pet_apt_service_delivery.
  ///
  /// In en, this message translates to:
  /// **'Food Delivery'**
  String get pet_apt_service_delivery;

  /// No description provided for @pet_apt_nutrition_meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get pet_apt_nutrition_meal;

  /// No description provided for @pet_apt_nutrition_food_change.
  ///
  /// In en, this message translates to:
  /// **'Food Change'**
  String get pet_apt_nutrition_food_change;

  /// No description provided for @pet_apt_service_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Consult'**
  String get pet_apt_service_nutrition;

  /// No description provided for @pet_apt_service_mealplan.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get pet_apt_service_mealplan;

  /// No description provided for @pet_apt_doc_vaccine_card.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Card Renewal'**
  String get pet_apt_doc_vaccine_card;

  /// No description provided for @pet_apt_doc_health_cert.
  ///
  /// In en, this message translates to:
  /// **'Health Certificate'**
  String get pet_apt_doc_health_cert;

  /// No description provided for @pet_apt_doc_microchip.
  ///
  /// In en, this message translates to:
  /// **'Microchipping'**
  String get pet_apt_doc_microchip;

  /// No description provided for @pet_apt_doc_gta.
  ///
  /// In en, this message translates to:
  /// **'Animal Transit Guide'**
  String get pet_apt_doc_gta;

  /// No description provided for @pet_apt_doc_travel.
  ///
  /// In en, this message translates to:
  /// **'Travel Docs'**
  String get pet_apt_doc_travel;

  /// No description provided for @pet_apt_select_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get pet_apt_select_category;

  /// No description provided for @pet_apt_select_type.
  ///
  /// In en, this message translates to:
  /// **'Appointment Type'**
  String get pet_apt_select_type;

  /// No description provided for @source_friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get source_friend;

  /// No description provided for @pet_event_plant.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get pet_event_plant;

  /// No description provided for @pet_nutrition_copy_action.
  ///
  /// In en, this message translates to:
  /// **'Copy meals to agenda'**
  String get pet_nutrition_copy_action;

  /// No description provided for @pet_nutrition_select_start_date.
  ///
  /// In en, this message translates to:
  /// **'Select start date (Monday)'**
  String get pet_nutrition_select_start_date;

  /// No description provided for @pet_nutrition_copy_success.
  ///
  /// In en, this message translates to:
  /// **'Meals copied to agenda!'**
  String get pet_nutrition_copy_success;

  /// No description provided for @pet_nutrition_copy_error.
  ///
  /// In en, this message translates to:
  /// **'Error copying. Check plan format.'**
  String get pet_nutrition_copy_error;

  /// No description provided for @pet_plan_nutritional.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Plan'**
  String get pet_plan_nutritional;

  /// No description provided for @pet_walk_summary_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Walk Summary 🐾'**
  String get pet_walk_summary_dialog_title;

  /// No description provided for @pet_walk_summary_dialog_desc.
  ///
  /// In en, this message translates to:
  /// **'Select the interval to generate AI summary.'**
  String get pet_walk_summary_dialog_desc;

  /// No description provided for @pet_label_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get pet_label_start;

  /// No description provided for @pet_label_end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get pet_label_end;

  /// No description provided for @pet_action_generate_summary.
  ///
  /// In en, this message translates to:
  /// **'Generate Summary'**
  String get pet_action_generate_summary;

  /// No description provided for @pet_error_fetch_events.
  ///
  /// In en, this message translates to:
  /// **'Error fetching events.'**
  String get pet_error_fetch_events;

  /// No description provided for @pet_error_no_events_period.
  ///
  /// In en, this message translates to:
  /// **'No events found in this period.'**
  String get pet_error_no_events_period;

  /// No description provided for @pet_msg_summary_success.
  ///
  /// In en, this message translates to:
  /// **'Summary generated and saved successfully! 🐾'**
  String get pet_msg_summary_success;

  /// No description provided for @pet_walk_empty_history.
  ///
  /// In en, this message translates to:
  /// **'No walks recorded.'**
  String get pet_walk_empty_history;

  /// No description provided for @pet_walk_summary_title_generated.
  ///
  /// In en, this message translates to:
  /// **'Summary {start} - {end}'**
  String pet_walk_summary_title_generated(String start, String end);

  /// No description provided for @pet_msg_google_simulated.
  ///
  /// In en, this message translates to:
  /// **'Google Data (Simulated) added!'**
  String get pet_msg_google_simulated;

  /// No description provided for @pet_title_ophthalmology.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology'**
  String get pet_title_ophthalmology;

  /// No description provided for @pet_title_dental.
  ///
  /// In en, this message translates to:
  /// **'Dental Health'**
  String get pet_title_dental;

  /// No description provided for @pet_title_dermatology.
  ///
  /// In en, this message translates to:
  /// **'Skin & Coat'**
  String get pet_title_dermatology;

  /// No description provided for @pet_title_ears.
  ///
  /// In en, this message translates to:
  /// **'Ears'**
  String get pet_title_ears;

  /// No description provided for @pet_title_digestion.
  ///
  /// In en, this message translates to:
  /// **'Digestion'**
  String get pet_title_digestion;

  /// No description provided for @pet_title_body_condition.
  ///
  /// In en, this message translates to:
  /// **'Body Condition'**
  String get pet_title_body_condition;

  /// No description provided for @pet_title_vocalization.
  ///
  /// In en, this message translates to:
  /// **'Vocalization'**
  String get pet_title_vocalization;

  /// No description provided for @pet_title_behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get pet_title_behavior;

  /// No description provided for @pet_title_walk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get pet_title_walk;

  /// No description provided for @pet_title_ai_chat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get pet_title_ai_chat;

  /// No description provided for @pet_title_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get pet_title_nutrition;

  /// No description provided for @pet_title_lab.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get pet_title_lab;

  /// No description provided for @pet_title_label_analysis.
  ///
  /// In en, this message translates to:
  /// **'Label Analysis'**
  String get pet_title_label_analysis;

  /// No description provided for @pet_title_plants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get pet_title_plants;

  /// No description provided for @pet_title_initial_eval.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get pet_title_initial_eval;

  /// No description provided for @pet_title_health_summary.
  ///
  /// In en, this message translates to:
  /// **'Health Summary'**
  String get pet_title_health_summary;

  /// No description provided for @pet_title_general_checkup.
  ///
  /// In en, this message translates to:
  /// **'General Check-up'**
  String get pet_title_general_checkup;

  /// No description provided for @pet_title_clinical_summary.
  ///
  /// In en, this message translates to:
  /// **'Clinical Summary'**
  String get pet_title_clinical_summary;

  /// No description provided for @pet_action_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get pet_action_nutrition;

  /// No description provided for @pet_nutrition_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get pet_nutrition_screen_title;

  /// No description provided for @pet_title_planned_meal.
  ///
  /// In en, this message translates to:
  /// **'Planned Meal'**
  String get pet_title_planned_meal;

  /// No description provided for @pet_record_medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get pet_record_medication;

  /// No description provided for @pet_record_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get pet_record_weight;

  /// No description provided for @pet_record_energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get pet_record_energy;

  /// No description provided for @pet_record_appetite.
  ///
  /// In en, this message translates to:
  /// **'Appetite'**
  String get pet_record_appetite;

  /// No description provided for @pet_record_incident.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get pet_record_incident;

  /// No description provided for @pet_record_expense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get pet_record_expense;

  /// No description provided for @pet_expense_history_title.
  ///
  /// In en, this message translates to:
  /// **'Expense History'**
  String get pet_expense_history_title;

  /// No description provided for @pet_expense_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded.'**
  String get pet_expense_history_empty;

  /// No description provided for @pet_expense_history_item_deleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get pet_expense_history_item_deleted;

  /// No description provided for @pet_record_other.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get pet_record_other;

  /// No description provided for @pet_field_drug_name.
  ///
  /// In en, this message translates to:
  /// **'Drug Name'**
  String get pet_field_drug_name;

  /// No description provided for @pet_field_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get pet_field_category;

  /// No description provided for @pet_field_dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get pet_field_dosage;

  /// No description provided for @pet_field_unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get pet_field_unit;

  /// No description provided for @pet_field_time.
  ///
  /// In en, this message translates to:
  /// **'Actual Time'**
  String get pet_field_time;

  /// No description provided for @pet_field_amount_money.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get pet_field_amount_money;

  /// No description provided for @pet_field_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get pet_field_currency;

  /// No description provided for @pet_field_observation.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get pet_field_observation;

  /// No description provided for @pet_field_mass.
  ///
  /// In en, this message translates to:
  /// **'Mass'**
  String get pet_field_mass;

  /// No description provided for @pet_field_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get pet_field_location;

  /// No description provided for @pet_field_energy_level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get pet_field_energy_level;

  /// No description provided for @pet_field_period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get pet_field_period;

  /// No description provided for @pet_field_context.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get pet_field_context;

  /// No description provided for @pet_field_consumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get pet_field_consumption;

  /// No description provided for @pet_field_thirst.
  ///
  /// In en, this message translates to:
  /// **'Thirst'**
  String get pet_field_thirst;

  /// No description provided for @pet_field_diet_variation.
  ///
  /// In en, this message translates to:
  /// **'Diet Variation'**
  String get pet_field_diet_variation;

  /// No description provided for @pet_field_severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get pet_field_severity;

  /// No description provided for @pet_field_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get pet_field_description;

  /// No description provided for @pet_field_symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get pet_field_symptoms;

  /// No description provided for @pet_field_action_taken.
  ///
  /// In en, this message translates to:
  /// **'Action Taken'**
  String get pet_field_action_taken;

  /// No description provided for @pet_field_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pet_field_type;

  /// No description provided for @pet_field_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get pet_field_details;

  /// No description provided for @pet_opt_continuous.
  ///
  /// In en, this message translates to:
  /// **'Continuous'**
  String get pet_opt_continuous;

  /// No description provided for @pet_opt_wormer.
  ///
  /// In en, this message translates to:
  /// **'Dewormer'**
  String get pet_opt_wormer;

  /// No description provided for @pet_opt_flea.
  ///
  /// In en, this message translates to:
  /// **'Flea Control'**
  String get pet_opt_flea;

  /// No description provided for @pet_opt_antibiotic.
  ///
  /// In en, this message translates to:
  /// **'Antibiotic'**
  String get pet_opt_antibiotic;

  /// No description provided for @pet_opt_low.
  ///
  /// In en, this message translates to:
  /// **'Low/Apathetic'**
  String get pet_opt_low;

  /// No description provided for @pet_opt_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get pet_opt_normal;

  /// No description provided for @pet_opt_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get pet_opt_active;

  /// No description provided for @pet_opt_hyper.
  ///
  /// In en, this message translates to:
  /// **'Hyperactive'**
  String get pet_opt_hyper;

  /// No description provided for @pet_opt_morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get pet_opt_morning;

  /// No description provided for @pet_opt_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get pet_opt_afternoon;

  /// No description provided for @pet_opt_night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get pet_opt_night;

  /// No description provided for @pet_opt_all_day.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get pet_opt_all_day;

  /// No description provided for @pet_opt_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get pet_opt_none;

  /// No description provided for @pet_opt_half.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get pet_opt_half;

  /// No description provided for @pet_opt_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pet_opt_all;

  /// No description provided for @pet_opt_reduced.
  ///
  /// In en, this message translates to:
  /// **'Reduced'**
  String get pet_opt_reduced;

  /// No description provided for @pet_opt_excessive.
  ///
  /// In en, this message translates to:
  /// **'Excessive'**
  String get pet_opt_excessive;

  /// No description provided for @pet_opt_mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get pet_opt_mild;

  /// No description provided for @pet_opt_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get pet_opt_moderate;

  /// No description provided for @pet_opt_urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get pet_opt_urgent;

  /// No description provided for @pet_opt_hygiene.
  ///
  /// In en, this message translates to:
  /// **'Hygiene'**
  String get pet_opt_hygiene;

  /// No description provided for @pet_opt_estrus.
  ///
  /// In en, this message translates to:
  /// **'Estrus/Reproduction'**
  String get pet_opt_estrus;

  /// No description provided for @pet_opt_social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get pet_opt_social;

  /// No description provided for @pet_record_save_success.
  ///
  /// In en, this message translates to:
  /// **'Record saved successfully!'**
  String get pet_record_save_success;

  /// No description provided for @pet_record_save_error.
  ///
  /// In en, this message translates to:
  /// **'Error saving record.'**
  String get pet_record_save_error;

  /// No description provided for @help_ia_pet_pillars_title.
  ///
  /// In en, this message translates to:
  /// **'Inteligência Pet ScanNut+'**
  String get help_ia_pet_pillars_title;

  /// No description provided for @help_pillar_analysis_title.
  ///
  /// In en, this message translates to:
  /// **'Image and Video Analysis'**
  String get help_pillar_analysis_title;

  /// No description provided for @help_pillar_analysis_desc.
  ///
  /// In en, this message translates to:
  /// **'Our AI processes photos and videos to identify subtle signs of health, posture, and behavior in your pet.'**
  String get help_pillar_analysis_desc;

  /// No description provided for @help_pillar_walks_title.
  ///
  /// In en, this message translates to:
  /// **'Walk Monitoring'**
  String get help_pillar_walks_title;

  /// No description provided for @help_pillar_walks_desc.
  ///
  /// In en, this message translates to:
  /// **'Record of what happens during walks, monitoring energy levels, interactions, and predictive routes.'**
  String get help_pillar_walks_desc;

  /// No description provided for @help_pillar_agenda_title.
  ///
  /// In en, this message translates to:
  /// **'Agenda and Occurrences'**
  String get help_pillar_agenda_title;

  /// No description provided for @help_pillar_agenda_desc.
  ///
  /// In en, this message translates to:
  /// **'Central hub for appointments and daily records: medication, weight, incidents, and analysis history in one place.'**
  String get help_pillar_agenda_desc;

  /// No description provided for @help_pillar_nutrition_title.
  ///
  /// In en, this message translates to:
  /// **'Smart Nutrition'**
  String get help_pillar_nutrition_title;

  /// No description provided for @help_pillar_nutrition_desc.
  ///
  /// In en, this message translates to:
  /// **'Generation of personalized menus and automatic inclusion of meals in the daily agenda for consumption tracking.'**
  String get help_pillar_nutrition_desc;

  /// No description provided for @help_pillar_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile and Documentation'**
  String get help_pillar_profile_title;

  /// No description provided for @help_pillar_profile_desc.
  ///
  /// In en, this message translates to:
  /// **'Pet data, health plans, funeral plans, and storage of important documents for quick access.'**
  String get help_pillar_profile_desc;

  /// No description provided for @pet_agenda_tab_history_label.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get pet_agenda_tab_history_label;

  /// No description provided for @pet_agenda_tab_records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get pet_agenda_tab_records;

  /// No description provided for @pet_field_partner_name.
  ///
  /// In en, this message translates to:
  /// **'Place/Professional Name'**
  String get pet_field_partner_name;

  /// No description provided for @pet_field_contact_person.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get pet_field_contact_person;

  /// No description provided for @pet_field_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get pet_field_phone;

  /// No description provided for @pet_field_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get pet_field_whatsapp;

  /// No description provided for @pet_field_email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get pet_field_email;

  /// No description provided for @ai_disclaimer_footer.
  ///
  /// In en, this message translates to:
  /// **'💡 Analysis generated by Gemini technology. Always consult a specialist.'**
  String get ai_disclaimer_footer;

  /// No description provided for @pet_agenda_edit_btn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get pet_agenda_edit_btn;

  /// No description provided for @pet_agenda_outcome_btn.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get pet_agenda_outcome_btn;

  /// No description provided for @pet_field_what_to_do.
  ///
  /// In en, this message translates to:
  /// **'What to do?'**
  String get pet_field_what_to_do;

  /// No description provided for @pet_field_what_was_done.
  ///
  /// In en, this message translates to:
  /// **'What was done?'**
  String get pet_field_what_was_done;

  /// No description provided for @pet_agenda_outcome_title.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get pet_agenda_outcome_title;

  /// No description provided for @pet_agenda_outcome_hint.
  ///
  /// In en, this message translates to:
  /// **'How did it proceed after the analysis? Did it get worse? Better?'**
  String get pet_agenda_outcome_hint;

  /// No description provided for @pet_agenda_outcome_prefix.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get pet_agenda_outcome_prefix;

  /// No description provided for @pet_friend_name_label.
  ///
  /// In en, this message translates to:
  /// **'Friend\'s Name (Pet)'**
  String get pet_friend_name_label;

  /// No description provided for @pet_tutor_name_label.
  ///
  /// In en, this message translates to:
  /// **'Tutor\'s Name'**
  String get pet_tutor_name_label;

  /// No description provided for @pet_friend_new.
  ///
  /// In en, this message translates to:
  /// **'New Friend'**
  String get pet_friend_new;

  /// No description provided for @pet_friend_select.
  ///
  /// In en, this message translates to:
  /// **'Select a friend'**
  String get pet_friend_select;

  /// No description provided for @error_generic_title.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something didn\'t go as expected'**
  String get error_generic_title;

  /// No description provided for @error_generic_message.
  ///
  /// In en, this message translates to:
  /// **'The system had a little technical hiccup. We are already looking into it!'**
  String get error_generic_message;

  /// No description provided for @error_button_retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get error_button_retry;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get error_unknown;

  /// No description provided for @pdf_report_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Report generated automatically by ScanNut+ AI. Always consult a veterinarian.'**
  String get pdf_report_disclaimer;

  /// No description provided for @pdf_analysis_report.
  ///
  /// In en, this message translates to:
  /// **'ANALYSIS REPORT'**
  String get pdf_analysis_report;

  /// No description provided for @pdf_part.
  ///
  /// In en, this message translates to:
  /// **'PART '**
  String get pdf_part;

  /// No description provided for @pdf_references_sources.
  ///
  /// In en, this message translates to:
  /// **'REFERENCES & SOURCES'**
  String get pdf_references_sources;

  /// No description provided for @pdf_title_label.
  ///
  /// In en, this message translates to:
  /// **'TITLE:'**
  String get pdf_title_label;

  /// No description provided for @pdf_content_label.
  ///
  /// In en, this message translates to:
  /// **'CONTENT:'**
  String get pdf_content_label;

  /// No description provided for @pdf_icon_label.
  ///
  /// In en, this message translates to:
  /// **'ICON:'**
  String get pdf_icon_label;

  /// No description provided for @ocr_scan_title.
  ///
  /// In en, this message translates to:
  /// **'Exam Scan'**
  String get ocr_scan_title;

  /// No description provided for @action_generate_pdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get action_generate_pdf;

  /// No description provided for @ocr_extracted_data_title.
  ///
  /// In en, this message translates to:
  /// **'EXTRACTED EXAM DATA'**
  String get ocr_extracted_data_title;

  /// No description provided for @ocr_extracted_item.
  ///
  /// In en, this message translates to:
  /// **'Extracted Data'**
  String get ocr_extracted_item;

  /// No description provided for @ocr_scientific_sources.
  ///
  /// In en, this message translates to:
  /// **'Scientific & Regulatory Sources'**
  String get ocr_scientific_sources;

  /// No description provided for @pdf_unknown_pet.
  ///
  /// In en, this message translates to:
  /// **'Unknown Pet'**
  String get pdf_unknown_pet;

  /// No description provided for @pdf_unknown_breed.
  ///
  /// In en, this message translates to:
  /// **'Unknown Breed'**
  String get pdf_unknown_breed;

  /// No description provided for @pdf_scannut_report.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+ Report'**
  String get pdf_scannut_report;

  /// No description provided for @pdf_scientific_references.
  ///
  /// In en, this message translates to:
  /// **'Scientific References:'**
  String get pdf_scientific_references;

  /// No description provided for @pdf_master_protocol_2026.
  ///
  /// In en, this message translates to:
  /// **'Master Protocol 2026'**
  String get pdf_master_protocol_2026;

  /// No description provided for @pdf_section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get pdf_section;

  /// No description provided for @general_analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get general_analysis;

  /// No description provided for @general_scientific_sources.
  ///
  /// In en, this message translates to:
  /// **'Scientific Sources'**
  String get general_scientific_sources;

  /// No description provided for @help_journal_walk_guide.
  ///
  /// In en, this message translates to:
  /// **'Journal / Walk Guide'**
  String get help_journal_walk_guide;

  /// No description provided for @partner_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get partner_filter_all;

  /// No description provided for @partner_filter_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get partner_filter_health;

  /// No description provided for @partner_filter_hospitality.
  ///
  /// In en, this message translates to:
  /// **'Hospitality'**
  String get partner_filter_hospitality;

  /// No description provided for @partner_filter_aesthetics.
  ///
  /// In en, this message translates to:
  /// **'Aesthetics'**
  String get partner_filter_aesthetics;

  /// No description provided for @partner_filter_education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get partner_filter_education;

  /// No description provided for @partner_filter_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get partner_filter_services;

  /// No description provided for @error_location_disabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get error_location_disabled;

  /// No description provided for @error_location_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get error_location_denied;

  /// No description provided for @error_location_permanently_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get error_location_permanently_denied;

  /// No description provided for @error_fetching_places.
  ///
  /// In en, this message translates to:
  /// **'Error fetching places: {error}'**
  String error_fetching_places(String error);

  /// No description provided for @partner_about.
  ///
  /// In en, this message translates to:
  /// **'About the Partner'**
  String get partner_about;

  /// No description provided for @partner_network_search.
  ///
  /// In en, this message translates to:
  /// **'Network Search'**
  String get partner_network_search;

  /// No description provided for @partner_force_search_restart.
  ///
  /// In en, this message translates to:
  /// **'Force search restart'**
  String get partner_force_search_restart;

  /// No description provided for @partner_syncing_contacts.
  ///
  /// In en, this message translates to:
  /// **'Syncing contacts...'**
  String get partner_syncing_contacts;

  /// No description provided for @partner_open_now.
  ///
  /// In en, this message translates to:
  /// **'OPEN NOW'**
  String get partner_open_now;

  /// No description provided for @partner_select_this.
  ///
  /// In en, this message translates to:
  /// **'SELECT THIS PARTNER'**
  String get partner_select_this;

  /// No description provided for @walk_no_notes.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get walk_no_notes;

  /// No description provided for @walk_error_generating_summary.
  ///
  /// In en, this message translates to:
  /// **'Error generating summary: {error}'**
  String walk_error_generating_summary(String error);

  /// No description provided for @walk_ai_summary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get walk_ai_summary;

  /// No description provided for @walk_event_removed_success.
  ///
  /// In en, this message translates to:
  /// **'Event successfully removed!'**
  String get walk_event_removed_success;

  /// No description provided for @walk_error_deleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting'**
  String get walk_error_deleting;

  /// No description provided for @history_guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get history_guest;

  /// No description provided for @agenda_appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get agenda_appointment;

  /// No description provided for @metrics_registered_clinical.
  ///
  /// In en, this message translates to:
  /// **'Registered Clinical Metrics'**
  String get metrics_registered_clinical;

  /// No description provided for @pdf_page_count.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pdf_page_count(int page, int total);

  /// No description provided for @pdf_scannut_module.
  ///
  /// In en, this message translates to:
  /// **'ScanNut+: {module}'**
  String pdf_scannut_module(String module);

  /// No description provided for @pdf_name.
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String pdf_name(String name);

  /// No description provided for @pdf_breed.
  ///
  /// In en, this message translates to:
  /// **'Breed: {breed}'**
  String pdf_breed(String breed);

  /// No description provided for @pdf_friend_present.
  ///
  /// In en, this message translates to:
  /// **'Friend Present: {friendName}'**
  String pdf_friend_present(String friendName);

  /// No description provided for @pdf_tutor.
  ///
  /// In en, this message translates to:
  /// **'Tutor: {tutorName}'**
  String pdf_tutor(String tutorName);

  /// No description provided for @pdf_date.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String pdf_date(String date);

  /// No description provided for @walk_location_real_context.
  ///
  /// In en, this message translates to:
  /// **'Location: {place} (Real Context)'**
  String walk_location_real_context(String place);

  /// No description provided for @walk_weather_summary.
  ///
  /// In en, this message translates to:
  /// **'Temperature: {temp}°C, {desc}. Humidity: {humidity}%.'**
  String walk_weather_summary(String temp, String desc, String humidity);

  /// No description provided for @pet_nutrition_hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid (Kibble + Fresh)'**
  String get pet_nutrition_hybrid;

  /// No description provided for @pet_nutrition_maintain.
  ///
  /// In en, this message translates to:
  /// **'Weight Maintenance'**
  String get pet_nutrition_maintain;

  /// No description provided for @pet_nutrition_weight_loss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get pet_nutrition_weight_loss;

  /// No description provided for @pet_nutrition_muscle.
  ///
  /// In en, this message translates to:
  /// **'Muscle Building'**
  String get pet_nutrition_muscle;

  /// No description provided for @pet_nutrition_therapeutic.
  ///
  /// In en, this message translates to:
  /// **'Therapeutic/Disease'**
  String get pet_nutrition_therapeutic;

  /// No description provided for @pet_nutrition_exclusion.
  ///
  /// In en, this message translates to:
  /// **'Exclusion Diet'**
  String get pet_nutrition_exclusion;

  /// No description provided for @pet_nutrition_senior.
  ///
  /// In en, this message translates to:
  /// **'Senior/Cognitive'**
  String get pet_nutrition_senior;

  /// No description provided for @pet_nutrition_puppy.
  ///
  /// In en, this message translates to:
  /// **'Puppy/Kitten'**
  String get pet_nutrition_puppy;

  /// No description provided for @pet_nutrition_gestating.
  ///
  /// In en, this message translates to:
  /// **'Gestating/Lactating'**
  String get pet_nutrition_gestating;

  /// No description provided for @pet_nutrition_athlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete/Work'**
  String get pet_nutrition_athlete;

  /// No description provided for @pet_nutrition_recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get pet_nutrition_recovery;

  /// No description provided for @pet_nutrition_every_day.
  ///
  /// In en, this message translates to:
  /// **'EVERY DAY:'**
  String get pet_nutrition_every_day;

  /// No description provided for @pet_error_nutrition_plan.
  ///
  /// In en, this message translates to:
  /// **'Error generating nutritional plan.'**
  String get pet_error_nutrition_plan;

  /// No description provided for @pet_error_summary.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t generate the summary right now. Please try again later.'**
  String get pet_error_summary;

  /// No description provided for @pet_health_based_on_history.
  ///
  /// In en, this message translates to:
  /// **'Based on Pet\'s Clinical History'**
  String get pet_health_based_on_history;

  /// No description provided for @pet_metric_last_recorded.
  ///
  /// In en, this message translates to:
  /// **'Last: {value}'**
  String pet_metric_last_recorded(String value);

  /// No description provided for @pet_metric_evolution_title.
  ///
  /// In en, this message translates to:
  /// **'Evolution: {label}'**
  String pet_metric_evolution_title(String label);

  /// No description provided for @pet_metric_save_quick.
  ///
  /// In en, this message translates to:
  /// **'Save {metric}'**
  String pet_metric_save_quick(String metric);

  /// No description provided for @pet_metric_empty_state.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get pet_metric_empty_state;

  /// No description provided for @pet_metric_quick_action_title.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get pet_metric_quick_action_title;

  /// No description provided for @pet_error_no_internet_title.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get pet_error_no_internet_title;

  /// No description provided for @pet_error_no_internet_content.
  ///
  /// In en, this message translates to:
  /// **'Oops! It looks like your phone is offline or the signal dropped. Please check your internet connection and try again.'**
  String get pet_error_no_internet_content;

  /// No description provided for @pet_error_timeout_title.
  ///
  /// In en, this message translates to:
  /// **'Server Busy'**
  String get pet_error_timeout_title;

  /// No description provided for @pet_error_timeout_content.
  ///
  /// In en, this message translates to:
  /// **'The AI took too long to respond this time. This usually happens when the server is busy. Please wait a few seconds and try again.'**
  String get pet_error_timeout_content;

  /// No description provided for @pet_error_technical_title.
  ///
  /// In en, this message translates to:
  /// **'Unable to Analyze'**
  String get pet_error_technical_title;

  /// No description provided for @pet_error_technical_content.
  ///
  /// In en, this message translates to:
  /// **'We encountered a small technical issue while reading your data. Don\'t worry, just try again.'**
  String get pet_error_technical_content;

  /// No description provided for @pet_journal_bg_evaluating.
  ///
  /// In en, this message translates to:
  /// **'Analyzing in background...'**
  String get pet_journal_bg_evaluating;

  /// No description provided for @pet_journal_bg_ready.
  ///
  /// In en, this message translates to:
  /// **'Analysis Ready - Summary below'**
  String get pet_journal_bg_ready;

  /// No description provided for @pet_journal_bg_error.
  ///
  /// In en, this message translates to:
  /// **'Analysis Error'**
  String get pet_journal_bg_error;

  /// No description provided for @pet_journal_bg_saved.
  ///
  /// In en, this message translates to:
  /// **'Media saved. Analyzing...'**
  String get pet_journal_bg_saved;

  /// No description provided for @pet_journal_bg_resuming.
  ///
  /// In en, this message translates to:
  /// **'Resuming intelligence evaluations... ({count})'**
  String pet_journal_bg_resuming(int count);

  /// No description provided for @pet_journal_bg_fatal.
  ///
  /// In en, this message translates to:
  /// **'Critical error in background processing.'**
  String get pet_journal_bg_fatal;

  /// No description provided for @pet_journal_bg_save_fail.
  ///
  /// In en, this message translates to:
  /// **'Failed to save event to database.'**
  String get pet_journal_bg_save_fail;

  /// No description provided for @pet_journal_saved_friend.
  ///
  /// In en, this message translates to:
  /// **'Friend Event Saved in Agenda!'**
  String get pet_journal_saved_friend;

  /// No description provided for @pet_journal_saved_own.
  ///
  /// In en, this message translates to:
  /// **'Event Saved!'**
  String get pet_journal_saved_own;

  /// No description provided for @pet_journal_friend_label.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get pet_journal_friend_label;

  /// No description provided for @pet_btn_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get pet_btn_ok;

  /// No description provided for @agenda_voice_greeting.
  ///
  /// In en, this message translates to:
  /// **'Beli, what are we scheduling for your pet?'**
  String get agenda_voice_greeting;

  /// No description provided for @agenda_voice_success_prompt.
  ///
  /// In en, this message translates to:
  /// **'I filled in the details for you. Is everything correct or do you want to adjust something?'**
  String get agenda_voice_success_prompt;

  /// No description provided for @agenda_voice_listening.
  ///
  /// In en, this message translates to:
  /// **'Beli is listening...'**
  String get agenda_voice_listening;

  /// No description provided for @agenda_voice_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get agenda_voice_processing;

  /// No description provided for @agenda_field_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get agenda_field_category;

  /// No description provided for @agenda_field_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get agenda_field_date;

  /// No description provided for @agenda_field_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get agenda_field_time;

  /// No description provided for @agenda_field_desc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get agenda_field_desc;

  /// No description provided for @agenda_btn_save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get agenda_btn_save;

  /// No description provided for @agenda_error_voice.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t understand, try typing.'**
  String get agenda_error_voice;

  /// No description provided for @pet_agenda_attach_document.
  ///
  /// In en, this message translates to:
  /// **'Attach Document'**
  String get pet_agenda_attach_document;

  /// No description provided for @pet_agenda_ai_summary.
  ///
  /// In en, this message translates to:
  /// **'Generate AI Summary'**
  String get pet_agenda_ai_summary;

  /// No description provided for @pet_agenda_generating_summary.
  ///
  /// In en, this message translates to:
  /// **'Generating Summary...'**
  String get pet_agenda_generating_summary;

  /// No description provided for @pet_agenda_file_attached.
  ///
  /// In en, this message translates to:
  /// **'File Attached'**
  String get pet_agenda_file_attached;

  /// No description provided for @pet_agenda_ai_summary_attached.
  ///
  /// In en, this message translates to:
  /// **'AI Summary Attached'**
  String get pet_agenda_ai_summary_attached;

  /// No description provided for @pet_journal_bg_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing AI Media...'**
  String get pet_journal_bg_processing;

  /// No description provided for @pet_agenda_delete_attachment_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Attachment'**
  String get pet_agenda_delete_attachment_title;

  /// No description provided for @pet_agenda_delete_attachment_msg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this attachment?'**
  String get pet_agenda_delete_attachment_msg;

  /// No description provided for @pet_agenda_delete_attachment_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pet_agenda_delete_attachment_confirm;

  /// No description provided for @pet_metric_pdf_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Metrics Report'**
  String get pet_metric_pdf_filter_title;

  /// No description provided for @pet_metric_pdf_filter_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the period to generate the PDF'**
  String get pet_metric_pdf_filter_subtitle;

  /// No description provided for @pet_metric_pdf_filter_last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get pet_metric_pdf_filter_last_7_days;

  /// No description provided for @pet_metric_pdf_filter_last_30_days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get pet_metric_pdf_filter_last_30_days;

  /// No description provided for @pet_metric_pdf_filter_last_3_months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get pet_metric_pdf_filter_last_3_months;

  /// No description provided for @pet_metric_pdf_filter_all_time.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get pet_metric_pdf_filter_all_time;

  /// No description provided for @pet_metric_pdf_filter_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get pet_metric_pdf_filter_custom;

  /// No description provided for @pet_metric_pdf_filter_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get pet_metric_pdf_filter_start_date;

  /// No description provided for @pet_metric_pdf_filter_end_date.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get pet_metric_pdf_filter_end_date;

  /// No description provided for @pet_metric_pdf_filter_generate.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get pet_metric_pdf_filter_generate;

  /// No description provided for @pet_metric_pdf_filter_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pet_metric_pdf_filter_cancel;

  /// No description provided for @pet_metric_pdf_table_value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get pet_metric_pdf_table_value;

  /// No description provided for @pet_metric_pdf_empty_data.
  ///
  /// In en, this message translates to:
  /// **'No records found in this period.'**
  String get pet_metric_pdf_empty_data;

  /// No description provided for @pet_record_date_label.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pet_record_date_label;

  /// No description provided for @pet_expense_dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Expense Monitoring'**
  String get pet_expense_dashboard_title;

  /// No description provided for @pet_expense_dashboard_empty.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded in this period yet. How about recording your pet\'s first treat?'**
  String get pet_expense_dashboard_empty;

  /// No description provided for @pet_expense_chart_pie_title.
  ///
  /// In en, this message translates to:
  /// **'Distribution by Category'**
  String get pet_expense_chart_pie_title;

  /// No description provided for @pet_expense_chart_line_title.
  ///
  /// In en, this message translates to:
  /// **'Monthly Evolution'**
  String get pet_expense_chart_line_title;

  /// No description provided for @pet_expense_chart_area_title.
  ///
  /// In en, this message translates to:
  /// **'Total Accumulation'**
  String get pet_expense_chart_area_title;

  /// No description provided for @pet_expense_filter_month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get pet_expense_filter_month;

  /// No description provided for @pet_expense_filter_year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get pet_expense_filter_year;

  /// No description provided for @pet_expense_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pet_expense_filter_all;

  /// No description provided for @pet_expense_cat_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get pet_expense_cat_food;

  /// No description provided for @pet_expense_cat_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get pet_expense_cat_health;

  /// No description provided for @pet_expense_cat_hygiene.
  ///
  /// In en, this message translates to:
  /// **'Hygiene & Aesthetics'**
  String get pet_expense_cat_hygiene;

  /// No description provided for @pet_expense_cat_meds.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get pet_expense_cat_meds;

  /// No description provided for @pet_expense_cat_treats.
  ///
  /// In en, this message translates to:
  /// **'Treats & Leisure'**
  String get pet_expense_cat_treats;

  /// No description provided for @pet_expense_cat_services.
  ///
  /// In en, this message translates to:
  /// **'Extra Services'**
  String get pet_expense_cat_services;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
