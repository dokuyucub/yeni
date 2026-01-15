import 'package:equatable/equatable.dart';

/// UserBadge - Tracks user's progress and unlock status for badges
/// Links a user to a badge with progress information
class UserBadge extends Equatable {
  /// User ID (references UserProfile)
  final String userId;

  /// Badge ID (references Badge)
  final String badgeId;

  /// Timestamp when badge was unlocked
  final DateTime unlockedAt;

  /// Current progress toward requirement
  final int? progress;

  /// Target requirement number
  final int? target;

  // ============================================================================
  // CONSTRUCTOR
  // ============================================================================

  const UserBadge({
    required this.userId,
    required this.badgeId,
    required this.unlockedAt,
    this.progress,
    this.target,
  });

  // ============================================================================
  // NAMED CONSTRUCTORS
  // ============================================================================

  /// Create a user badge from a database map
  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      userId: map['userId'] as String,
      badgeId: map['badgeId'] as String,
      unlockedAt: DateTime.parse(map['unlockedAt'] as String),
      progress: map['progress'] as int?,
      target: map['target'] as int?,
    );
  }

  // ============================================================================
  // METHODS
  // ============================================================================

  /// Convert user badge to database map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'badgeId': badgeId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  /// Create a copy of this user badge with updated fields
  UserBadge copyWith({
    String? userId,
    String? badgeId,
    DateTime? unlockedAt,
    int? progress,
    int? target,
  }) {
    return UserBadge(
      userId: userId ?? this.userId,
      badgeId: badgeId ?? this.badgeId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Returns true if the badge is complete (progress >= target or no target)
  bool get isComplete {
    if (target == null) return true;
    if (progress == null) return false;
    return progress! >= target!;
  }

  /// Returns progress as a percentage (0.0-1.0)
  double get progressPercentage {
    if (isComplete) return 1.0;
    if (target == null || progress == null || target == 0) return 0.0;
    return (progress! / target!).clamp(0.0, 1.0);
  }

  // ============================================================================
  // EQUATABLE
  // ============================================================================

  @override
  List<Object?> get props => [
        userId,
        badgeId,
        unlockedAt,
        progress,
        target,
      ];
}
