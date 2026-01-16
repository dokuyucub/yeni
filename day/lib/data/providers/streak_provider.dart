import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/entry_repository.dart';
import 'repository_providers.dart';
import 'user_provider.dart';

/// Provider for streak information
/// Returns a map with 'current' and 'longest' streak counts
/// Also updates the user profile with streak data
final streakProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.read(entryRepositoryProvider);
  final streakInfo = await repository.getStreakInfo();

  // Update user profile with latest streak info
  final userNotifier = ref.read(userProfileProvider.notifier);
  await userNotifier.updateStreak(
    streakInfo['current'] ?? 0,
    streakInfo['longest'] ?? 0,
  );

  return streakInfo;
});

/// Provider for current streak count
/// Returns 0 if streak data is not available
final currentStreakProvider = Provider<int>((ref) {
  final streakAsync = ref.watch(streakProvider);
  return streakAsync.whenOrNull(data: (data) => data['current']) ?? 0;
});

/// Provider for longest streak count
/// Returns 0 if streak data is not available
final longestStreakProvider = Provider<int>((ref) {
  final streakAsync = ref.watch(streakProvider);
  return streakAsync.whenOrNull(data: (data) => data['longest']) ?? 0;
});

/// Provider to check if user has created an entry today
/// Returns true if an entry exists for today
final hasEntryTodayProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(entryRepositoryProvider);
  return await repository.hasEntryForDate(DateTime.now());
});
