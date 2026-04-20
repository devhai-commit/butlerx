import 'package:butlerx/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants', () {
    test('animation durations are positive', () {
      expect(AppConstants.animFast.inMilliseconds, greaterThan(0));
      expect(AppConstants.animNormal.inMilliseconds, greaterThan(AppConstants.animFast.inMilliseconds));
      expect(AppConstants.animSlow.inMilliseconds, greaterThan(AppConstants.animNormal.inMilliseconds));
    });

    test('spacing scale is ascending', () {
      expect(AppConstants.spacingXs, lessThan(AppConstants.spacingSm));
      expect(AppConstants.spacingSm, lessThan(AppConstants.spacingMd));
      expect(AppConstants.spacingMd, lessThan(AppConstants.spacingLg));
      expect(AppConstants.spacingLg, lessThan(AppConstants.spacingXl));
    });

    test('mealPlanDays is 7', () {
      expect(AppConstants.mealPlanDays, 7);
    });

    test('accessibility min touch target meets WCAG guideline (48dp)', () {
      expect(AppConstants.accessibilityMinTouchTarget, greaterThanOrEqualTo(48.0));
    });
  });

  group('StorageKeys', () {
    test('keys are non-empty strings', () {
      expect(StorageKeys.openAiApiKey, isNotEmpty);
      expect(StorageKeys.themeMode, isNotEmpty);
      expect(StorageKeys.onboardingComplete, isNotEmpty);
      expect(StorageKeys.userId, isNotEmpty);
    });

    test('keys are unique', () {
      final keys = [
        StorageKeys.openAiApiKey,
        StorageKeys.themeMode,
        StorageKeys.onboardingComplete,
        StorageKeys.userId,
      ];
      expect(keys.toSet().length, keys.length);
    });
  });

  group('FirestoreCollections', () {
    test('collection names are non-empty and unique', () {
      final cols = [
        FirestoreCollections.users,
        FirestoreCollections.appointments,
        FirestoreCollections.healthMetrics,
        FirestoreCollections.mealPlans,
        FirestoreCollections.conversations,
        FirestoreCollections.specialOccasions,
      ];
      for (final c in cols) {
        expect(c, isNotEmpty);
      }
      expect(cols.toSet().length, cols.length);
    });
  });
}
