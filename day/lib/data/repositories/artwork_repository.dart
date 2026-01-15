import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/artwork.dart';

/// ArtworkRepository - Data access layer for Artwork operations
/// Provides CRUD operations and queries for generated artworks
class ArtworkRepository {
  // Database service instance
  final DatabaseService _db = DatabaseService.instance;

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Insert a new artwork into the database
  Future<void> insert(Artwork artwork) async {
    final db = await _db.database;
    await db.insert(
      'artworks',
      artwork.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing artwork in the database
  Future<void> update(Artwork artwork) async {
    final db = await _db.database;
    await db.update(
      'artworks',
      artwork.toMap(),
      where: 'id = ?',
      whereArgs: [artwork.id],
    );
  }

  /// Delete an artwork from the database
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(
      'artworks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get an artwork by ID
  Future<Artwork?> getById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'artworks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Artwork.fromMap(maps.first);
  }

  // ============================================================================
  // QUERY METHODS
  // ============================================================================

  /// Get all artworks ordered by creation date descending
  Future<List<Artwork>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      'artworks',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }

  /// Get artworks by type (daily, weekly, monthly)
  Future<List<Artwork>> getByType(ArtworkType type) async {
    final db = await _db.database;
    final maps = await db.query(
      'artworks',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }

  /// Get all favorite artworks
  Future<List<Artwork>> getFavorites() async {
    final db = await _db.database;
    final maps = await db.query(
      'artworks',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }

  /// Get all public artworks
  Future<List<Artwork>> getPublic() async {
    final db = await _db.database;
    final maps = await db.query(
      'artworks',
      where: 'is_public = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }

  /// Get artworks by visualization mode
  Future<List<Artwork>> getByVisualizationMode(VisualizationMode mode) async {
    final db = await _db.database;
    final maps = await db.query(
      'artworks',
      where: 'visualization_mode = ?',
      whereArgs: [mode.name],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }

  /// Get artworks within a date range
  Future<List<Artwork>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _db.database;

    final startString = start.toIso8601String();
    final endString = end.toIso8601String();

    final maps = await db.query(
      'artworks',
      where: 'start_date >= ? AND end_date <= ?',
      whereArgs: [startString, endString],
      orderBy: 'start_date ASC',
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }

  // ============================================================================
  // TIME-BASED QUERIES
  // ============================================================================

  /// Get monthly artworks for a specific year and month
  Future<List<Artwork>> getMonthlyArtworks(int year, int month) async {
    final db = await _db.database;

    // Create date range for the month
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final maps = await db.query(
      'artworks',
      where: 'type = ? AND start_date >= ? AND end_date <= ?',
      whereArgs: [
        ArtworkType.monthly.name,
        firstDay.toIso8601String(),
        lastDay.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }

  /// Get weekly artworks for a specific year and week number
  Future<List<Artwork>> getWeeklyArtworks(int year, int weekNumber) async {
    final db = await _db.database;

    // Calculate the date range for the week
    // Week 1 is the first week with at least 4 days in January
    final jan4 = DateTime(year, 1, 4);
    final weekStart = jan4.subtract(Duration(days: jan4.weekday - 1));
    final targetWeekStart = weekStart.add(Duration(days: (weekNumber - 1) * 7));
    final targetWeekEnd = targetWeekStart.add(const Duration(days: 6));

    final maps = await db.query(
      'artworks',
      where: 'type = ? AND start_date >= ? AND end_date <= ?',
      whereArgs: [
        ArtworkType.weekly.name,
        targetWeekStart.toIso8601String(),
        targetWeekEnd.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Toggle favorite status of an artwork
  /// Returns the new favorite state
  Future<bool> toggleFavorite(String id) async {
    final db = await _db.database;

    // Get current artwork
    final artwork = await getById(id);
    if (artwork == null) return false;

    // Toggle favorite status
    final newFavoriteState = !artwork.isFavorite;

    // Update in database
    await db.update(
      'artworks',
      {'is_favorite': newFavoriteState ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    return newFavoriteState;
  }

  /// Set the public status of an artwork
  Future<void> setPublic(String id, bool isPublic) async {
    final db = await _db.database;
    await db.update(
      'artworks',
      {'is_public': isPublic ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Increment the appreciation count of an artwork
  Future<void> incrementAppreciation(String id) async {
    final db = await _db.database;

    // Get current artwork
    final artwork = await getById(id);
    if (artwork == null) return;

    // Increment appreciation count
    await db.update(
      'artworks',
      {'appreciation_count': artwork.appreciationCount + 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total count of artworks
  Future<int> getCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM artworks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get count of favorite artworks
  Future<int> getFavoritesCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM artworks WHERE is_favorite = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get recent artworks with limit
  Future<List<Artwork>> getRecentArtworks(int limit) async {
    final db = await _db.database;
    final maps = await db.query(
      'artworks',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => Artwork.fromMap(map)).toList();
  }
}
