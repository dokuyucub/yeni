import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/daily_entry.dart';

/// EntryRepository - Data access layer for DailyEntry operations
/// Provides CRUD operations and queries for mood entries
class EntryRepository {
  // Database service instance
  final DatabaseService _db = DatabaseService.instance;

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Insert a new entry into the database
  Future<void> insert(DailyEntry entry) async {
    final db = await _db.database;
    await db.insert(
      'daily_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing entry in the database
  Future<void> update(DailyEntry entry) async {
    final db = await _db.database;
    await db.update(
      'daily_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Delete an entry from the database
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(
      'daily_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get an entry by ID
  Future<DailyEntry?> getById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'daily_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DailyEntry.fromMap(maps.first);
  }

  // ============================================================================
  // QUERY METHODS
  // ============================================================================

  /// Get an entry for a specific date
  Future<DailyEntry?> getByDate(DateTime date) async {
    final db = await _db.database;

    // Format date as yyyy-MM-dd
    final dateString = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'daily_entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DailyEntry.fromMap(maps.first);
  }

  /// Get all entries ordered by date descending
  Future<List<DailyEntry>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      'daily_entries',
      orderBy: 'date DESC',
    );

    return maps.map((map) => DailyEntry.fromMap(map)).toList();
  }

  /// Get entries within a date range
  Future<List<DailyEntry>> getInDateRange(DateTime start, DateTime end) async {
    final db = await _db.database;

    final startString = start.toIso8601String();
    final endString = end.toIso8601String();

    final maps = await db.query(
      'daily_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startString, endString],
      orderBy: 'date ASC',
    );

    return maps.map((map) => DailyEntry.fromMap(map)).toList();
  }

  /// Get entries for the last N days
  Future<List<DailyEntry>> getLastNDays(int days) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    return getInDateRange(start, now);
  }

  /// Get entries for a specific week starting from weekStart
  Future<List<DailyEntry>> getWeekEntries(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return getInDateRange(weekStart, weekEnd);
  }

  /// Get entries for a specific month
  Future<List<DailyEntry>> getMonthEntries(int year, int month) async {
    // First day of month
    final firstDay = DateTime(year, month, 1);

    // Last day of month
    final lastDay = DateTime(year, month + 1, 0);

    return getInDateRange(firstDay, lastDay);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get total count of entries
  Future<int> getEntriesCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM daily_entries');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if an entry exists for a specific date
  Future<bool> hasEntryForDate(DateTime date) async {
    final entry = await getByDate(date);
    return entry != null;
  }

  /// Get streak information (current and longest streaks)
  Future<Map<String, int>> getStreakInfo() async {
    final db = await _db.database;

    // Get all dates ordered by date descending
    final maps = await db.query(
      'daily_entries',
      columns: ['date'],
      orderBy: 'date DESC',
    );

    if (maps.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Parse dates and extract date-only (ignore time)
    final dates = maps.map((map) {
      final dateTime = DateTime.parse(map['date'] as String);
      return DateTime(dateTime.year, dateTime.month, dateTime.day);
    }).toList();

    // Remove duplicates and sort
    final uniqueDates = dates.toSet().toList()..sort((a, b) => b.compareTo(a));

    // Calculate current streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int currentStreak = 0;
    DateTime checkDate = today;

    // Start from today or yesterday
    if (uniqueDates.first.isAtSameMomentAs(today)) {
      checkDate = today;
    } else if (uniqueDates.first.isAtSameMomentAs(yesterday)) {
      checkDate = yesterday;
    } else {
      // No recent entry, current streak is 0
      currentStreak = 0;
      checkDate = DateTime(1900, 1, 1); // Set to past date to exit loop
    }

    // Count consecutive days backwards
    for (final date in uniqueDates) {
      if (date.isAtSameMomentAs(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;

    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final currentDate = uniqueDates[i];
      final nextDate = uniqueDates[i + 1];
      final diff = currentDate.difference(nextDate).inDays;

      if (diff == 1) {
        // Consecutive day
        tempStreak++;
      } else {
        // Streak broken
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 1;
      }
    }

    // Check final streak
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }
}
