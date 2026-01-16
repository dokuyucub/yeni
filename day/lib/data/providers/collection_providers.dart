import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection.dart';
import '../repositories/collection_repository.dart';
import 'repository_providers.dart';

/// Provider for all collections
/// Returns all collections ordered by creation date
final allCollectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final repository = ref.read(collectionRepositoryProvider);
  return await repository.getAll();
});

/// Provider for favorites collection
/// Returns the special favorites collection (auto-created if doesn't exist)
final favoritesCollectionProvider = FutureProvider<Collection>((ref) async {
  final repository = ref.read(collectionRepositoryProvider);
  return await repository.getFavoritesCollection();
});

/// Provider for custom collections
/// Returns only user-created collections
final customCollectionsProvider =
    FutureProvider<List<Collection>>((ref) async {
  final repository = ref.read(collectionRepositoryProvider);
  return await repository.getCustomCollections();
});

/// Family provider for collection by id
/// Returns null if collection doesn't exist
final collectionByIdProvider =
    FutureProvider.family<Collection?, String>((ref, id) async {
  final repository = ref.read(collectionRepositoryProvider);
  return await repository.getById(id);
});

/// StateNotifier for managing collection operations
/// Handles creating, updating, and deleting collections
class CollectionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CollectionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Create a new custom collection
  Future<void> createCollection(
    String name, {
    String? description,
  }) async {
    try {
      final repository = ref.read(collectionRepositoryProvider);
      final collection = Collection.create(
        name: name,
        type: CollectionType.custom,
      ).copyWith(description: description);
      await repository.insert(collection);
      _invalidate();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add an artwork to a collection
  Future<void> addToCollection(String collectionId, String artworkId) async {
    try {
      final repository = ref.read(collectionRepositoryProvider);
      await repository.addArtworkToCollection(collectionId, artworkId);
      _invalidate();
      ref.invalidate(collectionByIdProvider(collectionId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Remove an artwork from a collection
  Future<void> removeFromCollection(
    String collectionId,
    String artworkId,
  ) async {
    try {
      final repository = ref.read(collectionRepositoryProvider);
      await repository.removeArtworkFromCollection(collectionId, artworkId);
      _invalidate();
      ref.invalidate(collectionByIdProvider(collectionId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a collection
  Future<void> deleteCollection(String id) async {
    try {
      final repository = ref.read(collectionRepositoryProvider);
      await repository.delete(id);
      _invalidate();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Invalidate all collection-related providers
  void _invalidate() {
    ref.invalidate(allCollectionsProvider);
    ref.invalidate(customCollectionsProvider);
  }
}

/// Provider for collection state management
/// Use this to create, update, and delete collections
final collectionNotifierProvider =
    StateNotifierProvider<CollectionNotifier, AsyncValue<void>>((ref) {
  return CollectionNotifier(ref);
});
