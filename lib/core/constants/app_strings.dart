/// Hard-coded English string constants used across the app.
/// Keys that are also covered by ARB localisation files use the same text
/// here as a fallback; the l10n-generated AppLocalizations class takes
/// precedence at runtime.
abstract final class AppStrings {
  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'PlanPal';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'PlanPal helps you manage tasks, track progress, and collaborate with your team — all in one place.';

  // ── Greetings ─────────────────────────────────────────────────────────────
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';

  // ── Bottom nav labels ─────────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navTasks = 'Tasks';
  static const String navChat = 'Chat';
  static const String navProfile = 'Profile';
  static const String navSettings = 'Settings';

  // ── Home screen ───────────────────────────────────────────────────────────
  static const String todaysTasks = "Today's Tasks";
  static const String viewAll = 'View All';
  static const String noTasksToday = 'No tasks due today. Enjoy your day!';
  static const String newTask = 'New Task';
  static const String calendar = 'Calendar';
  static const String analytics = 'Analytics';
  static const String documents = 'Documents';
  static const String comingSoon = 'Coming soon!';

  // ── Performance overview ──────────────────────────────────────────────────
  static const String completed = 'Completed';
  static const String inProgress = 'In Progress';
  static const String overdue = 'Overdue';
  static const String productivity = 'Productivity';

  // ── Tasks screen ──────────────────────────────────────────────────────────
  static const String myTasks = 'My Tasks';
  static const String noTasksEmpty = 'No tasks here. Add one!';
  static const String filterAll = 'All';
  static const String filterToday = 'Today';
  static const String filterUpcoming = 'Upcoming';
  static const String filterCompleted = 'Completed';

  // ── Sort options ──────────────────────────────────────────────────────────
  static const String sortDueDateAsc = 'Due Date (Earliest First)';
  static const String sortDueDateDesc = 'Due Date (Latest First)';
  static const String sortPriorityHighLow = 'Priority (High to Low)';
  static const String sortPriorityLowHigh = 'Priority (Low to High)';
  static const String sortNameAZ = 'Name (A–Z)';
  static const String sortNameZA = 'Name (Z–A)';

  // ── Task form ─────────────────────────────────────────────────────────────
  static const String taskNameLabel = 'Task Name';
  static const String dueDateLabel = 'Due Date';
  static const String dueTimeLabel = 'Due Time';
  static const String priorityLabel = 'Priority';
  static const String assigneeLabel = 'Assignee (optional)';
  static const String descriptionLabel = 'Description (optional)';
  static const String saveTask = 'Save Task';
  static const String saveChanges = 'Save Changes';
  static const String cancel = 'Cancel';
  static const String allDay = 'All day';

  // ── Task validation ───────────────────────────────────────────────────────
  static const String taskNameRequired = 'Task name is required.';
  static const String taskNameTooLong = 'Task name must be 100 characters or fewer.';
  static const String dueDateRequired = 'Due date is required.';
  static const String dueTimeRequired = 'Due time is required.';
  static const String priorityRequired = 'Priority is required.';

  // ── Task actions ──────────────────────────────────────────────────────────
  static const String markComplete = 'Mark Complete';
  static const String reopen = 'Reopen';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String taskAdded = 'Task added successfully.';
  static const String taskUpdated = 'Task updated successfully.';
  static const String taskDeleted = 'Task deleted.';
  static const String taskMarkedComplete = 'Task marked as complete.';
  static const String taskReopened = 'Task reopened.';
  static const String deleteTaskConfirm = 'Delete this task?';

  // ── Chat screen ───────────────────────────────────────────────────────────
  static const String conversations = 'Conversations';
  static const String searchConversations = 'Search conversations…';
  static const String noConversations = 'No conversations yet.';
  static const String noResults = 'No results found.';
  static const String typeAMessage = 'Type a message…';
  static const String startConversation = 'Start Conversation';
  static const String noContactsFound = 'No contacts found.';
  static const String selectParticipant = 'Please select at least one participant.';
  static const String groupLimit = 'Group conversations are limited to 50 participants.';

