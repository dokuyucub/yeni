import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_entry.dart';
import '../repositories/entry_repository.dart';
import 'repository_providers.dart';
import 'user_provider.dart';
import 'streak_provider.dart';

/// Provider for today's daily entry
/// Returns null if no entry exists for today
final todayEntryProvider = FutureProvider<DailyEntry?>((ref) async {
  final repository = ref.read(entryRepositoryProvider);
  return await repository.getByDate(DateTime.now());
});

/// Provider for this week's entries
/// Returns entries from Monday to Sunday of the current week
final weekEntriesProvider = FutureProvider<List<DailyEntry>>((ref) async {
  final repository = ref.read(entryRepositoryProvider);
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
  return await repository.getWeekEntries(startOfWeek);
});

/// Provider for last 7 days of entries
/// Used for home screen visualization
final lastSevenDaysProvider = FutureProvider<List<DailyEntry>>((ref) async {
  final repository = ref.read(entryRepositoryProvider);
  return await repository.getLastNDays(7);
});

/// Family provider for monthly entries
/// Pass a DateTime to get entries for that specific month
final monthEntriesProvider =
    FutureProvider.family<List<DailyEntry>, DateTime>((ref, month) async {
  final repository = ref.read(entryRepositoryProvider);
  return await repository.getMonthEntries(month.year, month.month);
});

/// StateNotifier for managing entry creation and updates
/// Handles today's entry with methods for saving and updating
class EntryNotifier extends StateNotifier<AsyncValue<DailyEntry?>> {
  final Ref ref;

  EntryNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadTodayEntry();
  }

  /// Load today's entry from database
  Future<void> _loadTodayEntry() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(entryRepositoryProvider);
      final entry = await repository.getByDate(DateTime.now());
      state = AsyncValue.data(entry);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Save or update today's entry with mood and notes
  Future<void> saveEntry({
    required String primaryColor,
    String? secondaryColor,
    String? note,
    int? moodScore,
    int? energyScore,
  }) async {
    try {
      final repository = ref.read(entryRepositoryProvider);
      final existing = state.valueOrNull;

      DailyEntry entry;
      if (existing != null) {
        entry = existing.copyWith(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          note: note,
          moodScore: moodScore,
          energyScore: energyScore,
        );
        await repository.update(entry);
      } else {
        entry = DailyEntry.create(
          date: DateTime.now(),
          primaryColor: primaryColor,
        ).copyWith(
          secondaryColor: secondaryColor,
          note: note,
          moodScore: moodScore,
          energyScore: energyScore,
        );
        await repository.insert(entry);
        await ref.read(userProfileProvider.notifier).incrementEntryCount();
      }

      state = AsyncValue.data(entry);
      ref.invalidate(todayEntryProvider);
      ref.invalidate(weekEntriesProvider);
      ref.invalidate(lastSevenDaysProvider);
      ref.invalidate(streakProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update health data for today's entry
  Future<void> updateHealthData({
    int? steps,
    double? sleepHours,
    int? sleepQuality,
    int? heartRateAvg,
    int? hrvAvg,
    int? activeMinutes,
  }) async {
    final existing = state.valueOrNull;
    if (existing == null) return;

    try {
      final repository = ref.read(entryRepositoryProvider);
      final updated = existing.copyWith(
        steps: steps,
        sleepHours: sleepHours,
        sleepQuality: sleepQuality,
        heartRateAvg: heartRateAvg,
        hrvAvg: hrvAvg,
        activeMinutes: activeMinutes,
      );
      await repository.update(updated);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update weather data for today's entry
  Future<void> updateWeatherData({
    String? condition,
    double? temperature,
    int? humidity,
  }) async {
    final existing = state.valueOrNull;
    if (existing == null) return;

    try {
      final repository = ref.read(entryRepositoryProvider);
      final updated = existing.copyWith(
        weatherCondition: condition,
        temperature: temperature,
        humidity: humidity,
      );
      await repository.update(updated);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh today's entry from database
  void refresh() {
    _loadTodayEntry();
  }
}

/// Provider for entry state management
/// Use this to access and modify today's entry
final entryNotifierProvider =
    StateNotifierProvider<EntryNotifier, AsyncValue<DailyEntry?>>((ref) {
  return EntryNotifier(ref);
});
