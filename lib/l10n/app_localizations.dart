import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

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
    Locale('nl'),
  ];

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to WoonMe!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Easily find your dream home for free.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get welcomeLogin;

  /// No description provided for @welcomeRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get welcomeRegister;

  /// No description provided for @welcomeContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get welcomeContinueGuest;

  /// No description provided for @loginPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginPageTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubmit;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginPasswordTooShort;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email address.'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get loginErrorUserDisabled;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginErrorGeneric;

  /// No description provided for @registerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerPageTitle;

  /// No description provided for @registerFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registerFirstNameLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerSubmit;

  /// No description provided for @registerFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get registerFirstNameRequired;

  /// No description provided for @registerEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get registerEmailRequired;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get registerEmailInvalid;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get registerPasswordRequired;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get registerPasswordTooShort;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get registerConfirmPasswordRequired;

  /// No description provided for @registerConfirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerConfirmPasswordMismatch;

  /// No description provided for @registerErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use.'**
  String get registerErrorEmailInUse;

  /// No description provided for @registerErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get registerErrorInvalidEmail;

  /// No description provided for @registerErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get registerErrorWeakPassword;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registerErrorGeneric;

  /// No description provided for @profilePageTitle.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get profilePageTitle;

  /// No description provided for @profileMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More account options'**
  String get profileMoreOptions;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get profileMemberSince;

  /// No description provided for @profileLastActivity.
  ///
  /// In en, this message translates to:
  /// **'Last activity'**
  String get profileLastActivity;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// No description provided for @profileFeedback.
  ///
  /// In en, this message translates to:
  /// **'Give feedback'**
  String get profileFeedback;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteDialogTitle;

  /// No description provided for @profileDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account and all search filters? This cannot be undone.'**
  String get profileDeleteDialogBody;

  /// No description provided for @profileDeleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileDeleteDialogCancel;

  /// No description provided for @profileDeleteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteDialogConfirm;

  /// No description provided for @profileErrorRelogin.
  ///
  /// In en, this message translates to:
  /// **'Log in again and try deleting your account again.'**
  String get profileErrorRelogin;

  /// No description provided for @profileErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String profileErrorGeneric(String message);

  /// No description provided for @profileErrorDelete.
  ///
  /// In en, this message translates to:
  /// **'Error deleting: {error}'**
  String profileErrorDelete(String error);

  /// No description provided for @profileLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get profileLanguageSection;

  /// No description provided for @profileLanguageNl.
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get profileLanguageNl;

  /// No description provided for @profileLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @profileNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsSection;

  /// No description provided for @profileNotificationsReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications'**
  String get profileNotificationsReceive;

  /// No description provided for @profileNotificationsEnableInSettings.
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications in your phone settings.'**
  String get profileNotificationsEnableInSettings;

  /// No description provided for @filterOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your first search filter'**
  String get filterOnboardingTitle;

  /// No description provided for @filterOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'A search filter saves your housing preferences. Specify which city you want to live in, what your budget is and how many rooms you need — then WoonMe will show you matching listings directly.'**
  String get filterOnboardingDesc;

  /// No description provided for @filterCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City or municipality'**
  String get filterCityLabel;

  /// No description provided for @filterRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Radius:'**
  String get filterRadiusLabel;

  /// No description provided for @filterMinRentLabel.
  ///
  /// In en, this message translates to:
  /// **'Min. rent €'**
  String get filterMinRentLabel;

  /// No description provided for @filterMaxRentLabel.
  ///
  /// In en, this message translates to:
  /// **'Max. rent €'**
  String get filterMaxRentLabel;

  /// No description provided for @filterMinRoomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Min. rooms:'**
  String get filterMinRoomsLabel;

  /// No description provided for @filterMinSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Min. area (m²)'**
  String get filterMinSizeLabel;

  /// No description provided for @filterSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save filter'**
  String get filterSaveButton;

  /// No description provided for @filterErrorAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Fill in at least one filter to continue.'**
  String get filterErrorAtLeastOne;

  /// No description provided for @filterDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'My search filter'**
  String get filterDefaultLabel;

  /// No description provided for @filterWholeNL.
  ///
  /// In en, this message translates to:
  /// **'All of Netherlands'**
  String get filterWholeNL;

  /// No description provided for @filterFromPrice.
  ///
  /// In en, this message translates to:
  /// **'from €{price}'**
  String filterFromPrice(int price);

  /// No description provided for @filterUpToPrice.
  ///
  /// In en, this message translates to:
  /// **'up to €{price}'**
  String filterUpToPrice(int price);

  /// No description provided for @filterRooms.
  ///
  /// In en, this message translates to:
  /// **'{count} rooms'**
  String filterRooms(String count);

  /// No description provided for @zoekenNewFilter.
  ///
  /// In en, this message translates to:
  /// **'New search filter'**
  String get zoekenNewFilter;

  /// No description provided for @zoekenSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get zoekenSave;

  /// No description provided for @zoekenCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City name *'**
  String get zoekenCityLabel;

  /// No description provided for @zoekenCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a city name'**
  String get zoekenCityRequired;

  /// No description provided for @zoekenSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Search filter saved'**
  String get zoekenSavedSuccess;

  /// No description provided for @zoekenStayUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stay updated on new listings'**
  String get zoekenStayUpdated;

  /// No description provided for @zoekenNoFilters.
  ///
  /// In en, this message translates to:
  /// **'No search filters saved yet.'**
  String get zoekenNoFilters;

  /// No description provided for @aanbodTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get aanbodTabLabel;

  /// No description provided for @aanbodFilterTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Search filter'**
  String get aanbodFilterTabLabel;

  /// No description provided for @aanbodNewTabLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get aanbodNewTabLabel;

  /// No description provided for @aanbodFiltersHeader.
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get aanbodFiltersHeader;

  /// No description provided for @aanbodFiltersHeaderCollapsed.
  ///
  /// In en, this message translates to:
  /// **'Search filters · {label}'**
  String aanbodFiltersHeaderCollapsed(String label);

  /// No description provided for @aanbodRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Radius:'**
  String get aanbodRadiusLabel;

  /// No description provided for @aanbodSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort:'**
  String get aanbodSortLabel;

  /// No description provided for @aanbodSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get aanbodSortNewest;

  /// No description provided for @aanbodSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get aanbodSortOldest;

  /// No description provided for @aanbodSortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get aanbodSortPriceAsc;

  /// No description provided for @aanbodSortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get aanbodSortPriceDesc;

  /// No description provided for @aanbodSortDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get aanbodSortDistance;

  /// No description provided for @aanbodBannerText.
  ///
  /// In en, this message translates to:
  /// **'Be the first — get notified when new listings become available'**
  String get aanbodBannerText;

  /// No description provided for @aanbodEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No search filters set'**
  String get aanbodEmptyTitle;

  /// No description provided for @aanbodEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Go to the \"Search filter\" tab to save your preferences and see matching listings.'**
  String get aanbodEmptyBody;

  /// No description provided for @aanbodNoResults.
  ///
  /// In en, this message translates to:
  /// **'No properties found.'**
  String get aanbodNoResults;

  /// No description provided for @aanbodErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get aanbodErrorRetry;

  /// No description provided for @aanbodBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get aanbodBadgeNew;

  /// No description provided for @aanbodBadgeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get aanbodBadgeRecent;

  /// No description provided for @aanbodUnknownAddress.
  ///
  /// In en, this message translates to:
  /// **'Unknown address'**
  String get aanbodUnknownAddress;

  /// No description provided for @nieuwToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get nieuwToday;

  /// No description provided for @nieuwThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get nieuwThisWeek;

  /// No description provided for @nieuwEmptyNoFilter.
  ///
  /// In en, this message translates to:
  /// **'First set up a search filter via the \"Search filter\" tab.'**
  String get nieuwEmptyNoFilter;

  /// No description provided for @nieuwEmptyNoResults.
  ///
  /// In en, this message translates to:
  /// **'No new listings available this week.'**
  String get nieuwEmptyNoResults;

  /// No description provided for @nieuwErrorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load listings'**
  String get nieuwErrorLoadFailed;

  /// No description provided for @nieuwRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get nieuwRetry;

  /// No description provided for @feedbackPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Give feedback'**
  String get feedbackPageTitle;

  /// No description provided for @feedbackTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get feedbackTitleLabel;

  /// No description provided for @feedbackDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get feedbackDescLabel;

  /// No description provided for @feedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSubmit;

  /// No description provided for @feedbackTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get feedbackTitleRequired;

  /// No description provided for @feedbackDescRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get feedbackDescRequired;

  /// No description provided for @feedbackSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackSuccessMessage;

  /// No description provided for @feedbackErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error while sending: {error}'**
  String feedbackErrorMessage(String error);

  /// No description provided for @updatePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updatePromptTitle;

  /// No description provided for @updatePromptBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Do you want to update now?'**
  String get updatePromptBody;

  /// No description provided for @updatePromptLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updatePromptLater;

  /// No description provided for @updatePromptUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updatePromptUpdate;

  /// No description provided for @updateEnforceTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateEnforceTitle;

  /// No description provided for @updateEnforceBody.
  ///
  /// In en, this message translates to:
  /// **'To continue using the app you must update to the latest version.'**
  String get updateEnforceBody;

  /// No description provided for @updateEnforceButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateEnforceButton;

  /// No description provided for @notifPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay informed'**
  String get notifPermissionTitle;

  /// No description provided for @notifPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about new features and important app updates.'**
  String get notifPermissionBody;

  /// No description provided for @notifPermissionSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'You can always change this in the app settings.'**
  String get notifPermissionSettingsHint;

  /// No description provided for @notifPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Yes, keep me updated'**
  String get notifPermissionAllow;

  /// No description provided for @notifPermissionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get notifPermissionSkip;

  /// No description provided for @propertySourcePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a source'**
  String get propertySourcePickerTitle;

  /// No description provided for @propertySourceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 source} other{{count} sources}}'**
  String propertySourceCount(int count);
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
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
