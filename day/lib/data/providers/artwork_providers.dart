import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/artwork.dart';
import '../repositories/artwork_repository.dart';
import 'repository_providers.dart';
import 'user_provider.dart';

/// Provider for all artworks
/// Returns all artworks ordered by creation date (newest first)
final allArtworksProvider = FutureProvider<List<Artwork>>((ref) async {
  final repository = ref.read(artworkRepositoryProvider);
  return await repository.getAll();
});

/// Provider for favorite artworks
/// Returns only artworks marked as favorites
final favoriteArtworksProvider = FutureProvider<List<Artwork>>((ref) async {
  final repository = ref.read(artworkRepositoryProvider);
  return await repository.getFavorites();
});

/// Provider for recent artworks
/// Returns the 10 most recent artworks
final recentArtworksProvider = FutureProvider<List<Artwork>>((ref) async {
  final repository = ref.read(artworkRepositoryProvider);
  return await repository.getRecentArtworks(10);
});

/// Family provider for artworks by type
/// Pass an ArtworkType to get artworks of that specific type
final artworksByTypeProvider =
    FutureProvider.family<List<Artwork>, ArtworkType>((ref, type) async {
  final repository = ref.read(artworkRepositoryProvider);
  return await repository.getByType(type);
});

/// Provider for monthly artworks
/// Returns all monthly recap artworks
final monthlyArtworksProvider = FutureProvider<List<Artwork>>((ref) async {
  final repository = ref.read(artworkRepositoryProvider);
  return await repository.getByType(ArtworkType.monthly);
});

/// Family provider for single artwork by id
/// Returns null if artwork doesn't exist
final artworkByIdProvider =
    FutureProvider.family<Artwork?, String>((ref, id) async {
  final repository = ref.read(artworkRepositoryProvider);
  return await repository.getById(id);
});

/// Provider for total artwork count
/// Returns the number of artworks created
final artworkCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(artworkRepositoryProvider);
  return await repository.getCount();
});

/// StateNotifier for managing artwork operations
/// Handles creating, updating, and deleting artworks
class ArtworkNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ArtworkNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Create a new artwork
  Future<void> createArtwork(Artwork artwork) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(artworkRepositoryProvider);
      await repository.insert(artwork);
      await ref.read(userProfileProvider.notifier).incrementArtworkCount();
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update an existing artwork
  Future<void> updateArtwork(Artwork artwork) async {
    try {
      final repository = ref.read(artworkRepositoryProvider);
      await repository.update(artwork);
      _invalidateProviders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggle favorite status of an artwork
  /// Returns the new favorite state
  Future<bool> toggleFavorite(String artworkId) async {
    try {
      final repository = ref.read(artworkRepositoryProvider);
      final newState = await repository.toggleFavorite(artworkId);
      ref.invalidate(favoriteArtworksProvider);
      ref.invalidate(artworkByIdProvider(artworkId));
      return newState;
    } catch (e) {
      return false;
    }
  }

  /// Delete an artwork
  Future<void> deleteArtwork(String id) async {
    try {
      final repository = ref.read(artworkRepositoryProvider);
      await repository.delete(id);
      _invalidateProviders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Invalidate all artwork-related providers
  void _invalidateProviders() {
    ref.invalidate(allArtworksProvider);
    ref.invalidate(favoriteArtworksProvider);
    ref.invalidate(recentArtworksProvider);
    ref.invalidate(monthlyArtworksProvider);
    ref.invalidate(artworkCountProvider);
  }
}

/// Provider for artwork state management
/// Use this to create, update, and delete artworks
final artworkNotifierProvider =
    StateNotifierProvider<ArtworkNotifier, AsyncValue<void>>((ref) {
  return ArtworkNotifier(ref);
});