  // ── Profile screen ────────────────────────────────────────────────────────
  static const String tasksCompleted = 'Tasks Completed';
  static const String activeProjects = 'Active Projects';
  static const String teamMembers = 'Team Members';
  static const String recentActivity = 'Recent Activity';
  static const String noRecentActivity = 'No recent activity.';
  static const String editProfileSettings = 'Edit Profile Settings';
  static const String avatarUpdateFailed = 'Could not update avatar. Please try again.';

  // ── Profile form ──────────────────────────────────────────────────────────
  static const String firstNameLabel = 'First Name';
  static const String lastNameLabel = 'Last Name';
  static const String roleLabel = 'Role / Title (optional)';
  static const String emailLabel = 'Email';
  static const String phoneLabel = 'Phone Number (optional)';
  static const String save = 'Save';
  static const String profileUpdated = 'Profile updated successfully.';
  static const String profileSaveFailed = 'Could not save profile. Please try again.';

  // ── Profile validation ────────────────────────────────────────────────────
  static const String firstNameRequired = 'First name is required.';
  static const String lastNameRequired = 'Last name is required.';
  static const String emailRequired = 'Email is required.';
  static const String emailInvalid = 'Enter a valid email address.';

  // ── Settings screen ───────────────────────────────────────────────────────
  static const String settings = 'Settings';
  static const String accountSettings = 'Account Settings';
  static const String preferences = 'Preferences';
  static const String supportLegals = 'Support & Legals';
  static const String personalProfile = 'Personal Profile';
  static const String notificationPreferences = 'Notification Preferences';
  static const String securityPrivacy = 'Security & Privacy';
  static const String interfaceTheme = 'Interface Theme';
  static const String appLanguage = 'App Language';
  static const String timeZone = 'Time Zone';
  static const String helpSupport = 'Help & Support';
  static const String about = 'About';
  static const String rateOurApp = 'Rate Our App';
  static const String logOut = 'Log Out';
  static const String logOutConfirm = 'Are you sure you want to log out?';
  static const String loggedOut = 'You have been logged out.';
  static const String logOutFailed = 'Log out failed. Please try again.';

  // ── Theme options ─────────────────────────────────────────────────────────
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String themeSystem = 'System Default';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String taskReminders = 'Task Reminders';
  static const String dueDateAlerts = 'Due Date Alerts';
  static const String chatMessages = 'Chat Messages';
  static const String weeklySummary = 'Weekly Summary';
  static const String prefSaveFailed = 'Could not save preference. Please try again.';

  // ── Security ─────────────────────────────────────────────────────────────
  static const String changePassword = 'Change Password';
  static const String biometricLogin = 'Biometric Login';
  static const String dataPrivacyPolicy = 'Data Privacy Policy';
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password';
  static const String confirmPassword = 'Confirm New Password';
  static const String passwordChanged = 'Password changed successfully.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String passwordLength = 'Password must be between 8 and 64 characters.';
  static const String passwordIncorrect = 'Current password is incorrect.';
  static const String passwordSaveFailed = 'Could not update password. Please try again.';

  // ── Help & Support ────────────────────────────────────────────────────────
  static const String contactSupport = 'Contact Support';
  static const String supportEmail = 'support@planpal.app';
  static const String noEmailApp =
      'No email app found. Please email support@planpal.app directly.';
  static const String helpLoadFailed =
      'Could not load help content. Please try again later.';
  static const String storeOpenFailed =
      'Unable to open the store. Please try again later.';

  // ── Generic errors ────────────────────────────────────────────────────────
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String changesSaveFailed = 'Changes could not be saved. Please try again.';
  static const String dataLoadFailed = 'Could not load saved data. Starting fresh.';
}
