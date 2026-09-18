/// Extension methods on [String] used throughout the app.
extension StringExtensions on String {
  /// Returns this string truncated to [max] characters, with an ellipsis
  /// appended if the string was longer than [max].
  ///
  /// Example:
  /// ```dart
  /// 'Hello, world!'.truncate(5); // 'Hello…'
  /// 'Hi'.truncate(5);            // 'Hi'
  /// ```
  String truncate(int max) {
    assert(max > 0, 'max must be positive');
    if (length <= max) return this;
    return '${substring(0, max)}…';
  }

  /// Returns `true` if this string is not null and not blank (empty or
  /// whitespace-only).
  bool get isNotBlank => trim().isNotEmpty;

  /// Returns `true` if this string is blank (empty or whitespace-only).
  bool get isBlank => trim().isEmpty;

  /// Returns the first [n] characters, or the full string if shorter.
  String take(int n) => length <= n ? this : substring(0, n);

  /// Capitalises only the first character of this string.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

/// Null-safe extension for nullable strings.
extension NullableStringExtensions on String? {
  /// Returns `true` when the value is `null`, empty, or whitespace-only.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Returns `true` when the value is non-null and non-blank.
  bool get isNotNullOrBlank => !isNullOrBlank;
}
