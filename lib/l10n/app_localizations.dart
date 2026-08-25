import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'PlanPal'**
  String get appName;

  /// Application version string
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// Short app description shown on the About screen (≤150 chars)
  ///
  /// In en, this message translates to:
  /// **'PlanPal helps you manage tasks, track progress, and collaborate with your team — all in one place.'**
  String get appDescription;

  /// Time-based salutation for 05:00–11:59
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Time-based salutation for 12:00–17:59
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// Time-based salutation for 18:00–04:59
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Subtitle on Home screen showing tasks due today
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{You have no tasks due today.} =1{You have 1 task due today.} other{You have {count} tasks due today.}}'**
  String taskCountSubtitle(int count);

  /// Bottom nav label — Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav label — Tasks tab
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// Bottom nav label — Chat tab
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// Bottom nav label — Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom nav label — Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Section heading on Home screen
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todaysTasks;

  /// Link to see all tasks due today
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Empty state in Today's Tasks section
  ///
  /// In en, this message translates to:
  /// **'No tasks due today. Enjoy your day!'**
  String get noTasksToday;

  /// Quick action label
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// Quick action label
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Quick action label
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Quick action label
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// Snackbar message for unimplemented features
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// Section heading on Home screen
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get performanceOverview;

  /// Metric tile label and filter tab
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Metric tile label
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Metric tile label
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Metric tile label
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// Tasks screen heading
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// Empty state on Tasks screen
  ///
  /// In en, this message translates to:
  /// **'No tasks here. Add one!'**
  String get noTasksEmpty;

  /// Filter tab label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter tab label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// Filter tab label
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get filterUpcoming;

  /// Filter tab label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// Sort modal heading
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Sort option
  ///
  /// In en, this message translates to:
  /// **'Due Date (Earliest First)'**
  String get sortDueDateAsc;

  /// Sort option
  ///
  /// In en, this message translates to:
  /// **'Due Date (Latest First)'**
  String get sortDueDateDesc;

  /// Sort option
  ///
  /// In en, this message translates to:
  /// **'Priority (High to Low)'**
  String get sortPriorityHighLow;

  /// Sort option
  ///
  /// In en, this message translates to:
  /// **'Priority (Low to High)'**
  String get sortPriorityLowHigh;

  /// Sort option
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get sortNameAZ;

  /// Sort option
  ///
  /// In en, this message translates to:
  /// **'Name (Z–A)'**
  String get sortNameZA;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get taskNameLabel;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Due Time'**
  String get dueTimeLabel;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Assignee (optional)'**
  String get assigneeLabel;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionLabel;

  /// Primary button on Add Task sheet
  ///
  /// In en, this message translates to:
  /// **'Save Task'**
  String get saveTask;

  /// Primary button on Edit Task sheet
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Secondary dismiss button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Shown when a task has no due time
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// Priority badge label
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Priority badge label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// Priority badge label
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Task name is required.'**
  String get taskNameRequired;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Task name must be 100 characters or fewer.'**
  String get taskNameTooLong;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Due date is required.'**
  String get dueDateRequired;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Due time is required.'**
  String get dueTimeRequired;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Priority is required.'**
  String get priorityRequired;

  /// Task action button label
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// Task action button label
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// Context menu and button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Context menu and button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Snackbar confirmation
  ///
  /// In en, this message translates to:
  /// **'Task added successfully.'**
  String get taskAdded;

  /// Snackbar confirmation
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully.'**
  String get taskUpdated;

  /// Snackbar confirmation
  ///
  /// In en, this message translates to:
  /// **'Task deleted.'**
  String get taskDeleted;

  /// Snackbar confirmation
  ///
  /// In en, this message translates to:
  /// **'Task marked as complete.'**
  String get taskMarkedComplete;

  /// Snackbar confirmation
  ///
  /// In en, this message translates to:
  /// **'Task reopened.'**
  String get taskReopened;

  /// Confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get deleteTaskConfirm;

  /// Confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteTaskBody;

  /// Chat screen heading
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// Search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search conversations…'**
  String get searchConversations;

  /// Empty state on Chat screen
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get noConversations;

  /// Empty state when search returns nothing
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResults;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeAMessage;

  /// Button label on New Conversation sheet
  ///
  /// In en, this message translates to:
  /// **'Start Conversation'**
  String get startConversation;

  /// Sheet title for starting a new conversation
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// Search field placeholder on New Conversation sheet
  ///
  /// In en, this message translates to:
  /// **'Search contacts…'**
  String get searchContacts;

  /// Empty state on contacts list
  ///
  /// In en, this message translates to:
  /// **'No contacts found.'**
  String get noContactsFound;

  /// Inline validation error on New Conversation sheet
  ///
  /// In en, this message translates to:
  /// **'Please select at least one participant.'**
  String get selectParticipant;

  /// Inline validation error when too many participants selected
  ///
  /// In en, this message translates to:
  /// **'Group conversations are limited to 50 participants.'**
  String get groupLimit;

  /// Profile stats tile label
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get tasksCompleted;

  /// Profile stats tile label
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get activeProjects;

  /// Profile stats tile label
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// Profile section heading
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Empty state in Recent Activity section
  ///
  /// In en, this message translates to:
  /// **'No recent activity.'**
  String get noRecentActivity;

  /// Button label on Profile screen
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Settings'**
  String get editProfileSettings;

  /// Snackbar error
  ///
  /// In en, this message translates to:
  /// **'Could not update avatar. Please try again.'**
  String get avatarUpdateFailed;

  /// Profile form field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// Profile form field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// Profile form field label
  ///
  /// In en, this message translates to:
  /// **'Role / Title (optional)'**
  String get roleLabel;

  /// Profile form field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Profile form field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number (optional)'**
  String get phoneLabel;

  /// Primary button on profile edit sheet
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Snackbar confirmation
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdated;

  /// Snackbar error
  ///
  /// In en, this message translates to:
  /// **'Could not save profile. Please try again.'**
  String get profileSaveFailed;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get firstNameRequired;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Last name is required.'**
  String get lastNameRequired;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequired;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailInvalid;

  /// Settings screen heading
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Support & Legals'**
  String get supportLegals;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get personalProfile;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityPrivacy;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'Interface Theme'**
  String get interfaceTheme;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get timeZone;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Settings list item label
  ///
  /// In en, this message translates to:
  /// **'Rate Our App'**
  String get rateOurApp;

  /// Settings log out button label
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Confirmation dialog body for log out
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// Snackbar confirmation after log out
  ///
  /// In en, this message translates to:
  /// **'You have been logged out.'**
  String get loggedOut;

  /// Snackbar error when log out fails
  ///
  /// In en, this message translates to:
  /// **'Log out failed. Please try again.'**
  String get logOutFailed;

  /// Theme option label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Theme option label
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// Notification toggle label
  ///
  /// In en, this message translates to:
  /// **'Task Reminders'**
  String get taskReminders;

  /// Notification toggle label
  ///
  /// In en, this message translates to:
  /// **'Due Date Alerts'**
  String get dueDateAlerts;

  /// Notification toggle label
  ///
  /// In en, this message translates to:
  /// **'Chat Messages'**
  String get chatMessages;

  /// Notification toggle label
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// Snackbar error when preference save fails
  ///
  /// In en, this message translates to:
  /// **'Could not save preference. Please try again.'**
  String get prefSaveFailed;

  /// Security screen list item label
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Security screen toggle label
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// Security screen list item label
  ///
  /// In en, this message translates to:
  /// **'Data Privacy Policy'**
  String get dataPrivacyPolicy;

  /// Change password form field label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Change password form field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Change password form field label
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmPassword;

  /// Snackbar confirmation
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChanged;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be between 8 and 64 characters.'**
  String get passwordLength;

  /// Inline validation error
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get passwordIncorrect;

  /// Snackbar error
  ///
  /// In en, this message translates to:
  /// **'Could not update password. Please try again.'**
  String get passwordSaveFailed;

  /// Help screen button label
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Support email address
  ///
  /// In en, this message translates to:
  /// **'support@planpal.app'**
  String get supportEmail;

  /// Snackbar error when no email client is available
  ///
  /// In en, this message translates to:
  /// **'No email app found. Please email support@planpal.app directly.'**
  String get noEmailApp;

  /// Error message on Help screen when FAQ fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load help content. Please try again later.'**
  String get helpLoadFailed;

  /// Snackbar error when app store cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Unable to open the store. Please try again later.'**
  String get storeOpenFailed;

  /// Generic error snackbar
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Snackbar error for failed local storage write
  ///
  /// In en, this message translates to:
  /// **'Changes could not be saved. Please try again.'**
  String get changesSaveFailed;

  /// Snackbar shown when Hive init times out or fails
  ///
  /// In en, this message translates to:
  /// **'Could not load saved data. Starting fresh.'**
  String get dataLoadFailed;

  /// Help screen section heading
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// Verb used in activity feed: Task X created
  ///
  /// In en, this message translates to:
  /// **'created'**
  String get activityCreated;

  /// Verb used in activity feed: Task X updated
  ///
  /// In en, this message translates to:
  /// **'updated'**
  String get activityUpdated;

  /// Verb used in activity feed: Task X completed
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get activityCompleted;

  /// Placeholder when referenced task no longer exists
  ///
  /// In en, this message translates to:
  /// **'[Deleted task]'**
  String get deletedTask;

  /// Empty state in conversation detail
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hi!'**
  String get noMessagesYet;

  /// Home screen section heading
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;
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
      <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
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
