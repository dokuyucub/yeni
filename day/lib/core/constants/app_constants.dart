/// AppConstants - Application-wide configuration constants for Day app
/// Contains app info, feature limits, database configuration, and storage keys
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ============================================================================
  // APP INFO
  // ============================================================================

  /// Application name
  static const String appName = 'Day';

  /// Application tagline
  static const String appTagline = 'Your life, in color';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Build number
  static const String buildNumber = '1';

  /// iOS bundle identifier
  static const String bundleIdIos = 'com.day.app';

  /// Android bundle identifier
  static const String bundleIdAndroid = 'com.day.app';

  // ============================================================================
  // FEATURE LIMITS
  // ============================================================================

  /// Maximum number of mood colors in the palette
  static const int maxMoodColors = 24;

  /// Maximum length for note text
  static const int maxNoteLength = 500;

  /// Maximum duration for voice notes in seconds
  static const int maxVoiceNoteDurationSeconds = 60;

  /// Number of visualization modes available in free tier
  static const int freeVisualizationModes = 3;

  /// Total number of visualization modes
  static const int totalVisualizationModes = 8;

  /// Number of days of history available in free tier
  static const int freeHistoryDays = 90;

  /// Unlimited history (represented as -1)
  static const int unlimitedHistoryDays = -1;

  // ============================================================================
  // DATABASE
  // ============================================================================

  /// Database file name
  static const String databaseName = 'day_database.db';

  /// Database schema version
  static const int databaseVersion = 1;

  /// Table name for daily mood entries
  static const String tableEntries = 'daily_entries';

  /// Table name for generated artworks
  static const String tableArtworks = 'artworks';

  /// Table name for journal entries
  static const String tableJournals = 'journal_entries';

  /// Table name for user collections
  static const String tableCollections = 'collections';

  /// Table name for user badges
  static const String tableBadges = 'user_badges';

  // ============================================================================
  // STORAGE KEYS
  // ============================================================================

  /// Key for onboarding completion status
  static const String keyOnboardingComplete = 'onboarding_complete';

  /// Key for user ID
  static const String keyUserId = 'user_id';

  /// Key for theme mode preference
  static const String keyThemeMode = 'theme_mode';

  /// Key for notifications enabled status
  static const String keyNotificationsEnabled = 'notifications_enabled';

  /// Key for notification time
  static const String keyNotificationTime = 'notification_time';

  /// Key for last entry date
  static const String keyLastEntryDate = 'last_entry_date';

  /// Key for current streak count
  static const String keyCurrentStreak = 'current_streak';

  /// Key for longest streak record
  static const String keyLongestStreak = 'longest_streak';

  /// Key for premium subscription status
  static const String keyIsPremium = 'is_premium';
}
