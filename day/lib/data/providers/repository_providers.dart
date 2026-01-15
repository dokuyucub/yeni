import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/entry_repository.dart';
import '../repositories/artwork_repository.dart';
import '../repositories/journal_repository.dart';
import '../repositories/collection_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/badge_repository.dart';

/// Provider for EntryRepository
/// Provides access to daily entry data operations
final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository();
});

/// Provider for ArtworkRepository
/// Provides access to artwork data operations
final artworkRepositoryProvider = Provider<ArtworkRepository>((ref) {
  return ArtworkRepository();
});

/// Provider for JournalRepository
/// Provides access to journal entry data operations
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

/// Provider for CollectionRepository
/// Provides access to collection data operations
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepository();
});

/// Provider for UserRepository
/// Provides access to user profile data operations
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Provider for BadgeRepository
/// Provides access to badge and achievement data operations
final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  return BadgeRepository();
});
