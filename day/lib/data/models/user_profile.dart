import 'package:equatable/equatable.dart';

/// UserProfile - Represents user account data and app settings
/// Contains statistics, preferences, and premium status
class UserProfile extends Equatable {
  /// Unique user identifier
  final String id;

  /// User's email address
  final String? email;

  /// Display name
  final String? displayName;

  /// Cloud URL to avatar image
  final String? avatarUrl;

  /// Local artwork ID used as avatar
  final String? avatarArtworkId;

  /// Premium subscription status
  final bool isPremium;

  /// Premium subscription expiration date
  final DateTime? premiumExpiresAt;

  /// Current consecutive day streak
  final int currentStreak;

  /// Longest streak ever achieved
  final int longestStreak;

  /// Total number of entries created
  final int totalEntries;

  /// Total number of artworks created
  final int totalArtworks;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last time user created an entry
  final DateTime? lastEntryAt;

  /// User's timezone
  final String? timezone;

  /// Whether notifications are enabled
  final bool notificationsEnabled;

  /// Time for daily notification (e.g., "20:00")
  final String? notificationTime;

  /// Theme mode: "system", "light", or "dark"
  final String themeMode;

  /// Whether analytics are enabled
  final bool analyticsEnabled;

  /// Whether user has completed onboarding
  final bool hasCompletedOnboarding;

  // ============================================================================
  // CONSTRUCTORS
  // ============================================================================

  /// Main constructor
  const UserProfile({
    required this.id,
    required this.createdAt,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.avatarArtworkId,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalEntries = 0,
    this.totalArtworks = 0,
    this.lastEntryAt,
    this.timezone,
    this.notificationsEnabled = true,
    this.notificationTime,
    this.themeMode = 'system',
    this.analyticsEnabled = true,
    this.hasCompletedOnboarding = false,
  });

  /// Create a new user profile with default values
  factory UserProfile.createNew({
    required String id,
    String? email,
    String? displayName,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
  }

  /// Create a user profile from a database map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      avatarArtworkId: map['avatarArtworkId'] as String?,
      isPremium: (map['isPremium'] as int) == 1,
      premiumExpiresAt: map['premiumExpiresAt'] != null
          ? DateTime.parse(map['premiumExpiresAt'] as String)
          : null,
      currentStreak: map['currentStreak'] as int,
      longestStreak: map['longestStreak'] as int,
      totalEntries: map['totalEntries'] as int,
      totalArtworks: map['totalArtworks'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastEntryAt: map['lastEntryAt'] != null
          ? DateTime.parse(map['lastEntryAt'] as String)
          : null,
      timezone: map['timezone'] as String?,
      notificationsEnabled: (map['notificationsEnabled'] as int) == 1,
      notificationTime: map['notificationTime'] as String?,
      themeMode: map['themeMode'] as String,
      analyticsEnabled: (map['analyticsEnabled'] as int) == 1,
      hasCompletedOnboarding: (map['hasCompletedOnboarding'] as int) == 1,
    );
  }

  // ============================================================================
  // METHODS
  // ============================================================================

  /// Convert user profile to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'avatarArtworkId': avatarArtworkId,
      'isPremium': isPremium ? 1 : 0,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalEntries': totalEntries,
      'totalArtworks': totalArtworks,
      'createdAt': createdAt.toIso8601String(),
      'lastEntryAt': lastEntryAt?.toIso8601String(),
      'timezone': timezone,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'notificationTime': notificationTime,
      'themeMode': themeMode,
      'analyticsEnabled': analyticsEnabled ? 1 : 0,
      'hasCompletedOnboarding': hasCompletedOnboarding ? 1 : 0,
    };
  }

  /// Create a copy of this profile with updated fields
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? avatarArtworkId,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    int? currentStreak,
    int? longestStreak,
    int? totalEntries,
    int? totalArtworks,
    DateTime? createdAt,
    DateTime? lastEntryAt,
    String? timezone,
    bool? notificationsEnabled,
    String? notificationTime,
    String? themeMode,
    bool? analyticsEnabled,
    bool? hasCompletedOnboarding,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarArtworkId: avatarArtworkId ?? this.avatarArtworkId,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalEntries: totalEntries ?? this.totalEntries,
      totalArtworks: totalArtworks ?? this.totalArtworks,
      createdAt: createdAt ?? this.createdAt,
      lastEntryAt: lastEntryAt ?? this.lastEntryAt,
      timezone: timezone ?? this.timezone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      themeMode: themeMode ?? this.themeMode,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Returns true if the streak is still active (last entry was today or yesterday)
  bool get isStreakActive {
    if (lastEntryAt == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastEntry = DateTime(lastEntryAt!.year, lastEntryAt!.month, lastEntryAt!.day);

    return lastEntry.isAtSameMomentAs(today) || lastEntry.isAtSameMomentAs(yesterday);
  }

  /// Returns display name or "Day User" as default
  String get displayNameOrDefault {
    if (displayName == null || displayName!.isEmpty) {
      return 'Day User';
    }
    return displayName!;
  }

  /// Returns first letter of display name in uppercase, or "D"
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return 'D';
    }
    return displayName![0].toUpperCase();
  }

  // ============================================================================
  // EQUATABLE
  // ============================================================================

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        avatarArtworkId,
        isPremium,
        premiumExpiresAt,
        currentStreak,
        longestStreak,
        totalEntries,
        totalArtworks,
        createdAt,
        lastEntryAt,
        timezone,
        notificationsEnabled,
        notificationTime,
        themeMode,
        analyticsEnabled,
        hasCompletedOnboarding,
      ];
}
