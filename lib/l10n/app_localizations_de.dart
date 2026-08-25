// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'PlanPal';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription =>
      'PlanPal hilft dir, Aufgaben zu verwalten, Fortschritte zu verfolgen und mit deinem Team zusammenzuarbeiten – alles an einem Ort.';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String taskCountSubtitle(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Heute $countString Aufgaben fällig.',
      one: 'Heute 1 Aufgabe fällig.',
      zero: 'Heute keine Aufgaben fällig.',
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Start';

  @override
  String get navTasks => 'Aufgaben';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get todaysTasks => 'Heutige Aufgaben';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get noTasksToday => 'Heute keine Aufgaben. Genieße den Tag!';

  @override
  String get newTask => 'Neue Aufgabe';

  @override
  String get calendar => 'Kalender';

  @override
  String get analytics => 'Analysen';

  @override
  String get documents => 'Dokumente';

  @override
  String get comingSoon => 'Demnächst verfügbar!';

  @override
  String get performanceOverview => 'Leistungsübersicht';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get inProgress => 'In Bearbeitung';

  @override
  String get overdue => 'Überfällig';

  @override
  String get productivity => 'Produktivität';

  @override
  String get myTasks => 'Meine Aufgaben';

  @override
  String get noTasksEmpty => 'Keine Aufgaben vorhanden. Füge eine hinzu!';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterToday => 'Heute';

  @override
  String get filterUpcoming => 'Bevorstehend';

  @override
  String get filterCompleted => 'Abgeschlossen';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get sortDueDateAsc => 'Fälligkeitsdatum (früheste zuerst)';

  @override
  String get sortDueDateDesc => 'Fälligkeitsdatum (späteste zuerst)';

  @override
  String get sortPriorityHighLow => 'Priorität (hoch nach niedrig)';

  @override
  String get sortPriorityLowHigh => 'Priorität (niedrig nach hoch)';

  @override
  String get sortNameAZ => 'Name (A–Z)';

  @override
  String get sortNameZA => 'Name (Z–A)';

  @override
  String get taskNameLabel => 'Aufgabenname';

  @override
  String get dueDateLabel => 'Fälligkeitsdatum';

  @override
  String get dueTimeLabel => 'Fälligkeitszeit';

  @override
  String get priorityLabel => 'Priorität';

  @override
  String get assigneeLabel => 'Verantwortliche Person (optional)';

  @override
  String get descriptionLabel => 'Beschreibung (optional)';

  @override
  String get saveTask => 'Aufgabe speichern';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get allDay => 'Ganzer Tag';

  @override
  String get priorityHigh => 'Hoch';

  @override
  String get priorityMedium => 'Mittel';

  @override
  String get priorityLow => 'Niedrig';

  @override
  String get taskNameRequired => 'Aufgabenname ist erforderlich.';

  @override
  String get taskNameTooLong => 'Der Name darf maximal 100 Zeichen lang sein.';

  @override
  String get dueDateRequired => 'Fälligkeitsdatum ist erforderlich.';

  @override
  String get dueTimeRequired => 'Fälligkeitszeit ist erforderlich.';

  @override
  String get priorityRequired => 'Priorität ist erforderlich.';

  @override
  String get markComplete => 'Als abgeschlossen markieren';

  @override
  String get reopen => 'Erneut öffnen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get taskAdded => 'Aufgabe erfolgreich hinzugefügt.';

  @override
  String get taskUpdated => 'Aufgabe erfolgreich aktualisiert.';

  @override
  String get taskDeleted => 'Aufgabe gelöscht.';

  @override
  String get taskMarkedComplete => 'Aufgabe als abgeschlossen markiert.';

  @override
  String get taskReopened => 'Aufgabe wieder geöffnet.';

  @override
  String get deleteTaskConfirm => 'Diese Aufgabe löschen?';

  @override
  String get deleteTaskBody =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get conversations => 'Unterhaltungen';

  @override
  String get searchConversations => 'Unterhaltungen suchen…';

  @override
  String get noConversations => 'Noch keine Unterhaltungen.';

  @override
  String get noResults => 'Keine Ergebnisse gefunden.';

  @override
  String get typeAMessage => 'Nachricht eingeben…';

  @override
  String get startConversation => 'Unterhaltung starten';

  @override
  String get newConversation => 'Neue Unterhaltung';

  @override
  String get searchContacts => 'Kontakte suchen…';

  @override
  String get noContactsFound => 'Keine Kontakte gefunden.';

  @override
  String get selectParticipant =>
      'Bitte mindestens einen Teilnehmer auswählen.';

  @override
  String get groupLimit =>
      'Gruppenunterhaltungen sind auf 50 Teilnehmer begrenzt.';

  @override
  String get tasksCompleted => 'Abgeschlossene Aufgaben';

  @override
  String get activeProjects => 'Aktive Projekte';

  @override
  String get teamMembers => 'Teammitglieder';

  @override
  String get recentActivity => 'Letzte Aktivitäten';

  @override
  String get noRecentActivity => 'Keine letzten Aktivitäten.';

  @override
  String get editProfileSettings => 'Profil bearbeiten';

  @override
  String get avatarUpdateFailed =>
      'Avatar konnte nicht aktualisiert werden. Erneut versuchen.';

  @override
  String get firstNameLabel => 'Vorname';

  @override
  String get lastNameLabel => 'Nachname';

  @override
  String get roleLabel => 'Rolle / Titel (optional)';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get phoneLabel => 'Telefonnummer (optional)';

  @override
  String get save => 'Speichern';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert.';

  @override
  String get profileSaveFailed =>
      'Profil konnte nicht gespeichert werden. Erneut versuchen.';

  @override
  String get firstNameRequired => 'Vorname ist erforderlich.';

  @override
  String get lastNameRequired => 'Nachname ist erforderlich.';

  @override
  String get emailRequired => 'E-Mail ist erforderlich.';

  @override
  String get emailInvalid => 'Bitte eine gültige E-Mail-Adresse eingeben.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get accountSettings => 'Konto';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get supportLegals => 'Support & Rechtliches';

  @override
  String get personalProfile => 'Persönliches Profil';

  @override
  String get notificationPreferences => 'Benachrichtigungen';

  @override
  String get securityPrivacy => 'Sicherheit & Datenschutz';

  @override
  String get interfaceTheme => 'Erscheinungsbild';

  @override
  String get appLanguage => 'Sprache';

  @override
  String get timeZone => 'Zeitzone';

  @override
  String get helpSupport => 'Hilfe & Support';

  @override
  String get about => 'Über die App';

  @override
  String get rateOurApp => 'App bewerten';

  @override
  String get logOut => 'Abmelden';

  @override
  String get logOutConfirm => 'Wirklich abmelden?';

  @override
  String get loggedOut => 'Du wurdest abgemeldet.';

  @override
  String get logOutFailed => 'Abmelden fehlgeschlagen. Erneut versuchen.';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get taskReminders => 'Aufgabenerinnerungen';

  @override
  String get dueDateAlerts => 'Fälligkeitswarnungen';

  @override
  String get chatMessages => 'Chat-Nachrichten';

  @override
  String get weeklySummary => 'Wöchentliche Zusammenfassung';

  @override
  String get prefSaveFailed =>
      'Einstellung konnte nicht gespeichert werden. Erneut versuchen.';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get biometricLogin => 'Biometrische Anmeldung';

  @override
  String get dataPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmPassword => 'Neues Passwort bestätigen';

  @override
  String get passwordChanged => 'Passwort erfolgreich geändert.';

  @override
  String get passwordMismatch => 'Passwörter stimmen nicht überein.';

  @override
  String get passwordLength =>
      'Das Passwort muss zwischen 8 und 64 Zeichen lang sein.';

  @override
  String get passwordIncorrect => 'Das aktuelle Passwort ist falsch.';

  @override
  String get passwordSaveFailed =>
      'Passwort konnte nicht aktualisiert werden. Erneut versuchen.';

  @override
  String get contactSupport => 'Support kontaktieren';

  @override
  String get supportEmail => 'support@planpal.app';

  @override
  String get noEmailApp =>
      'Keine E-Mail-App gefunden. Bitte schreib direkt an support@planpal.app.';

  @override
  String get helpLoadFailed =>
      'Hilfe konnte nicht geladen werden. Später erneut versuchen.';

  @override
  String get storeOpenFailed =>
      'Store konnte nicht geöffnet werden. Später erneut versuchen.';

  @override
  String get somethingWentWrong =>
      'Etwas ist schiefgelaufen. Erneut versuchen.';

  @override
  String get changesSaveFailed =>
      'Änderungen konnten nicht gespeichert werden. Erneut versuchen.';

  @override
  String get dataLoadFailed =>
      'Gespeicherte Daten konnten nicht geladen werden. Neustart.';

  @override
  String get faqTitle => 'Häufig gestellte Fragen';

  @override
  String get activityCreated => 'erstellt';

  @override
  String get activityUpdated => 'aktualisiert';

  @override
  String get activityCompleted => 'abgeschlossen';

  @override
  String get deletedTask => '[Gelöschte Aufgabe]';

  @override
  String get noMessagesYet => 'Noch keine Nachrichten. Sag Hallo!';

  @override
  String get quickActions => 'Schnellaktionen';
}
