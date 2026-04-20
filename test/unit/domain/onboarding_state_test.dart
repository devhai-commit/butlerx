import 'package:butlerx/features/auth/domain/entities/user_profile.dart';
import 'package:butlerx/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingState.canAdvance', () {
    test('step 0: false when name is empty', () {
      const s = OnboardingState(step: 0, displayName: '');
      expect(s.canAdvance, isFalse);
    });

    test('step 0: false when name is only whitespace', () {
      const s = OnboardingState(step: 0, displayName: '   ');
      expect(s.canAdvance, isFalse);
    });

    test('step 0: true when name is filled', () {
      const s = OnboardingState(step: 0, displayName: 'An');
      expect(s.canAdvance, isTrue);
    });

    test('step 1: false when birthdate is null', () {
      const s = OnboardingState(step: 1, displayName: 'An', birthdate: null);
      expect(s.canAdvance, isFalse);
    });

    test('step 1: true when birthdate is set', () {
      final s = OnboardingState(step: 1, displayName: 'An', birthdate: DateTime(1990));
      expect(s.canAdvance, isTrue);
    });

    test('step 2: false when gender is null', () {
      const s = OnboardingState(step: 2, displayName: 'An');
      expect(s.canAdvance, isFalse);
    });

    test('step 2: true when gender is set', () {
      const s = OnboardingState(step: 2, displayName: 'An', gender: Gender.male);
      expect(s.canAdvance, isTrue);
    });

    test('step 3: false when addressTitle is null', () {
      const s = OnboardingState(step: 3, displayName: 'An', gender: Gender.male);
      expect(s.canAdvance, isFalse);
    });

    test('step 3: true when addressTitle is set', () {
      const s = OnboardingState(step: 3, displayName: 'An', gender: Gender.male, addressTitle: AddressTitle.anh);
      expect(s.canAdvance, isTrue);
    });

    test('step 4: false when personalityTag is null', () {
      const s = OnboardingState(step: 4, displayName: 'An', addressTitle: AddressTitle.anh);
      expect(s.canAdvance, isFalse);
    });

    test('step 4: true when personalityTag is set', () {
      const s = OnboardingState(step: 4, displayName: 'An', addressTitle: AddressTitle.anh, personalityTag: PersonalityTag.warm);
      expect(s.canAdvance, isTrue);
    });
  });

  group('OnboardingState.copyWith', () {
    test('updates step without affecting other fields', () {
      const original = OnboardingState(step: 0, displayName: 'An');
      final updated = original.copyWith(step: 1);
      expect(updated.step, 1);
      expect(updated.displayName, 'An');
    });

    test('totalSteps is 5', () {
      expect(OnboardingState.totalSteps, 5);
    });
  });
}
