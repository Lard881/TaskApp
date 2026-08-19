import 'package:planpal/core/constants/app_strings.dart';

/// Validation functions for the Change Password form (Req 20.7–20.8).
abstract final class PasswordValidator {
  /// Validates the new password field.
  /// - Error if fewer than 8 or more than 64 characters.
  static String? validateNewPassword(String? value) {
    final v = value ?? '';
    if (v.length < 8 || v.length > 64) {
      return AppStrings.passwordLength;
    }
    return null;
  }

  /// Validates that confirm password matches the new password.
  static String? validateConfirmPassword(String? newPassword, String? confirm) {
    if (newPassword != confirm) return AppStrings.passwordMismatch;
    return null;
  }

  /// Validates all three password fields together.
  /// [storedPassword] is the currently saved password for the current-password check.
  ///
  /// Returns a map of field name → error for any failing field.
  /// Keys: 'currentPassword', 'newPassword', 'confirmPassword'
  static Map<String, String> validateAll({
    required String currentPassword,
    required String storedPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};

    if (currentPassword != storedPassword) {
      errors['currentPassword'] = AppStrings.passwordIncorrect;
    }

    final newPwdError = validateNewPassword(newPassword);
    if (newPwdError != null) errors['newPassword'] = newPwdError;

    final confirmError = validateConfirmPassword(newPassword, confirmPassword);
    if (confirmError != null) errors['confirmPassword'] = confirmError;

    return errors;
  }
}
