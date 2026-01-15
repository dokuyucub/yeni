import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/badge.dart';
import '../models/user_badge.dart';

/// BadgeRepository - Data access layer for Badge and UserBadge operations
/// Provides badge management, unlocking, and progress tracking
class BadgeRepository {
  // Database service instance
  final DatabaseService _db = DatabaseService.instance;

  // ============================================================================
  // USER BADGE OPERATIONS
  // ============================================================================

  /// Get all user badges
  Future<List<UserBadge>> getUserBadges() async {
    final db = await _db.database;
    final maps = await db.query(
      'user_badges',
      orderBy: 'unlocked_at DESC',
    );

    return maps.map((map) => UserBadge.fromMap(map)).toList();
  }

  /// Get a user badge by badge ID
  Future<UserBadge?> getUserBadge(String badgeId) async {
    final db = await _db.database;
    final maps = await db.query(
      'user_badges',
      where: 'badge_id = ?',
      whereArgs: [badgeId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserBadge.fromMap(maps.first);
  }

  /// Get all unlocked badge IDs
  Future<List<String>> getUnlockedBadgeIds() async {
    final db = await _db.database;
    final maps = await db.query(
      'user_badges',
      columns: ['badge_id'],
      where: 'is_unlocked = ?',
      whereArgs: [1],
    );

    return maps.map((map) => map['badge_id'] as String).toList();
  }

  /// Unlock a badge
  /// Creates a new UserBadge or updates existing one to unlocked
  Future<void> unlockBadge(String badgeId) async {
    final db = await _db.database;

    // Check if badge already exists
    final existingBadge = await getUserBadge(badgeId);

    if (existingBadge != null) {
      // Update existing badge to unlocked
      final updatedBadge = existingBadge.unlock();
      await db.update(
        'user_badges',
        updatedBadge.toMap(),
        where: 'id = ?',
        whereArgs: [updatedBadge.id],
      );
    } else {
      // Create new unlocked badge
      final newBadge = UserBadge.unlocked(badgeId: badgeId);
      await db.insert(
        'user_badges',
        newBadge.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Check if a badge is unlocked
  Future<bool> isBadgeUnlocked(String badgeId) async {
    final userBadge = await getUserBadge(badgeId);
    return userBadge?.isUnlocked ?? false;
  }

  /// Update badge progress
  /// Creates a new UserBadge if it doesn't exist
  Future<void> updateProgress(String badgeId, int currentProgress) async {
    final db = await _db.database;

    // Get the badge definition to check target
    final badge = Badge.allBadges.firstWhere(
      (b) => b.id == badgeId,
      orElse: () => Badge.allBadges.first, // Fallback to first badge
    );

    // Check if badge already exists
    final existingBadge = await getUserBadge(badgeId);

    if (existingBadge != null) {
      // Update progress
      final updatedBadge = existingBadge.updateProgress(
        currentProgress,
        badge.targetValue,
      );
      await db.update(
        'user_badges',
        updatedBadge.toMap(),
        where: 'id = ?',
        whereArgs: [updatedBadge.id],
      );
    } else {
      // Create new badge with progress
      final newBadge = UserBadge.withProgress(
        badgeId: badgeId,
        currentProgress: currentProgress,
        targetValue: badge.targetValue,
      );
      await db.insert(
        'user_badges',
        newBadge.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get progress for a specific badge
  Future<int> getProgress(String badgeId) async {
    final userBadge = await getUserBadge(badgeId);
    return userBadge?.currentProgress ?? 0;
  }

  // ============================================================================
  // BADGE QUERIES
  // ============================================================================

  /// Get count of unlocked badges
  Future<int> getUnlockedCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM user_badges WHERE is_unlocked = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get all unlocked badges with full badge information
  Future<List<Map<String, dynamic>>> getUnlockedBadges() async {
    final unlockedIds = await getUnlockedBadgeIds();

    // Match with badge definitions
    return Badge.allBadges
        .where((badge) => unlockedIds.contains(badge.id))
        .map((badge) => {
              'badge': badge,
              'userBadge': getUserBadge(badge.id),
            })
        .toList();
  }

  /// Get all locked badges with full badge information
  Future<List<Map<String, dynamic>>> getLockedBadges() async {
    final unlockedIds = await getUnlockedBadgeIds();

    // Get all badges that are not unlocked
    final lockedBadges = Badge.allBadges
        .where((badge) => !unlockedIds.contains(badge.id))
        .toList();

    // Get progress for each locked badge
    final result = <Map<String, dynamic>>[];
    for (final badge in lockedBadges) {
      final userBadge = await getUserBadge(badge.id);
      result.add({
        'badge': badge,
        'userBadge': userBadge,
        'progress': userBadge?.currentProgress ?? 0,
        'target': badge.targetValue,
      });
    }

    return result;
  }

  /// Get badges by category
  Future<List<Map<String, dynamic>>> getBadgesByCategory(
    BadgeCategory category,
  ) async {
    final unlockedIds = await getUnlockedBadgeIds();

    // Filter badges by category
    final categoryBadges = Badge.allBadges
        .where((badge) => badge.category == category)
        .toList();

    // Get progress for each badge
    final result = <Map<String, dynamic>>[];
    for (final badge in categoryBadges) {
      final userBadge = await getUserBadge(badge.id);
      result.add({
        'badge': badge,
        'userBadge': userBadge,
        'isUnlocked': unlockedIds.contains(badge.id),
        'progress': userBadge?.currentProgress ?? 0,
      });
    }

    return result;
  }

  /// Get badges by rarity
  Future<List<Map<String, dynamic>>> getBadgesByRarity(
    BadgeRarity rarity,
  ) async {
    final unlockedIds = await getUnlockedBadgeIds();

    // Filter badges by rarity
    final rarityBadges = Badge.allBadges
        .where((badge) => badge.rarity == rarity)
        .toList();

    // Get progress for each badge
    final result = <Map<String, dynamic>>[];
    for (final badge in rarityBadges) {
      final userBadge = await getUserBadge(badge.id);
      result.add({
        'badge': badge,
        'userBadge': userBadge,
        'isUnlocked': unlockedIds.contains(badge.id),
        'progress': userBadge?.currentProgress ?? 0,
      });
    }

    return result;
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get total badge count
  Future<int> getTotalBadgeCount() async {
    return Badge.allBadges.length;
  }

  /// Get completion percentage (unlocked / total)
  Future<double> getCompletionPercentage() async {
    final unlockedCount = await getUnlockedCount();
    final totalCount = Badge.allBadges.length;

    if (totalCount == 0) return 0.0;
    return (unlockedCount / totalCount) * 100;
  }

  /// Check and unlock badges based on progress
  /// This should be called after updating user stats
  Future<List<String>> checkAndUnlockBadges({
    required int totalEntries,
    required int currentStreak,
    required int longestStreak,
    required int totalArtworks,
  }) async {
    final newlyUnlocked = <String>[];

    // Check each badge's unlock condition
    for (final badge in Badge.allBadges) {
      // Skip if already unlocked
      if (await isBadgeUnlocked(badge.id)) continue;

      bool shouldUnlock = false;

      // Check unlock condition based on category
      switch (badge.category) {
        case BadgeCategory.entries:
          shouldUnlock = totalEntries >= badge.targetValue;
          if (!shouldUnlock) {
            await updateProgress(badge.id, totalEntries);
          }
          break;
        case BadgeCategory.streak:
          shouldUnlock = currentStreak >= badge.targetValue ||
              longestStreak >= badge.targetValue;
          if (!shouldUnlock) {
            final progress = currentStreak > longestStreak
                ? currentStreak
                : longestStreak;
            await updateProgress(badge.id, progress);
          }
          break;
        case BadgeCategory.artwork:
          shouldUnlock = totalArtworks >= badge.targetValue;
          if (!shouldUnlock) {
            await updateProgress(badge.id, totalArtworks);
          }
          break;
        case BadgeCategory.special:
          // Special badges are unlocked manually
          break;
      }

      if (shouldUnlock) {
        await unlockBadge(badge.id);
        newlyUnlocked.add(badge.id);
      }
    }

    return newlyUnlocked;
  }
}
