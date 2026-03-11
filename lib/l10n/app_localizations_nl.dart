// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get welcomeTitle => 'Welkom bij WoonMe!';

  @override
  String get welcomeSubtitle => 'Vind eenvoudig en gratis jouw droomhuis.';

  @override
  String get welcomeLogin => 'Inloggen';

  @override
  String get welcomeRegister => 'Registreren';

  @override
  String get welcomeContinueGuest => 'Doorgaan zonder account';

  @override
  String get loginPageTitle => 'Inloggen';

  @override
  String get loginEmailLabel => 'E-mailadres';

  @override
  String get loginPasswordLabel => 'Wachtwoord';

  @override
  String get loginSubmit => 'Inloggen';

  @override
  String get loginEmailRequired => 'Vul alstublieft uw e-mailadres in';

  @override
  String get loginEmailInvalid => 'Voer een geldig e-mailadres in';

  @override
  String get loginPasswordRequired => 'Vul alstublieft uw wachtwoord in';

  @override
  String get loginPasswordTooShort =>
      'Wachtwoord moet minimaal 6 tekens bevatten';

  @override
  String get loginErrorUserNotFound =>
      'Geen account gevonden met dit e-mailadres.';

  @override
  String get loginErrorWrongPassword => 'Onjuist wachtwoord.';

  @override
  String get loginErrorInvalidEmail => 'Ongeldig e-mailadres.';

  @override
  String get loginErrorUserDisabled => 'Dit account is uitgeschakeld.';

  @override
  String get loginErrorGeneric => 'Inloggen mislukt. Probeer het opnieuw.';

  @override
  String get registerPageTitle => 'Registreren';

  @override
  String get registerFirstNameLabel => 'Voornaam';

  @override
  String get registerEmailLabel => 'E-mailadres';

  @override
  String get registerPasswordLabel => 'Wachtwoord';

  @override
  String get registerSubmit => 'Account aanmaken';

  @override
  String get registerFirstNameRequired => 'Vul alstublieft uw voornaam in';

  @override
  String get registerEmailRequired => 'Vul alstublieft uw e-mailadres in';

  @override
  String get registerEmailInvalid => 'Voer een geldig e-mailadres in';

  @override
  String get registerPasswordRequired => 'Vul alstublieft uw wachtwoord in';

  @override
  String get registerPasswordTooShort =>
      'Wachtwoord moet minimaal 6 tekens bevatten';

  @override
  String get registerConfirmPasswordLabel => 'Wachtwoord bevestigen';

  @override
  String get registerConfirmPasswordRequired =>
      'Bevestig alstublieft uw wachtwoord';

  @override
  String get registerConfirmPasswordMismatch =>
      'Wachtwoorden komen niet overeen';

  @override
  String get registerErrorEmailInUse => 'Dit e-mailadres is al in gebruik.';

  @override
  String get registerErrorInvalidEmail => 'Ongeldig e-mailadres.';

  @override
  String get registerErrorWeakPassword => 'Wachtwoord is te zwak.';

  @override
  String get registerErrorGeneric =>
      'Registratie mislukt. Probeer het opnieuw.';

  @override
  String get profilePageTitle => 'Mijn account';

  @override
  String get profileMoreOptions => 'Meer accountopties';

  @override
  String get profileMemberSince => 'Lid sinds';

  @override
  String get profileLastActivity => 'Laatste activiteit';

  @override
  String get profileLogout => 'Uitloggen';

  @override
  String get profileFeedback => 'Geef feedback';

  @override
  String get profileDeleteAccount => 'Account verwijderen';

  @override
  String get profileDeleteDialogTitle => 'Account verwijderen';

  @override
  String get profileDeleteDialogBody =>
      'Weet je zeker dat je je account en alle zoekfilters wilt verwijderen? Dit kan niet ongedaan worden gemaakt.';

  @override
  String get profileDeleteDialogCancel => 'Annuleren';

  @override
  String get profileDeleteDialogConfirm => 'Verwijderen';

  @override
  String get profileErrorRelogin =>
      'Log opnieuw in en probeer je account opnieuw te verwijderen.';

  @override
  String profileErrorGeneric(String message) {
    return 'Fout: $message';
  }

  @override
  String profileErrorDelete(String error) {
    return 'Fout bij verwijderen: $error';
  }

  @override
  String get profileLanguageSection => 'TAAL';

  @override
  String get profileLanguageNl => 'Nederlands';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileNotificationsSection => 'Notificaties';

  @override
  String get profileNotificationsReceive => 'Notificaties ontvangen';

  @override
  String get profileNotificationsEnableInSettings =>
      'Schakel notificaties in via de instellingen.';

  @override
  String get filterOnboardingTitle => 'Stel je eerste zoekfilter in';

  @override
  String get filterOnboardingDesc =>
      'Een zoekfilter slaat jouw woonwensen op. Geef aan in welke stad je wilt wonen, wat je budget is en hoeveel kamers je nodig hebt — dan toont WoonMe direct passend aanbod.';

  @override
  String get filterCityLabel => 'Stad of gemeente';

  @override
  String get filterRadiusLabel => 'Straal:';

  @override
  String get filterMinRentLabel => 'Min. huur €';

  @override
  String get filterMaxRentLabel => 'Max. huur €';

  @override
  String get filterMinRoomsLabel => 'Min. kamers:';

  @override
  String get filterMinSizeLabel => 'Min. oppervlakte (m²)';

  @override
  String get filterSaveButton => 'Filter opslaan';

  @override
  String get filterErrorAtLeastOne =>
      'Vul minimaal één filter in om verder te gaan.';

  @override
  String get filterDefaultLabel => 'Mijn zoekfilter';

  @override
  String get filterWholeNL => 'Heel Nederland';

  @override
  String filterFromPrice(int price) {
    return 'v.a. €$price';
  }

  @override
  String filterUpToPrice(int price) {
    return 't/m €$price';
  }

  @override
  String filterRooms(String count) {
    return '$count kamers';
  }

  @override
  String get zoekenNewFilter => 'Nieuw zoekfilter';

  @override
  String get zoekenSave => 'Opslaan';

  @override
  String get zoekenCityLabel => 'Plaatsnaam *';

  @override
  String get zoekenCityRequired => 'Vul een plaatsnaam in';

  @override
  String get zoekenSavedSuccess => 'Zoekfilter opgeslagen';

  @override
  String get zoekenStayUpdated => 'Blijf op de hoogte van nieuw aanbod';

  @override
  String get zoekenNoFilters => 'Nog geen zoekfilters opgeslagen.';

  @override
  String get aanbodTabLabel => 'Aanbod';

  @override
  String get aanbodFilterTabLabel => 'Zoekfilter';

  @override
  String get aanbodNewTabLabel => 'Nieuw';

  @override
  String get aanbodFiltersHeader => 'Zoekfilters';

  @override
  String aanbodFiltersHeaderCollapsed(String label) {
    return 'Zoekfilters · $label';
  }

  @override
  String get aanbodRadiusLabel => 'Straal:';

  @override
  String get aanbodSortLabel => 'Sortering:';

  @override
  String get aanbodSortNewest => 'Nieuwste';

  @override
  String get aanbodSortOldest => 'Oudste';

  @override
  String get aanbodSortPriceAsc => 'Prijs ↑';

  @override
  String get aanbodSortPriceDesc => 'Prijs ↓';

  @override
  String get aanbodSortDistance => 'Afstand';

  @override
  String get aanbodBannerText =>
      'Wees er als eerste bij — ontvang een melding zodra er nieuw aanbod beschikbaar is';

  @override
  String get aanbodEmptyTitle => 'Geen zoekfilters ingesteld';

  @override
  String get aanbodEmptyBody =>
      'Ga naar het \"Zoekfilter\" tabblad om je voorkeuren op te slaan en passend woningaanbod te zien.';

  @override
  String get aanbodNoResults => 'Geen woningen gevonden.';

  @override
  String get aanbodErrorRetry => 'Opnieuw proberen';

  @override
  String get aanbodBadgeNew => 'Nieuw';

  @override
  String get aanbodBadgeRecent => 'Recent';

  @override
  String get aanbodUnknownAddress => 'Onbekend adres';

  @override
  String get nieuwToday => 'Vandaag';

  @override
  String get nieuwThisWeek => 'Deze week';

  @override
  String get nieuwEmptyNoFilter =>
      'Stel eerst een zoekfilter in via het \"Zoekfilter\" tabblad.';

  @override
  String get nieuwEmptyNoResults =>
      'Deze week zijn geen nieuwe woningen beschikbaar gekomen.';

  @override
  String get nieuwErrorLoadFailed => 'Kon woningen niet laden';

  @override
  String get nieuwRetry => 'Opnieuw';

  @override
  String get feedbackPageTitle => 'Feedback geven';

  @override
  String get feedbackTitleLabel => 'Titel';

  @override
  String get feedbackDescLabel => 'Omschrijving';

  @override
  String get feedbackSubmit => 'Verstuur';

  @override
  String get feedbackTitleRequired => 'Vul een titel in';

  @override
  String get feedbackDescRequired => 'Vul een omschrijving in';

  @override
  String get feedbackSuccessMessage => 'Bedankt voor je feedback!';

  @override
  String feedbackErrorMessage(String error) {
    return 'Fout bij verzenden: $error';
  }

  @override
  String get updatePromptTitle => 'Update beschikbaar';

  @override
  String get updatePromptBody =>
      'Er is een nieuwe versie van de app beschikbaar. Wil je nu bijwerken?';

  @override
  String get updatePromptLater => 'Later';

  @override
  String get updatePromptUpdate => 'Bijwerken';

  @override
  String get updateEnforceTitle => 'Update vereist';

  @override
  String get updateEnforceBody =>
      'Om de app te blijven gebruiken moet je updaten naar de nieuwste versie.';

  @override
  String get updateEnforceButton => 'Bijwerken';

  @override
  String get notifPermissionTitle => 'Blijf op de hoogte';

  @override
  String get notifPermissionBody =>
      'Ontvang meldingen bij nieuwe functies en belangrijke updates in de app.';

  @override
  String get notifPermissionSettingsHint =>
      'Je kunt dit altijd wijzigen via de instellingen van de app.';

  @override
  String get notifPermissionAllow => 'Ja, houd me op de hoogte';

  @override
  String get notifPermissionSkip => 'Overslaan';

  @override
  String get propertySourcePickerTitle => 'Kies een bron';

  @override
  String propertySourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bronnen',
      one: '1 bron',
    );
    return '$_temp0';
  }
}
