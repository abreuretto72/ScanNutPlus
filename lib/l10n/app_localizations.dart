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
  /// **'Analysis Error: {error}'**
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
  /// **'Ear Health'**
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
  /// **'Error loading database: {error}'**
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
  /// **'Feces'**
  String get category_feces;

  /// No description provided for @category_food_label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
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
  /// **'Label'**
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
  /// **'Mouth/Teeth'**
  String get pet_type_mouth;

  /// No description provided for @pet_type_eyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get pet_type_eyes;

  /// No description provided for @pet_type_skin.
  ///
  /// In en, this message translates to:
  /// **'Skin/Coat'**
  String get pet_type_skin;

  /// No description provided for @pet_type_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab Exam'**
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
  /// **'Unknown Name'**
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
  /// **'Breed not informed'**
  String get pet_breed_unknown;

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
  /// **'Stool & Digestion Analysis'**
  String get pet_module_gastro;

  /// No description provided for @pet_module_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab Report Reading'**
  String get pet_module_lab;

  /// No description provided for @pet_module_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition & Label Analysis'**
  String get pet_module_nutrition;

  /// No description provided for @pet_module_ophthalmology.
  ///
  /// In en, this message translates to:
  /// **'Eyes & Ears Analysis'**
  String get pet_module_ophthalmology;

  /// No description provided for @pet_module_physique.
  ///
  /// In en, this message translates to:
  /// **'Body Condition & Weight'**
  String get pet_module_physique;

  /// No description provided for @btn_scan_image.
  ///
  /// In en, this message translates to:
  /// **'Scan Image'**
  String get btn_scan_image;

  /// No description provided for @generic_analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image...'**
  String get generic_analyzing;

  /// No description provided for @pet_error_image_not_found.
  ///
  /// In en, this message translates to:
  /// **'Error: Original image not found.'**
  String get pet_error_image_not_found;

  /// No description provided for @btn_go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get btn_go;

  /// No description provided for @pet_created_at_label.
  ///
  /// In en, this message translates to:
  /// **'Created at:'**
  String get pet_created_at_label;

  /// No description provided for @pet_initial_assessment.
  ///
  /// In en, this message translates to:
  /// **'Initial Assessment'**
  String get pet_initial_assessment;

  /// No description provided for @pet_hint_select_type.
  ///
  /// In en, this message translates to:
  /// **'<Select type>'**
  String get pet_hint_select_type;

  /// No description provided for @pet_label_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get pet_label_info;

  /// No description provided for @pet_type_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile Analysis'**
  String get pet_type_profile;

  /// No description provided for @pet_type_posture.
  ///
  /// In en, this message translates to:
  /// **'Posture Analysis'**
  String get pet_type_posture;

  /// No description provided for @pet_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Pet Profile'**
  String get pet_profile_title;

  /// No description provided for @pet_management_title.
  ///
  /// In en, this message translates to:
  /// **'Pet Management'**
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

  /// No description provided for @pet_label_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get pet_label_size;

  /// No description provided for @pet_label_neutered.
  ///
  /// In en, this message translates to:
  /// **'Neutered Status'**
  String get pet_label_neutered;

  /// No description provided for @pet_label_birth_date.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get pet_label_birth_date;

  /// No description provided for @pet_btn_add_metric.
  ///
  /// In en, this message translates to:
  /// **'Add Metric'**
  String get pet_btn_add_metric;

  /// No description provided for @pet_profile_save_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get pet_profile_save_success;

  /// No description provided for @pet_action_save_profile.
  ///
  /// In en, this message translates to:
  /// **'SAVE PET PROFILE'**
  String get pet_action_save_profile;

  /// No description provided for @pet_not_found.
  ///
  /// In en, this message translates to:
  /// **'Pet not found'**
  String get pet_not_found;

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
  /// **'Health Plan Management'**
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
  /// **'3. Limits & Rules'**
  String get health_plan_section_limits;

  /// No description provided for @health_plan_section_support.
  ///
  /// In en, this message translates to:
  /// **'4. Network & Support'**
  String get health_plan_section_support;

  /// No description provided for @health_plan_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Health Plan Saved Successfully!'**
  String get health_plan_saved_success;

  /// No description provided for @health_plan_action_save.
  ///
  /// In en, this message translates to:
  /// **'SAVE HEALTH PLAN'**
  String get health_plan_action_save;

  /// No description provided for @health_plan_label_operator.
  ///
  /// In en, this message translates to:
  /// **'Operator Name'**
  String get health_plan_label_operator;

  /// No description provided for @health_plan_label_plan_name.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get health_plan_label_plan_name;

  /// No description provided for @health_plan_label_card_number.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get health_plan_label_card_number;

  /// No description provided for @health_plan_label_holder_name.
  ///
  /// In en, this message translates to:
  /// **'Holder Name'**
  String get health_plan_label_holder_name;

  /// No description provided for @health_plan_label_grace_period.
  ///
  /// In en, this message translates to:
  /// **'Grace (Days)'**
  String get health_plan_label_grace_period;

  /// No description provided for @health_plan_label_annual_limit.
  ///
  /// In en, this message translates to:
  /// **'Annual Limit'**
  String get health_plan_label_annual_limit;

  /// No description provided for @health_plan_label_copay.
  ///
  /// In en, this message translates to:
  /// **'Copay %'**
  String get health_plan_label_copay;

  /// No description provided for @health_plan_label_reimburse.
  ///
  /// In en, this message translates to:
  /// **'Reimburse %'**
  String get health_plan_label_reimburse;

  /// No description provided for @health_plan_label_deductible.
  ///
  /// In en, this message translates to:
  /// **'Deductible'**
  String get health_plan_label_deductible;

  /// No description provided for @health_plan_label_main_clinic.
  ///
  /// In en, this message translates to:
  /// **'Main Clinic'**
  String get health_plan_label_main_clinic;

  /// No description provided for @health_plan_label_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get health_plan_label_city;

  /// No description provided for @health_plan_label_24h.
  ///
  /// In en, this message translates to:
  /// **'24h Service'**
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
  /// **'Support Email'**
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
  /// **'Physiotherapy'**
  String get health_cov_physiotherapy;

  /// No description provided for @pet_db_sync_error.
  ///
  /// In en, this message translates to:
  /// **'Database Sync Error - Please restart the app'**
  String get pet_db_sync_error;

  /// No description provided for @pet_action_manage_funeral_plan.
  ///
  /// In en, this message translates to:
  /// **'Manage Funeral Plan'**
  String get pet_action_manage_funeral_plan;

  /// No description provided for @funeral_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Funeral Plan Management'**
  String get funeral_plan_title;

  /// No description provided for @funeral_section_identity.
  ///
  /// In en, this message translates to:
  /// **'1. Identity'**
  String get funeral_section_identity;

  /// No description provided for @funeral_section_services.
  ///
  /// In en, this message translates to:
  /// **'2. Included Services'**
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
  /// **'Funeral Company'**
  String get funeral_label_company;

  /// No description provided for @funeral_label_plan_name.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get funeral_label_plan_name;

  /// No description provided for @funeral_label_contract.
  ///
  /// In en, this message translates to:
  /// **'Contract Number'**
  String get funeral_label_contract;

  /// No description provided for @funeral_label_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get funeral_label_start_date;

  /// No description provided for @funeral_label_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get funeral_label_status;

  /// No description provided for @funeral_label_grace_period.
  ///
  /// In en, this message translates to:
  /// **'Grace (Days)'**
  String get funeral_label_grace_period;

  /// No description provided for @funeral_label_max_weight.
  ///
  /// In en, this message translates to:
  /// **'Max Weight (kg)'**
  String get funeral_label_max_weight;

  /// No description provided for @funeral_label_24h.
  ///
  /// In en, this message translates to:
  /// **'24h Service'**
  String get funeral_label_24h;

  /// No description provided for @funeral_label_phone.
  ///
  /// In en, this message translates to:
  /// **'24h Phone'**
  String get funeral_label_phone;

  /// No description provided for @funeral_label_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get funeral_label_whatsapp;

  /// No description provided for @funeral_label_value.
  ///
  /// In en, this message translates to:
  /// **'Plan Value'**
  String get funeral_label_value;

  /// No description provided for @funeral_label_extra_fees.
  ///
  /// In en, this message translates to:
  /// **'Extra Fees'**
  String get funeral_label_extra_fees;

  /// No description provided for @funeral_svc_removal.
  ///
  /// In en, this message translates to:
  /// **'Removal 24h'**
  String get funeral_svc_removal;

  /// No description provided for @funeral_svc_viewing.
  ///
  /// In en, this message translates to:
  /// **'Viewing/Wake'**
  String get funeral_svc_viewing;

  /// No description provided for @funeral_svc_cremation_ind.
  ///
  /// In en, this message translates to:
  /// **'Individual Cremation'**
  String get funeral_svc_cremation_ind;

  /// No description provided for @funeral_svc_cremation_col.
  ///
  /// In en, this message translates to:
  /// **'Collective Cremation'**
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
  /// **'Ashes Delivery'**
  String get funeral_svc_ashes;

  /// No description provided for @funeral_svc_certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get funeral_svc_certificate;

  /// No description provided for @funeral_action_call_emergency.
  ///
  /// In en, this message translates to:
  /// **'CALL EMERGENCY NOW'**
  String get funeral_action_call_emergency;

  /// No description provided for @funeral_action_save.
  ///
  /// In en, this message translates to:
  /// **'SAVE FUNERAL PLAN'**
  String get funeral_action_save;

  /// No description provided for @funeral_save_success.
  ///
  /// In en, this message translates to:
  /// **'Funeral Plan Saved Successfully!'**
  String get funeral_save_success;

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
  /// **'Analysis History'**
  String get pet_history_button;

  /// No description provided for @ai_assistant_title.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant of {name}'**
  String ai_assistant_title(String name);

  /// No description provided for @ai_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your pet...'**
  String get ai_input_hint;

  /// No description provided for @ai_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get ai_listening;

  /// No description provided for @ai_error_mic.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required'**
  String get ai_error_mic;

  /// No description provided for @ai_thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get ai_thinking;
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
