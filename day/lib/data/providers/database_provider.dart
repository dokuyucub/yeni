import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Provider for DatabaseService singleton
/// Provides access to the SQLite database throughout the app
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});
