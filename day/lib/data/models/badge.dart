import 'package:equatable/equatable.dart';

/// Badge rarity levels
enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Badge categories
enum BadgeCategory {
  starter,
  streak,
  collector,
  explorer,
  social,
  wellness,
  special,
}

/// Badge - Represents an achievement that users can unlock
/// Contains metadata and unlock requirements
class Badge extends Equatable {
  /// Unique badge identifier (e.g., "first_entry", "streak_7")
  final String id;

  /// Display name of the badge
  final String name;

  /// Description of how to earn this badge
  final String description;

  /// Category this badge belongs to
  final BadgeCategory category;

  /// Rarity level of this badge
  final BadgeRarity rarity;

  /// SF Symbol or asset name for the icon
  final String iconName;

  /// Number required to unlock (e.g., 7 for streak_7)
  final int? requirement;

  /// Whether this badge is hidden until unlocked
  final bool isSecret;

  // ============================================================================
  // CONSTRUCTOR
  // ============================================================================

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.iconName,
    this.requirement,
    this.isSecret = false,
  });

  // ============================================================================
  // STATIC GETTER - ALL BADGES
  // ============================================================================

  /// Returns all predefined badges in the app
  static List<Badge> get allBadges => [
        // STARTER CATEGORY (common)
        const Badge(
          id: 'first_entry',
          name: 'First Step',
          description: 'Log your first mood',
          category: BadgeCategory.starter,
          rarity: BadgeRarity.common,
          iconName: 'paintbrush',
        ),
        const Badge(
          id: 'first_week',
          name: 'Week One',
          description: 'Complete your first week',
          category: BadgeCategory.starter,
          rarity: BadgeRarity.common,
          iconName: 'calendar',
        ),
        const Badge(
          id: 'first_artwork',
          name: 'Artist',
          description: 'Create your first artwork',
          category: BadgeCategory.starter,
          rarity: BadgeRarity.common,
          iconName: 'photo.artframe',
        ),

        // STREAK CATEGORY
        const Badge(
          id: 'streak_7',
          name: 'On Fire',
          description: '7 day streak',
          category: BadgeCategory.streak,
          rarity: BadgeRarity.common,
          iconName: 'flame',
          requirement: 7,
        ),
        const Badge(
          id: 'streak_30',
          name: 'Dedicated',
          description: '30 day streak',
          category: BadgeCategory.streak,
          rarity: BadgeRarity.rare,
          iconName: 'flame.fill',
          requirement: 30,
        ),
        const Badge(
          id: 'streak_100',
          name: 'Unstoppable',
          description: '100 day streak',
          category: BadgeCategory.streak,
          rarity: BadgeRarity.epic,
          iconName: 'bolt.fill',
          requirement: 100,
        ),
        const Badge(
          id: 'streak_365',
          name: 'Year Master',
          description: '365 day streak',
          category: BadgeCategory.streak,
          rarity: BadgeRarity.legendary,
          iconName: 'crown',
          requirement: 365,
        ),

        // COLLECTOR CATEGORY
        const Badge(
          id: 'favorites_10',
          name: 'Curator',
          description: 'Save 10 favorites',
          category: BadgeCategory.collector,
          rarity: BadgeRarity.common,
          iconName: 'heart.fill',
          requirement: 10,
        ),
        const Badge(
          id: 'all_modes',
          name: 'Explorer',
          description: 'Try all visualization modes',
          category: BadgeCategory.collector,
          rarity: BadgeRarity.rare,
          iconName: 'square.grid.3x3',
        ),
        const Badge(
          id: 'rare_artwork',
          name: 'Rare Find',
          description: 'Create a rare artwork',
          category: BadgeCategory.collector,
          rarity: BadgeRarity.epic,
          iconName: 'sparkles',
        ),

        // EXPLORER CATEGORY
        const Badge(
          id: 'geography_10',
          name: 'World Traveler',
          description: 'Match 10 different places',
          category: BadgeCategory.explorer,
          rarity: BadgeRarity.rare,
          iconName: 'globe',
          requirement: 10,
        ),
        const Badge(
          id: 'painter_10',
          name: 'Art Historian',
          description: 'Match 10 different painters',
          category: BadgeCategory.explorer,
          rarity: BadgeRarity.rare,
          iconName: 'paintpalette',
          requirement: 10,
        ),

        // SOCIAL CATEGORY
        const Badge(
          id: 'first_share',
          name: 'Sharing is Caring',
          description: 'Share your first artwork',
          category: BadgeCategory.social,
          rarity: BadgeRarity.common,
          iconName: 'square.and.arrow.up',
        ),
        const Badge(
          id: 'appreciated_10',
          name: 'Appreciated',
          description: 'Receive 10 appreciations',
          category: BadgeCategory.social,
          rarity: BadgeRarity.rare,
          iconName: 'hands.clap',
          requirement: 10,
        ),

        // WELLNESS CATEGORY
        const Badge(
          id: 'early_bird',
          name: 'Early Bird',
          description: 'Log before 8am for 7 days',
          category: BadgeCategory.wellness,
          rarity: BadgeRarity.rare,
          iconName: 'sunrise',
          requirement: 7,
        ),
        const Badge(
          id: 'night_owl',
          name: 'Night Owl',
          description: 'Log after 10pm for 7 days',
          category: BadgeCategory.wellness,
          rarity: BadgeRarity.rare,
          iconName: 'moon.stars',
          requirement: 7,
        ),
        const Badge(
          id: 'balanced',
          name: 'Balanced',
          description: 'All elements balanced for a week',
          category: BadgeCategory.wellness,
          rarity: BadgeRarity.epic,
          iconName: 'circle.grid.cross',
        ),

        // SPECIAL CATEGORY
        const Badge(
          id: 'premium_supporter',
          name: 'Supporter',
          description: 'Upgrade to Premium',
          category: BadgeCategory.special,
          rarity: BadgeRarity.rare,
          iconName: 'star.fill',
        ),
        const Badge(
          id: 'feedback',
          name: 'Voice Heard',
          description: 'Submit feedback',
          category: BadgeCategory.special,
          rarity: BadgeRarity.common,
          iconName: 'envelope',
        ),
        const Badge(
          id: 'secret_rainbow',
          name: 'Rainbow',
          description: 'Use all 24 colors in a month',
          category: BadgeCategory.special,
          rarity: BadgeRarity.legendary,
          iconName: 'rainbow',
          isSecret: true,
        ),
      ];

  // ============================================================================
  // EQUATABLE
  // ============================================================================

  @override
  List<Object?> get props => [id];
}
