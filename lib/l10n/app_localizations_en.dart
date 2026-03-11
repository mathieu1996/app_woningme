// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Welcome to WoonMe!';

  @override
  String get welcomeSubtitle => 'Easily find your dream home for free.';

  @override
  String get welcomeLogin => 'Log in';

  @override
  String get welcomeRegister => 'Register';

  @override
  String get welcomeContinueGuest => 'Continue without account';

  @override
  String get loginPageTitle => 'Log in';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get loginEmailRequired => 'Please enter your email address';

  @override
  String get loginEmailInvalid => 'Enter a valid email address';

  @override
  String get loginPasswordRequired => 'Please enter your password';

  @override
  String get loginPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginErrorUserNotFound =>
      'No account found with this email address.';

  @override
  String get loginErrorWrongPassword => 'Incorrect password.';

  @override
  String get loginErrorInvalidEmail => 'Invalid email address.';

  @override
  String get loginErrorUserDisabled => 'This account has been disabled.';

  @override
  String get loginErrorGeneric => 'Login failed. Please try again.';

  @override
  String get registerPageTitle => 'Register';

  @override
  String get registerFirstNameLabel => 'First name';

  @override
  String get registerEmailLabel => 'Email address';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get registerFirstNameRequired => 'Please enter your first name';

  @override
  String get registerEmailRequired => 'Please enter your email address';

  @override
  String get registerEmailInvalid => 'Enter a valid email address';

  @override
  String get registerPasswordRequired => 'Please enter your password';

  @override
  String get registerPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get registerConfirmPasswordMismatch => 'Passwords do not match';

  @override
  String get registerErrorEmailInUse => 'This email address is already in use.';

  @override
  String get registerErrorInvalidEmail => 'Invalid email address.';

  @override
  String get registerErrorWeakPassword => 'Password is too weak.';

  @override
  String get registerErrorGeneric => 'Registration failed. Please try again.';

  @override
  String get profilePageTitle => 'My account';

  @override
  String get profileMoreOptions => 'More account options';

  @override
  String get profileMemberSince => 'Member since';

  @override
  String get profileLastActivity => 'Last activity';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileFeedback => 'Give feedback';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteDialogTitle => 'Delete account';

  @override
  String get profileDeleteDialogBody =>
      'Are you sure you want to delete your account and all search filters? This cannot be undone.';

  @override
  String get profileDeleteDialogCancel => 'Cancel';

  @override
  String get profileDeleteDialogConfirm => 'Delete';

  @override
  String get profileErrorRelogin =>
      'Log in again and try deleting your account again.';

  @override
  String profileErrorGeneric(String message) {
    return 'Error: $message';
  }

  @override
  String profileErrorDelete(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get profileLanguageSection => 'LANGUAGE';

  @override
  String get profileLanguageNl => 'Nederlands';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileNotificationsSection => 'Notifications';

  @override
  String get profileNotificationsReceive => 'Receive notifications';

  @override
  String get profileNotificationsEnableInSettings =>
      'Please enable notifications in your phone settings.';

  @override
  String get filterOnboardingTitle => 'Set up your first search filter';

  @override
  String get filterOnboardingDesc =>
      'A search filter saves your housing preferences. Specify which city you want to live in, what your budget is and how many rooms you need — then WoonMe will show you matching listings directly.';

  @override
  String get filterCityLabel => 'City or municipality';

  @override
  String get filterRadiusLabel => 'Radius:';

  @override
  String get filterMinRentLabel => 'Min. rent €';

  @override
  String get filterMaxRentLabel => 'Max. rent €';

  @override
  String get filterMinRoomsLabel => 'Min. rooms:';

  @override
  String get filterMinSizeLabel => 'Min. area (m²)';

  @override
  String get filterSaveButton => 'Save filter';

  @override
  String get filterErrorAtLeastOne =>
      'Fill in at least one filter to continue.';

  @override
  String get filterDefaultLabel => 'My search filter';

  @override
  String get filterWholeNL => 'All of Netherlands';

  @override
  String filterFromPrice(int price) {
    return 'from €$price';
  }

  @override
  String filterUpToPrice(int price) {
    return 'up to €$price';
  }

  @override
  String filterRooms(String count) {
    return '$count rooms';
  }

  @override
  String get zoekenNewFilter => 'New search filter';

  @override
  String get zoekenSave => 'Save';

  @override
  String get zoekenCityLabel => 'City name *';

  @override
  String get zoekenCityRequired => 'Enter a city name';

  @override
  String get zoekenSavedSuccess => 'Search filter saved';

  @override
  String get zoekenStayUpdated => 'Stay updated on new listings';

  @override
  String get zoekenNoFilters => 'No search filters saved yet.';

  @override
  String get aanbodTabLabel => 'Listings';

  @override
  String get aanbodFilterTabLabel => 'Search filter';

  @override
  String get aanbodNewTabLabel => 'New';

  @override
  String get aanbodFiltersHeader => 'Search filters';

  @override
  String aanbodFiltersHeaderCollapsed(String label) {
    return 'Search filters · $label';
  }

  @override
  String get aanbodRadiusLabel => 'Radius:';

  @override
  String get aanbodSortLabel => 'Sort:';

  @override
  String get aanbodSortNewest => 'Newest';

  @override
  String get aanbodSortOldest => 'Oldest';

  @override
  String get aanbodSortPriceAsc => 'Price ↑';

  @override
  String get aanbodSortPriceDesc => 'Price ↓';

  @override
  String get aanbodSortDistance => 'Distance';

  @override
  String get aanbodBannerText =>
      'Be the first — get notified when new listings become available';

  @override
  String get aanbodEmptyTitle => 'No search filters set';

  @override
  String get aanbodEmptyBody =>
      'Go to the \"Search filter\" tab to save your preferences and see matching listings.';

  @override
  String get aanbodNoResults => 'No properties found.';

  @override
  String get aanbodErrorRetry => 'Try again';

  @override
  String get aanbodBadgeNew => 'New';

  @override
  String get aanbodBadgeRecent => 'Recent';

  @override
  String get aanbodUnknownAddress => 'Unknown address';

  @override
  String get nieuwToday => 'Today';

  @override
  String get nieuwThisWeek => 'This week';

  @override
  String get nieuwEmptyNoFilter =>
      'First set up a search filter via the \"Search filter\" tab.';

  @override
  String get nieuwEmptyNoResults => 'No new listings available this week.';

  @override
  String get nieuwErrorLoadFailed => 'Could not load listings';

  @override
  String get nieuwRetry => 'Retry';

  @override
  String get feedbackPageTitle => 'Give feedback';

  @override
  String get feedbackTitleLabel => 'Title';

  @override
  String get feedbackDescLabel => 'Description';

  @override
  String get feedbackSubmit => 'Send';

  @override
  String get feedbackTitleRequired => 'Enter a title';

  @override
  String get feedbackDescRequired => 'Enter a description';

  @override
  String get feedbackSuccessMessage => 'Thank you for your feedback!';

  @override
  String feedbackErrorMessage(String error) {
    return 'Error while sending: $error';
  }

  @override
  String get updatePromptTitle => 'Update available';

  @override
  String get updatePromptBody =>
      'A new version of the app is available. Do you want to update now?';

  @override
  String get updatePromptLater => 'Later';

  @override
  String get updatePromptUpdate => 'Update';

  @override
  String get updateEnforceTitle => 'Update required';

  @override
  String get updateEnforceBody =>
      'To continue using the app you must update to the latest version.';

  @override
  String get updateEnforceButton => 'Update';

  @override
  String get notifPermissionTitle => 'Stay informed';

  @override
  String get notifPermissionBody =>
      'Receive notifications about new features and important app updates.';

  @override
  String get notifPermissionSettingsHint =>
      'You can always change this in the app settings.';

  @override
  String get notifPermissionAllow => 'Yes, keep me updated';

  @override
  String get notifPermissionSkip => 'Skip';

  @override
  String get propertySourcePickerTitle => 'Choose a source';

  @override
  String propertySourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources',
      one: '1 source',
    );
    return '$_temp0';
  }
}
