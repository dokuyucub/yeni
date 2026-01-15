import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';
import 'repository_providers.dart';

/// AsyncNotifier for managing user profile state
/// Handles loading, updating, and refreshing user profile data
class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final repository = ref.read(userRepositoryProvider);
    return await repository.getOrCreateProfile();
  }

  /// Update the user profile
  Future<void> updateProfile(UserProfile profile) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.updateProfile(profile);
    ref.invalidateSelf();
  }

  /// Update streak information
  Future<void> updateStreak(int current, int longest) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.updateStreak(current, longest);
    ref.invalidateSelf();
  }

  /// Increment the total entries count
  Future<void> incrementEntryCount() async {
    final repository = ref.read(userRepositoryProvider);
    await repository.incrementEntryCount();
    ref.invalidateSelf();
  }

  /// Increment the total artworks count
  Future<void> incrementArtworkCount() async {
    final repository = ref.read(userRepositoryProvider);
    await repository.incrementArtworkCount();
    ref.invalidateSelf();
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete() async {
    final repository = ref.read(userRepositoryProvider);
    await repository.setOnboardingComplete(true);
    ref.invalidateSelf();
  }

  /// Update theme mode (light, dark, system)
  Future<void> updateThemeMode(String mode) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.updateThemeMode(mode);
    ref.invalidateSelf();
  }
}

/// Provider for user profile with state management
/// Use this to access and update user profile throughout the app
final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile>(() {
  return UserProfileNotifier();
});

/// Provider for checking premium status
/// Returns true if user has premium access
final isPremiumProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.whenOrNull(data: (user) => user.isPremium) ?? false;
});

/// Provider for current theme mode
/// Returns 'light', 'dark', or 'system'
final themeModeProvider = Provider<String>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.whenOrNull(data: (user) => user.themeMode) ?? 'system';
});
