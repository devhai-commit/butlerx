abstract final class AppConstants {
  static const String appName = 'ButlerX';
  static const String appVersion = '1.0.0';

  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  static const int chatHistoryLimit = 50;
  static const int mealPlanDays = 7;

  static const String openAiModel = 'gpt-4o';
  static const String openAiModelMini = 'gpt-4o-mini';

  static const int reminderDefaultOffsetMinutes = 15;

  static const double accessibilityMinTouchTarget = 48.0;
}

abstract final class StorageKeys {
  static const String openAiApiKey = 'openai_api_key';
  static const String themeMode = 'theme_mode';
  static const String onboardingComplete = 'onboarding_complete';
  static const String userId = 'user_id';
}

abstract final class FirestoreCollections {
  static const String users = 'users';
  static const String appointments = 'appointments';
  static const String healthMetrics = 'health_metrics';
  static const String mealPlans = 'meal_plans';
  static const String conversations = 'conversations';
  static const String specialOccasions = 'special_occasions';
}
