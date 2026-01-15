import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/collection.dart';

/// CollectionRepository - Data access layer for Collection operations
/// Provides CRUD operations and queries for artwork collections
class CollectionRepository {
  // Database service instance
  final DatabaseService _db = DatabaseService.instance;

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Insert a new collection into the database
  Future<void> insert(Collection collection) async {
    final db = await _db.database;
    await db.insert(
      'collections',
      collection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing collection in the database
  Future<void> update(Collection collection) async {
    final db = await _db.database;
    await db.update(
      'collections',
      collection.toMap(),
      where: 'id = ?',
      whereArgs: [collection.id],
    );
  }

  /// Delete a collection from the database
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(
      'collections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get a collection by ID
  Future<Collection?> getById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'collections',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Collection.fromMap(maps.first);
  }

  // ============================================================================
  // QUERY METHODS
  // ============================================================================

  /// Get all collections ordered by creation date descending
  Future<List<Collection>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      'collections',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Collection.fromMap(map)).toList();
  }

  /// Get collections by type
  Future<List<Collection>> getByType(CollectionType type) async {
    final db = await _db.database;
    final maps = await db.query(
      'collections',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Collection.fromMap(map)).toList();
  }

  /// Get or create the favorites collection
  /// Returns existing favorites collection or creates a new one
  Future<Collection> getFavoritesCollection() async {
    final db = await _db.database;
    final maps = await db.query(
      'collections',
      where: 'type = ?',
      whereArgs: [CollectionType.favorites.name],
      limit: 1,
    );

    // If favorites collection exists, return it
    if (maps.isNotEmpty) {
      return Collection.fromMap(maps.first);
    }

    // Create new favorites collection
    final favoritesCollection = Collection.create(
      name: 'Favorites',
      type: CollectionType.favorites,
      description: 'Your favorite artworks',
      iconName: 'heart.fill',
      colorHex: 'FF6B6B',
    );

    // Insert it into the database
    await insert(favoritesCollection);

    return favoritesCollection;
  }

  /// Get all custom (user-created) collections
  Future<List<Collection>> getCustomCollections() async {
    final db = await _db.database;
    final maps = await db.query(
      'collections',
      where: 'type = ?',
      whereArgs: [CollectionType.custom.name],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Collection.fromMap(map)).toList();
  }

  // ============================================================================
  // COLLECTION OPERATIONS
  // ============================================================================

  /// Add an artwork to a collection
  Future<void> addArtworkToCollection(String collectionId, String artworkId) async {
    // Get the collection
    final collection = await getById(collectionId);
    if (collection == null) return;

    // Add artwork to collection
    final updatedCollection = collection.addArtwork(artworkId);

    // Update in database
    await update(updatedCollection);
  }

  /// Remove an artwork from a collection
  Future<void> removeArtworkFromCollection(String collectionId, String artworkId) async {
    // Get the collection
    final collection = await getById(collectionId);
    if (collection == null) return;

    // Remove artwork from collection
    final updatedCollection = collection.removeArtwork(artworkId);

    // Update in database
    await update(updatedCollection);
  }

  /// Get all collections that contain a specific artwork
  Future<List<Collection>> getCollectionsForArtwork(String artworkId) async {
    // Get all collections
    final allCollections = await getAll();

    // Filter collections that contain the artwork
    return allCollections
        .where((collection) => collection.artworkIds.contains(artworkId))
        .toList();
  }
}
