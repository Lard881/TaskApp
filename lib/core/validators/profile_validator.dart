import 'package:planpal/core/constants/app_strings.dart';

/// Validation functions for the Edit Profile form fields (Req 18.5–18.8).
abstract final class ProfileValidator {
  // Simple email pattern: requires [text]@[domain].[tld]
  static final RegExp _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  /// First name — required, max 50 characters.
  static String? validateFirstName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AppStrings.firstNameRequired;
    if (trimmed.length > 50) return 'First name must be 50 characters or fewer.';
    return null;
  }

  /// Last name — required, max 50 characters.
  static String? validateLastName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AppStrings.lastNameRequired;
    if (trimmed.length > 50) return 'Last name must be 50 characters or fewer.';
    return null;
  }

  /// Email — required, max 254 characters, must match [text]@[domain].[tld].
  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AppStrings.emailRequired;
    if (trimmed.length > 254) return 'Email must be 254 characters or fewer.';
    if (!_emailPattern.hasMatch(trimmed)) return AppStrings.emailInvalid;
    return null;
  }

  /// Role/Title — optional, max 100 characters.
  static String? validateRole(String? value) {
    if (value != null && value.trim().length > 100) {
      return 'Role must be 100 characters or fewer.';
    }
    return null;
  }

  /// Phone — optional, max 20 characters.
  static String? validatePhone(String? value) {
    if (value != null && value.trim().length > 20) {
      return 'Phone number must be 20 characters or fewer.';
    }
    return null;
  }

  /// Validates all profile form fields at once.
  /// Returns a map of field name → error for any failing field.
  static Map<String, String> validateAll({
    required String? firstName,
    required String? lastName,
    required String? email,
    String? role,
    String? phone,
  }) {
    final errors = <String, String>{};
    final fn = validateFirstName(firstName);
    final ln = validateLastName(lastName);
    final em = validateEmail(email);
    final ro = validateRole(role);
    final ph = validatePhone(phone);

    if (fn != null) errors['firstName'] = fn;
    if (ln != null) errors['lastName'] = ln;
    if (em != null) errors['email'] = em;
    if (ro != null) errors['role'] = ro;
    if (ph != null) errors['phone'] = ph;

    return errors;
  }
}
