/// Sort criteria available on the Tasks screen (Req 8).
enum SortOption {
  dueDateAsc,
  dueDateDesc,
  priorityHighToLow,
  priorityLowToHigh,
  nameAZ,
  nameZA;

  /// Human-readable label shown in the sort modal.
  String get label {
    switch (this) {
      case SortOption.dueDateAsc:
        return 'Due Date (Earliest First)';
      case SortOption.dueDateDesc:
        return 'Due Date (Latest First)';
      case SortOption.priorityHighToLow:
        return 'Priority (High to Low)';
      case SortOption.priorityLowToHigh:
        return 'Priority (Low to High)';
      case SortOption.nameAZ:
        return 'Name (A–Z)';
      case SortOption.nameZA:
        return 'Name (Z–A)';
    }
  }
}
