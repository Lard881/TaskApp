import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/core/validators/password_validator.dart';

void main() {
  group('PasswordValidator.validateNewPassword', () {
    test('7 characters → error (too short)', () {
      expect(PasswordValidator.validateNewPassword('1234567'), isNotNull);
    });
    test('8 characters → valid (lower boundary)', () {
      expect(PasswordValidator.validateNewPassword('12345678'), isNull);
    });
    test('64 characters → valid (upper boundary)', () {
      expect(PasswordValidator.validateNewPassword('A' * 64), isNull);
    });
    test('65 characters → error (too long)', () {
      expect(PasswordValidator.validateNewPassword('A' * 65), isNotNull);
    });
    test('empty string → error', () {
      expect(PasswordValidator.validateNewPassword(''), isNotNull);
    });
    test('null → error', () {
      expect(PasswordValidator.validateNewPassword(null), isNotNull);
    });
  });

  group('PasswordValidator.validateConfirmPassword', () {
    test('matching passwords → valid', () {
      expect(
        PasswordValidator.validateConfirmPassword('MyPass123', 'MyPass123'),
        isNull,
      );
    });
    test('mismatched passwords → error', () {
      expect(
        PasswordValidator.validateConfirmPassword('MyPass123', 'Different1'),
        isNotNull,
      );
    });
    test('both empty → valid (both same)', () {
      expect(
        PasswordValidator.validateConfirmPassword('', ''),
        isNull,
      );
    });
    test('new empty, confirm non-empty → error', () {
      expect(
        PasswordValidator.validateConfirmPassword('', 'something'),
        isNotNull,
      );
    });
  });

  group('PasswordValidator.validateAll', () {
    const stored = 'StoredPass1';

    test('all valid → empty map', () {
      final errors = PasswordValidator.validateAll(
        currentPassword: stored,
        storedPassword: stored,
        newPassword: 'NewSecure99',
        confirmPassword: 'NewSecure99',
      );
      expect(errors, isEmpty);
    });

    test('incorrect current password → currentPassword error', () {
      final errors = PasswordValidator.validateAll(
        currentPassword: 'WrongPass',
        storedPassword: stored,
        newPassword: 'NewSecure99',
        confirmPassword: 'NewSecure99',
      );
      expect(errors.containsKey('currentPassword'), isTrue);
    });

    test('new password too short → newPassword error', () {
      final errors = PasswordValidator.validateAll(
        currentPassword: stored,
        storedPassword: stored,
        newPassword: 'short',
        confirmPassword: 'short',
      );
      expect(errors.containsKey('newPassword'), isTrue);
    });

    test('passwords do not match → confirmPassword error', () {
      final errors = PasswordValidator.validateAll(
        currentPassword: stored,
        storedPassword: stored,
        newPassword: 'ValidPass99',
        confirmPassword: 'DifferentPass',
      );
      expect(errors.containsKey('confirmPassword'), isTrue);
    });

    test('length and mismatch errors are reported independently', () {
      final errors = PasswordValidator.validateAll(
        currentPassword: stored,
        storedPassword: stored,
        newPassword: 'short',       // too short
        confirmPassword: 'shorter', // also too short and mismatched
      );
      expect(errors.containsKey('newPassword'), isTrue);
      expect(errors.containsKey('confirmPassword'), isTrue);
    });

    test('all three fields invalid → three error keys', () {
      final errors = PasswordValidator.validateAll(
        currentPassword: 'wrong',
        storedPassword: stored,
        newPassword: 'bad',
        confirmPassword: 'different',
      );
      expect(errors.containsKey('currentPassword'), isTrue);
      expect(errors.containsKey('newPassword'), isTrue);
      expect(errors.containsKey('confirmPassword'), isTrue);
    });
  });
}
