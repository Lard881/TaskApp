// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PlanPal';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription =>
      'PlanPal helps you manage tasks, track progress, and collaborate with your team — all in one place.';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String taskCountSubtitle(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $countString tasks due today.',
      one: 'You have 1 task due today.',
      zero: 'You have no tasks due today.',
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get todaysTasks => 'Today\'s Tasks';

  @override
  String get viewAll => 'View All';

  @override
  String get noTasksToday => 'No tasks due today. Enjoy your day!';

  @override
  String get newTask => 'New Task';

  @override
  String get calendar => 'Calendar';

  @override
  String get analytics => 'Analytics';

  @override
  String get documents => 'Documents';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get performanceOverview => 'Performance Overview';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In Progress';

  @override
  String get overdue => 'Overdue';

  @override
  String get productivity => 'Productivity';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get noTasksEmpty => 'No tasks here. Add one!';

  @override
  String get filterAll => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortDueDateAsc => 'Due Date (Earliest First)';

  @override
  String get sortDueDateDesc => 'Due Date (Latest First)';

  @override
  String get sortPriorityHighLow => 'Priority (High to Low)';

  @override
  String get sortPriorityLowHigh => 'Priority (Low to High)';

  @override
  String get sortNameAZ => 'Name (A–Z)';

  @override
  String get sortNameZA => 'Name (Z–A)';

  @override
  String get taskNameLabel => 'Task Name';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get dueTimeLabel => 'Due Time';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get assigneeLabel => 'Assignee (optional)';

  @override
  String get descriptionLabel => 'Description (optional)';

  @override
  String get saveTask => 'Save Task';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get allDay => 'All day';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get taskNameRequired => 'Task name is required.';

  @override
  String get taskNameTooLong => 'Task name must be 100 characters or fewer.';

  @override
  String get dueDateRequired => 'Due date is required.';

  @override
  String get dueTimeRequired => 'Due time is required.';

  @override
  String get priorityRequired => 'Priority is required.';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get reopen => 'Reopen';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get taskAdded => 'Task added successfully.';

  @override
  String get taskUpdated => 'Task updated successfully.';

  @override
  String get taskDeleted => 'Task deleted.';

  @override
  String get taskMarkedComplete => 'Task marked as complete.';

  @override
  String get taskReopened => 'Task reopened.';

  @override
  String get deleteTaskConfirm => 'Delete this task?';

  @override
  String get deleteTaskBody => 'This action cannot be undone.';

  @override
  String get conversations => 'Conversations';

  @override
  String get searchConversations => 'Search conversations…';

  @override
  String get noConversations => 'No conversations yet.';

  @override
  String get noResults => 'No results found.';

  @override
  String get typeAMessage => 'Type a message…';

  @override
  String get startConversation => 'Start Conversation';

  @override
  String get newConversation => 'New Conversation';

  @override
  String get searchContacts => 'Search contacts…';

  @override
  String get noContactsFound => 'No contacts found.';

  @override
  String get selectParticipant => 'Please select at least one participant.';

  @override
  String get groupLimit =>
      'Group conversations are limited to 50 participants.';

  @override
  String get tasksCompleted => 'Tasks Completed';

  @override
  String get activeProjects => 'Active Projects';

  @override
  String get teamMembers => 'Team Members';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivity => 'No recent activity.';

  @override
  String get editProfileSettings => 'Edit Profile Settings';

  @override
  String get avatarUpdateFailed => 'Could not update avatar. Please try again.';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get lastNameLabel => 'Last Name';

  @override
  String get roleLabel => 'Role / Title (optional)';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone Number (optional)';

  @override
  String get save => 'Save';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get profileSaveFailed => 'Could not save profile. Please try again.';

  @override
  String get firstNameRequired => 'First name is required.';

  @override
  String get lastNameRequired => 'Last name is required.';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get settings => 'Settings';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get supportLegals => 'Support & Legals';

  @override
  String get personalProfile => 'Personal Profile';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get securityPrivacy => 'Security & Privacy';

  @override
  String get interfaceTheme => 'Interface Theme';

  @override
  String get appLanguage => 'App Language';

  @override
  String get timeZone => 'Time Zone';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get rateOurApp => 'Rate Our App';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutConfirm => 'Are you sure you want to log out?';

  @override
  String get loggedOut => 'You have been logged out.';

  @override
  String get logOutFailed => 'Log out failed. Please try again.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System Default';

  @override
  String get taskReminders => 'Task Reminders';

  @override
  String get dueDateAlerts => 'Due Date Alerts';

  @override
  String get chatMessages => 'Chat Messages';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String get prefSaveFailed => 'Could not save preference. Please try again.';

  @override
  String get changePassword => 'Change Password';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get dataPrivacyPolicy => 'Data Privacy Policy';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm New Password';

  @override
  String get passwordChanged => 'Password changed successfully.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get passwordLength => 'Password must be between 8 and 64 characters.';

  @override
  String get passwordIncorrect => 'Current password is incorrect.';

  @override
  String get passwordSaveFailed =>
      'Could not update password. Please try again.';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get supportEmail => 'support@planpal.app';

  @override
  String get noEmailApp =>
      'No email app found. Please email support@planpal.app directly.';

  @override
  String get helpLoadFailed =>
      'Could not load help content. Please try again later.';

  @override
  String get storeOpenFailed =>
      'Unable to open the store. Please try again later.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get changesSaveFailed =>
      'Changes could not be saved. Please try again.';

  @override
  String get dataLoadFailed => 'Could not load saved data. Starting fresh.';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get activityCreated => 'created';

  @override
  String get activityUpdated => 'updated';

  @override
  String get activityCompleted => 'completed';

  @override
  String get deletedTask => '[Deleted task]';

  @override
  String get noMessagesYet => 'No messages yet. Say hi!';

  @override
  String get quickActions => 'Quick Actions';
}
