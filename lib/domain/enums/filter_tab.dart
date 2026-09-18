/// The active filter tab on the Tasks screen (Req 6).
enum FilterTab {
  all,
  today,
  upcoming,
  completed;

  /// Label shown on the tab (matches AppStrings).
  String get label {
    switch (this) {
      case FilterTab.all:
        return 'All';
      case FilterTab.today:
        return 'Today';
      case FilterTab.upcoming:
        return 'Upcoming';
      case FilterTab.completed:
        return 'Completed';
    }
  }
}
