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
    Locale('pt'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'ScanNut Plus'**
  String get app_title;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_title;

  /// No description provided for @login_title_plus.
  ///
  /// In en, this message translates to:
  /// **'ScanNutPlus'**
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
  /// **'ScanNut © 2026 Multiverso Digital'**
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
  /// **'Welcome to ScanNut'**
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
  /// **'© 2026 Multiverso Digital'**
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
  /// **'Label'**
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
  /// **'Pet Domain'**
  String get help_domain_pet_title;

  /// No description provided for @help_domain_pet_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete management for Dogs and Cats: AI for visual analysis, health routines, and toxic plant safety guide.'**
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
    'that was used.',
  );
}
