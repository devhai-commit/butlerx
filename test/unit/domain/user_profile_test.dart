import 'package:butlerx/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

UserProfile _makeProfile({
  int yearsOld = 30,
  Gender gender = Gender.male,
  AddressTitle addressTitle = AddressTitle.anh,
  PersonalityTag personalityTag = PersonalityTag.warm,
  bool onboardingComplete = false,
}) =>
    UserProfile(
      uid: 'uid-1',
      email: 'test@example.com',
      displayName: 'Nguyễn Văn An',
      birthdate: DateTime.now().subtract(Duration(days: yearsOld * 365)),
      gender: gender,
      addressTitle: addressTitle,
      personalityTag: personalityTag,
      onboardingComplete: onboardingComplete,
    );

void main() {
  group('UserProfile.ageBand', () {
    test('child for age < 13', () {
      expect(_makeProfile(yearsOld: 8).ageBand, AgeBand.child);
    });

    test('teen for age 13–17', () {
      expect(_makeProfile(yearsOld: 15).ageBand, AgeBand.teen);
    });

    test('adult for age 18–39', () {
      expect(_makeProfile(yearsOld: 25).ageBand, AgeBand.adult);
    });

    test('middleAged for age 40–59', () {
      expect(_makeProfile(yearsOld: 50).ageBand, AgeBand.middleAged);
    });

    test('elderly for age 60+', () {
      expect(_makeProfile(yearsOld: 70).ageBand, AgeBand.elderly);
    });
  });

  group('UserProfile.firstNameGreeting', () {
    test('returns last token of displayName', () {
      final p = _makeProfile();
      expect(p.firstNameGreeting, 'An');
    });

    test('single name returns itself', () {
      final p = UserProfile(
        uid: 'uid-2',
        email: 'x@x.com',
        displayName: 'Hoa',
        birthdate: DateTime(1990),
        gender: Gender.female,
        addressTitle: AddressTitle.chi,
        personalityTag: PersonalityTag.warm,
      );
      expect(p.firstNameGreeting, 'Hoa');
    });
  });

  group('UserProfile.copyWith', () {
    test('copies only changed fields', () {
      final original = _makeProfile();
      final updated = original.copyWith(displayName: 'Nguyễn Thị Hoa', onboardingComplete: true);
      expect(updated.uid, original.uid);
      expect(updated.email, original.email);
      expect(updated.displayName, 'Nguyễn Thị Hoa');
      expect(updated.onboardingComplete, true);
    });
  });

  group('UserProfile serialization', () {
    test('toJson/fromJson round-trips correctly', () {
      final original = _makeProfile(onboardingComplete: true);
      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.uid, original.uid);
      expect(restored.email, original.email);
      expect(restored.displayName, original.displayName);
      expect(restored.gender, original.gender);
      expect(restored.addressTitle, original.addressTitle);
      expect(restored.personalityTag, original.personalityTag);
      expect(restored.onboardingComplete, original.onboardingComplete);
    });
  });

  group('UserProfile equality', () {
    test('same uid = equal', () {
      final a = _makeProfile();
      final b = a.copyWith(displayName: 'Other');
      expect(a, equals(b));
    });

    test('different uid = not equal', () {
      final a = _makeProfile();
      final b = UserProfile(
        uid: 'uid-999',
        email: a.email,
        displayName: a.displayName,
        birthdate: a.birthdate,
        gender: a.gender,
        addressTitle: a.addressTitle,
        personalityTag: a.personalityTag,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('AddressTitle', () {
    test('all titles have non-empty Vietnamese labels', () {
      for (final t in AddressTitle.values) {
        expect(t.label, isNotEmpty);
      }
    });
  });

  group('PersonalityTag', () {
    test('all tags have non-empty Vietnamese labels', () {
      for (final p in PersonalityTag.values) {
        expect(p.label, isNotEmpty);
      }
    });
  });
}
