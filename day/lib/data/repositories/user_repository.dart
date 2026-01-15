import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';

/// UserRepository - Data access layer for UserProfile operations
/// Provides CRUD operations and user profile management
class UserRepository {
  // Database service instance
  final DatabaseService _db = DatabaseService.instance;

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Get the user profile
  /// Returns null if no profile exists
  Future<UserProfile?> getProfile() async {
    final db = await _db.database;
    final maps = await db.query(
      'user_profile',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  /// Create a new user profile
  /// Only one profile can exist in the database
  Future<void> createProfile(UserProfile profile) async {
    final db = await _db.database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update the user profile
  Future<void> updateProfile(UserProfile profile) async {
    final db = await _db.database;
    await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  /// Delete the user profile
  Future<void> deleteProfile(String id) async {
    final db = await _db.database;
    await db.delete(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get or create the user profile
  /// If no profile exists, creates one with default values
  Future<UserProfile> getOrCreateProfile() async {
    final profile = await getProfile();

    if (profile != null) {
      return profile;
    }

    // Create default profile
    final newProfile = UserProfile.createDefault();
    await createProfile(newProfile);
    return newProfile;
  }

  // ============================================================================
  // STREAK OPERATIONS
  // ============================================================================

  /// Update streak information
  Future<void> updateStreak(int currentStreak, int longestStreak) async {
    final profile = await getOrCreateProfile();

    final updatedProfile = profile.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  // ============================================================================
  // COUNTER OPERATIONS
  // ============================================================================

  /// Increment the total entries count
  Future<void> incrementEntryCount() async {
    final profile = await getOrCreateProfile();

    final updatedProfile = profile.copyWith(
      totalEntries: profile.totalEntries + 1,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  /// Increment the total artworks count
  Future<void> incrementArtworkCount() async {
    final profile = await getOrCreateProfile();

    final updatedProfile = profile.copyWith(
      totalArtworks: profile.totalArtworks + 1,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  // ============================================================================
  // PREMIUM & ONBOARDING
  // ============================================================================

  /// Set premium status
  Future<void> setPremium(bool isPremium) async {
    final profile = await getOrCreateProfile();

    final updatedProfile = profile.copyWith(
      isPremium: isPremium,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  /// Set onboarding completion status
  Future<void> setOnboardingComplete(bool isComplete) async {
    final profile = await getOrCreateProfile();

    final updatedProfile = profile.copyWith(
      hasCompletedOnboarding: isComplete,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  // ============================================================================
  // SETTINGS OPERATIONS
  // ============================================================================

  /// Update notification settings
  Future<void> updateNotificationSettings({
    required bool dailyReminder,
    required bool weeklyReview,
    required bool achievements,
  }) async {
    final profile = await getOrCreateProfile();

    final updatedProfile = profile.copyWith(
      notifyDailyReminder: dailyReminder,
      notifyWeeklyReview: weeklyReview,
      notifyAchievements: achievements,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  /// Update theme mode
  Future<void> updateThemeMode(String themeMode) async {
    final profile = await getOrCreateProfile();

    final updatedProfile = profile.copyWith(
      themeMode: themeMode,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if user is premium
  Future<bool> isPremiumUser() async {
    final profile = await getProfile();
    return profile?.isPremium ?? false;
  }

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final profile = await getProfile();
    return profile?.hasCompletedOnboarding ?? false;
  }

  /// Get current streak
  Future<int> getCurrentStreak() async {
    final profile = await getProfile();
    return profile?.currentStreak ?? 0;
  }

  /// Get longest streak
  Future<int> getLongestStreak() async {
    final profile = await getProfile();
    return profile?.longestStreak ?? 0;
  }

  /// Get total entries count
  Future<int> getTotalEntries() async {
    final profile = await getProfile();
    return profile?.totalEntries ?? 0;
  }

  /// Get total artworks count
  Future<int> getTotalArtworks() async {
    final profile = await getProfile();
    return profile?.totalArtworks ?? 0;
  }
}
