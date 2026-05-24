/// AppConstants holds all application-wide constant values.
/// Centralising them here avoids magic strings scattered across the codebase.
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'TaskPlano';
  static const String appVersion = '1.0.0';

  // ── Hive Box Names ────────────────────────────────────────────────────────
  static const String taskBoxName = 'tasks';
  static const String authBoxName = 'auth';
  static const String onboardingBoxName = 'onboarding';

  // ── Hive Type IDs ─────────────────────────────────────────────────────────
  // 0–9  : Task feature
  // 10–19: Auth feature
  static const int taskModelTypeId = 0;
  static const int userModelTypeId = 10;

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const String onboardingCompletedKey = 'onboarding_completed';

  // ── Animation durations ───────────────────────────────────────────────────
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 180);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // ── Spacing system ────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ── Border radius ─────────────────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 32.0;
}
