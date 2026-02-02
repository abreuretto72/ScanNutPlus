import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'pet_localizations_en.dart';
import 'pet_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of PetLocalizations
/// returned by `PetLocalizations.of(context)`.
///
/// Applications need to include `PetLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/pet_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: PetLocalizations.localizationsDelegates,
///   supportedLocales: PetLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the PetLocalizations.supportedLocales
/// property.
abstract class PetLocalizations {
  PetLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static PetLocalizations? of(BuildContext context) {
    return Localizations.of<PetLocalizations>(context, PetLocalizations);
  }

  static const LocalizationsDelegate<PetLocalizations> delegate = _PetLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @pet_capture_title.
  ///
  /// In en, this message translates to:
  /// **'Pet Capture'**
  String get pet_capture_title;

  /// No description provided for @pet_capture_instructions.
  ///
  /// In en, this message translates to:
  /// **'The AI analyzes images of the pet, wounds, stool, mouth, eyes, and skin. One at a time.'**
  String get pet_capture_instructions;

  /// No description provided for @pet_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Pet saved successfully'**
  String get pet_saved_success;

  /// No description provided for @pet_analysis_error.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get pet_analysis_error;

  /// No description provided for @pet_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get pet_history_empty;

  /// No description provided for @pet_tab_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get pet_tab_history;

  /// No description provided for @pet_tab_capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get pet_tab_capture;

  /// No description provided for @pet_label_species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get pet_label_species;

  /// No description provided for @pet_label_dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get pet_label_dog;

  /// No description provided for @pet_label_cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get pet_label_cat;

  /// No description provided for @pet_result_title.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get pet_result_title;

  /// No description provided for @pet_section_observations.
  ///
  /// In en, this message translates to:
  /// **'Visual Observations'**
  String get pet_section_observations;

  /// No description provided for @pet_section_sources.
  ///
  /// In en, this message translates to:
  /// **'Consulted Sources'**
  String get pet_section_sources;

  /// No description provided for @pet_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'The analysis is visual only and does not replace veterinary evaluation.'**
  String get pet_disclaimer;

  /// No description provided for @pet_action_share.
  ///
  /// In en, this message translates to:
  /// **'Share with Vet'**
  String get pet_action_share;

  /// No description provided for @pet_action_new_analysis.
  ///
  /// In en, this message translates to:
  /// **'New Analysis'**
  String get pet_action_new_analysis;

  /// No description provided for @pet_footer_text.
  ///
  /// In en, this message translates to:
  /// **'Result Page | © 2026 Multiverso Digital'**
  String get pet_footer_text;

  /// No description provided for @pet_action_analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze Now'**
  String get pet_action_analyze;

  /// No description provided for @pet_status_analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get pet_status_analyzing;

  /// No description provided for @pet_voice_title.
  ///
  /// In en, this message translates to:
  /// **'Voice Identification'**
  String get pet_voice_title;

  /// No description provided for @pet_voice_instruction.
  ///
  /// In en, this message translates to:
  /// **'New friend detected! Say name, sex, weight, and age.'**
  String get pet_voice_instruction;

  /// No description provided for @pet_voice_hint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Thor, Male, 12kg, 4 years'**
  String get pet_voice_hint;

  /// No description provided for @pet_voice_action.
  ///
  /// In en, this message translates to:
  /// **'Send Voice'**
  String get pet_voice_action;

  /// No description provided for @pet_voice_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pet_voice_retry;

  /// No description provided for @pet_rag_new_identity.
  ///
  /// In en, this message translates to:
  /// **'Identity saved: {name}'**
  String pet_rag_new_identity(Object name);

  /// No description provided for @pet_analysis_for.
  ///
  /// In en, this message translates to:
  /// **'Analysis: {name}'**
  String pet_analysis_for(Object name);

  /// No description provided for @pet_voice_who_is_this.
  ///
  /// In en, this message translates to:
  /// **'Who is this pet?'**
  String get pet_voice_who_is_this;
}

class _PetLocalizationsDelegate extends LocalizationsDelegate<PetLocalizations> {
  const _PetLocalizationsDelegate();

  @override
  Future<PetLocalizations> load(Locale locale) {
    return SynchronousFuture<PetLocalizations>(lookupPetLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_PetLocalizationsDelegate old) => false;
}

PetLocalizations lookupPetLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return PetLocalizationsEn();
    case 'pt': return PetLocalizationsPt();
  }

  throw FlutterError(
    'PetLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
