/// Data layer barrel file - exports all data layer components
/// This is the main entry point for accessing the data layer throughout the app
///
/// Usage:
/// ```dart
/// import 'package:day/data/data.dart';
/// ```
///
/// This provides access to:
/// - All data models (DailyEntry, Artwork, JournalEntry, Collection, UserProfile, Badge, UserBadge)
/// - All repositories (EntryRepository, ArtworkRepository, JournalRepository, CollectionRepository, UserRepository, BadgeRepository)
/// - All services (DatabaseService)
/// - All providers (Riverpod providers for state management)

// Export models
export 'models/models.dart';

// Export repositories
export 'repositories/repositories.dart';

// Export services
export 'services/services.dart';

// Export providers
export 'providers/providers.dart';
