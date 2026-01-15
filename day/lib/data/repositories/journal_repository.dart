import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';

/// JournalRepository - Data access layer for JournalEntry operations
/// Provides CRUD operations and queries for journal entries
class JournalRepository {
  // Database service instance
  final DatabaseService _db = DatabaseService.instance;

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Insert a new journal entry into the database
  Future<void> insert(JournalEntry entry) async {
    final db = await _db.database;
    await db.insert(
      'journal_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing journal entry in the database
  Future<void> update(JournalEntry entry) async {
    final db = await _db.database;
    await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Delete a journal entry from the database
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get a journal entry by ID
  Future<JournalEntry?> getById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }

  // ============================================================================
  // QUERY METHODS
  // ============================================================================

  /// Get a journal entry for a specific date
  Future<JournalEntry?> getByDate(DateTime date) async {
    final db = await _db.database;

    // Format date as yyyy-MM-dd
    final dateString = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'journal_entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }

  /// Get all journal entries ordered by date descending
  Future<List<JournalEntry>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      'journal_entries',
      orderBy: 'date DESC',
    );

    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Get recent journal entries with limit
  Future<List<JournalEntry>> getRecent(int limit) async {
    final db = await _db.database;
    final maps = await db.query(
      'journal_entries',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Get journal entries within a date range
  Future<List<JournalEntry>> getInDateRange(DateTime start, DateTime end) async {
    final db = await _db.database;

    final startString = start.toIso8601String();
    final endString = end.toIso8601String();

    final maps = await db.query(
      'journal_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startString, endString],
      orderBy: 'date ASC',
    );

    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Get a journal entry by linked daily entry ID
  Future<JournalEntry?> getByLinkedEntry(String entryId) async {
    final db = await _db.database;
    final maps = await db.query(
      'journal_entries',
      where: 'linked_entry_id = ?',
      whereArgs: [entryId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }

  /// Get total count of journal entries
  Future<int> getCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM journal_entries');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Search journal entries by content
  Future<List<JournalEntry>> searchByContent(String query) async {
    final db = await _db.database;
    final maps = await db.query(
      'journal_entries',
      where: 'content LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );

    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }
}
