import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/core/validators/profile_validator.dart';

void main() {
  group('ProfileValidator.validateFirstName', () {
    test('null → error', () {
      expect(ProfileValidator.validateFirstName(null), isNotNull);
    });
    test('empty → error', () {
      expect(ProfileValidator.validateFirstName(''), isNotNull);
    });
    test('whitespace only → error', () {
      expect(ProfileValidator.validateFirstName('  '), isNotNull);
    });
    test('1 character → valid', () {
      expect(ProfileValidator.validateFirstName('A'), isNull);
    });
    test('50 characters → valid', () {
      expect(ProfileValidator.validateFirstName('A' * 50), isNull);
    });
    test('51 characters → error', () {
      expect(ProfileValidator.validateFirstName('A' * 51), isNotNull);
    });
  });

  group('ProfileValidator.validateLastName', () {
    test('empty → error', () {
      expect(ProfileValidator.validateLastName(''), isNotNull);
    });
    test('50 characters → valid', () {
      expect(ProfileValidator.validateLastName('B' * 50), isNull);
    });
    test('51 characters → error', () {
      expect(ProfileValidator.validateLastName('B' * 51), isNotNull);
    });
  });

  group('ProfileValidator.validateEmail', () {
    test('null → error', () {
      expect(ProfileValidator.validateEmail(null), isNotNull);
    });
    test('empty → error', () {
      expect(ProfileValidator.validateEmail(''), isNotNull);
    });
    test('missing @ → error', () {
      expect(ProfileValidator.validateEmail('notanemail'), isNotNull);
    });
    test('missing domain → error', () {
      expect(ProfileValidator.validateEmail('user@'), isNotNull);
    });
    test('missing TLD → error', () {
      expect(ProfileValidator.validateEmail('user@domain'), isNotNull);
    });
    test('valid email → null', () {
      expect(ProfileValidator.validateEmail('user@example.com'), isNull);
    });
    test('valid email with subdomain → null', () {
      expect(ProfileValidator.validateEmail('user@mail.example.co.uk'), isNull);
    });
    test('254 characters → valid', () {
      // longest valid: local(64) + @ + domain(189) = 254
      final local = 'a' * 64;
      final domain = '${'b' * 185}.com';
      expect(ProfileValidator.validateEmail('$local@$domain'), isNull);
    });
    test('255 characters → error', () {
      final long = 'a' * 255;
      expect(ProfileValidator.validateEmail(long), isNotNull);
    });
    test('email with plus tag → valid', () {
      expect(ProfileValidator.validateEmail('user+tag@example.com'), isNull);
    });
    test('email with numbers → valid', () {
      expect(ProfileValidator.validateEmail('user123@domain456.org'), isNull);
    });
  });

  group('ProfileValidator.validateRole', () {
    test('null (optional) → valid', () {
      expect(ProfileValidator.validateRole(null), isNull);
    });
    test('empty (optional) → valid', () {
      expect(ProfileValidator.validateRole(''), isNull);
    });
    test('100 characters → valid', () {
      expect(ProfileValidator.validateRole('A' * 100), isNull);
    });
    test('101 characters → error', () {
      expect(ProfileValidator.validateRole('A' * 101), isNotNull);
    });
  });

  group('ProfileValidator.validatePhone', () {
    test('null (optional) → valid', () {
      expect(ProfileValidator.validatePhone(null), isNull);
    });
    test('20 characters → valid', () {
      expect(ProfileValidator.validatePhone('1' * 20), isNull);
    });
    test('21 characters → error', () {
      expect(ProfileValidator.validatePhone('1' * 21), isNotNull);
    });
  });

  group('ProfileValidator.validateAll', () {
    test('all valid → empty map', () {
      final errors = ProfileValidator.validateAll(
        firstName: 'Alex',
        lastName: 'Morgan',
        email: 'alex@example.com',
      );
      expect(errors, isEmpty);
    });

    test('all required fields missing → firstName, lastName, email keys', () {
      final errors = ProfileValidator.validateAll(
        firstName: '',
        lastName: '',
        email: '',
      );
      expect(errors.containsKey('firstName'), isTrue);
      expect(errors.containsKey('lastName'), isTrue);
      expect(errors.containsKey('email'), isTrue);
    });

    test('invalid email with valid names → only email error', () {
      final errors = ProfileValidator.validateAll(
        firstName: 'Alex',
        lastName: 'Morgan',
        email: 'not-an-email',
      );
      expect(errors.containsKey('email'), isTrue);
      expect(errors.containsKey('firstName'), isFalse);
      expect(errors.containsKey('lastName'), isFalse);
    });

    test('optional fields null → no errors added', () {
      final errors = ProfileValidator.validateAll(
        firstName: 'Alex',
        lastName: 'Morgan',
        email: 'alex@example.com',
        role: null,
        phone: null,
      );
      expect(errors, isEmpty);
    });
  });
}
