import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Visualization modes available for generating artwork
enum VisualizationMode {
  topography,
  river,
  stars,
  treeRings,
  smoke,
  ocean,
  city,
  music,
}

/// Extension methods for VisualizationMode
extension VisualizationModeExtension on VisualizationMode {
  /// Returns human-readable display name
  String get displayName {
    switch (this) {
      case VisualizationMode.topography:
        return 'Topography';
      case VisualizationMode.river:
        return 'River Flow';
      case VisualizationMode.stars:
        return 'Star Map';
      case VisualizationMode.treeRings:
        return 'Tree Rings';
      case VisualizationMode.smoke:
        return 'Smoke';
      case VisualizationMode.ocean:
        return 'Ocean Waves';
      case VisualizationMode.city:
        return 'City Skyline';
      case VisualizationMode.music:
        return 'Music Score';
    }
  }

  /// Returns true if this visualization mode requires premium
  bool get isPremium {
    switch (this) {
      case VisualizationMode.treeRings:
      case VisualizationMode.smoke:
      case VisualizationMode.ocean:
        return true;
      default:
        return false;
    }
  }

  /// Returns SF Symbol icon name for this visualization mode
  String get iconName {
    switch (this) {
      case VisualizationMode.topography:
        return 'mountain.2';
      case VisualizationMode.river:
        return 'water.waves';
      case VisualizationMode.stars:
        return 'star';
      case VisualizationMode.treeRings:
        return 'leaf';
      case VisualizationMode.smoke:
        return 'cloud.fog';
      case VisualizationMode.ocean:
        return 'tropicalstorm';
      case VisualizationMode.city:
        return 'building.2';
      case VisualizationMode.music:
        return 'music.note.list';
    }
  }
}

/// Type of artwork based on time period
enum ArtworkType {
  daily,
  weekly,
  monthly,
}

/// Artwork - Represents a generated visualization from mood data
/// Contains metadata, AI-generated insights, and user engagement data
class Artwork extends Equatable {
  /// Unique identifier for this artwork
  final String id;

  /// User ID for cloud sync (null if local only)
  final String? userId;

  /// IDs of DailyEntry records that created this artwork
  final List<String> entryIds;

  /// Type of artwork (daily, weekly, monthly)
  final ArtworkType type;

  /// Visualization mode used to generate this artwork
  final VisualizationMode visualizationMode;

  /// Local path to full-size generated image
  final String? imagePath;

  /// Local path to thumbnail image
  final String? thumbnailPath;

  /// Cloud URL to full-size image (if synced)
  final String? imageUrl;

  /// Cloud URL to thumbnail image (if synced)
  final String? thumbnailUrl;

  /// Dominant colors in the artwork (hex strings)
  final List<String> colorPalette;

  /// Most dominant color (hex string)
  final String? dominantColor;

  /// Title of the artwork (AI generated or user set)
  final String? title;

  /// Description of the artwork (AI generated)
  final String? description;

  /// Geographic location match (name, percentage, imageUrl)
  final Map<String, dynamic>? geographyMatch;

  /// Famous painter style match (name, percentage, imageUrl)
  final Map<String, dynamic>? painterMatch;

  /// Art movement match (name, percentage)
  final Map<String, dynamic>? movementMatch;

  /// Season match (season, percentage)
  final Map<String, dynamic>? seasonMatch;

  /// Element percentages (water, fire, earth, air)
  final Map<String, dynamic>? elementMatch;

  /// Whether this artwork is marked as favorite
  final bool isFavorite;

  /// Whether this artwork is shared to public gallery
  final bool isPublic;

  /// Number of appreciations/likes from public gallery
  final int appreciationCount;

  /// Start date of the period (first entry date)
  final DateTime startDate;

  /// End date of the period (last entry date)
  final DateTime endDate;

  /// Timestamp when artwork was created
  final DateTime createdAt;

  // ============================================================================
  // CONSTRUCTORS
  // ============================================================================

  /// Main constructor
  const Artwork({
    required this.id,
    required this.entryIds,
    required this.type,
    required this.visualizationMode,
    required this.colorPalette,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.userId,
    this.imagePath,
    this.thumbnailPath,
    this.imageUrl,
    this.thumbnailUrl,
    this.dominantColor,
    this.title,
    this.description,
    this.geographyMatch,
    this.painterMatch,
    this.movementMatch,
    this.seasonMatch,
    this.elementMatch,
    this.isFavorite = false,
    this.isPublic = false,
    this.appreciationCount = 0,
  });

  /// Create a new artwork with auto-generated ID and timestamp
  factory Artwork.create({
    required List<String> entryIds,
    required ArtworkType type,
    required VisualizationMode visualizationMode,
    required List<String> colorPalette,
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
    String? imagePath,
    String? thumbnailPath,
    String? imageUrl,
    String? thumbnailUrl,
    String? dominantColor,
    String? title,
    String? description,
    Map<String, dynamic>? geographyMatch,
    Map<String, dynamic>? painterMatch,
    Map<String, dynamic>? movementMatch,
    Map<String, dynamic>? seasonMatch,
    Map<String, dynamic>? elementMatch,
  }) {
    return Artwork(
      id: const Uuid().v4(),
      userId: userId,
      entryIds: entryIds,
      type: type,
      visualizationMode: visualizationMode,
      imagePath: imagePath,
      thumbnailPath: thumbnailPath,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      colorPalette: colorPalette,
      dominantColor: dominantColor,
      title: title,
      description: description,
      geographyMatch: geographyMatch,
      painterMatch: painterMatch,
      movementMatch: movementMatch,
      seasonMatch: seasonMatch,
      elementMatch: elementMatch,
      isFavorite: false,
      isPublic: false,
      appreciationCount: 0,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
    );
  }

  /// Create an artwork from a database map
  factory Artwork.fromMap(Map<String, dynamic> map) {
    return Artwork(
      id: map['id'] as String,
      userId: map['userId'] as String?,
      entryIds: (jsonDecode(map['entryIds'] as String) as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: ArtworkType.values.firstWhere(
        (e) => e.name == map['type'] as String,
      ),
      visualizationMode: VisualizationMode.values.firstWhere(
        (e) => e.name == map['visualizationMode'] as String,
      ),
      imagePath: map['imagePath'] as String?,
      thumbnailPath: map['thumbnailPath'] as String?,
      imageUrl: map['imageUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      colorPalette: (jsonDecode(map['colorPalette'] as String) as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dominantColor: map['dominantColor'] as String?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      geographyMatch: map['geographyMatch'] != null
          ? jsonDecode(map['geographyMatch'] as String) as Map<String, dynamic>
          : null,
      painterMatch: map['painterMatch'] != null
          ? jsonDecode(map['painterMatch'] as String) as Map<String, dynamic>
          : null,
      movementMatch: map['movementMatch'] != null
          ? jsonDecode(map['movementMatch'] as String) as Map<String, dynamic>
          : null,
      seasonMatch: map['seasonMatch'] != null
          ? jsonDecode(map['seasonMatch'] as String) as Map<String, dynamic>
          : null,
      elementMatch: map['elementMatch'] != null
          ? jsonDecode(map['elementMatch'] as String) as Map<String, dynamic>
          : null,
      isFavorite: (map['isFavorite'] as int) == 1,
      isPublic: (map['isPublic'] as int) == 1,
      appreciationCount: map['appreciationCount'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // ============================================================================
  // METHODS
  // ============================================================================

  /// Convert artwork to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'entryIds': jsonEncode(entryIds),
      'type': type.name,
      'visualizationMode': visualizationMode.name,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'colorPalette': jsonEncode(colorPalette),
      'dominantColor': dominantColor,
      'title': title,
      'description': description,
      'geographyMatch': geographyMatch != null ? jsonEncode(geographyMatch) : null,
      'painterMatch': painterMatch != null ? jsonEncode(painterMatch) : null,
      'movementMatch': movementMatch != null ? jsonEncode(movementMatch) : null,
      'seasonMatch': seasonMatch != null ? jsonEncode(seasonMatch) : null,
      'elementMatch': elementMatch != null ? jsonEncode(elementMatch) : null,
      'isFavorite': isFavorite ? 1 : 0,
      'isPublic': isPublic ? 1 : 0,
      'appreciationCount': appreciationCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy of this artwork with updated fields
  Artwork copyWith({
    String? id,
    String? userId,
    List<String>? entryIds,
    ArtworkType? type,
    VisualizationMode? visualizationMode,
    String? imagePath,
    String? thumbnailPath,
    String? imageUrl,
    String? thumbnailUrl,
    List<String>? colorPalette,
    String? dominantColor,
    String? title,
    String? description,
    Map<String, dynamic>? geographyMatch,
    Map<String, dynamic>? painterMatch,
    Map<String, dynamic>? movementMatch,
    Map<String, dynamic>? seasonMatch,
    Map<String, dynamic>? elementMatch,
    bool? isFavorite,
    bool? isPublic,
    int? appreciationCount,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return Artwork(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entryIds: entryIds ?? this.entryIds,
      type: type ?? this.type,
      visualizationMode: visualizationMode ?? this.visualizationMode,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      colorPalette: colorPalette ?? this.colorPalette,
      dominantColor: dominantColor ?? this.dominantColor,
      title: title ?? this.title,
      description: description ?? this.description,
      geographyMatch: geographyMatch ?? this.geographyMatch,
      painterMatch: painterMatch ?? this.painterMatch,
      movementMatch: movementMatch ?? this.movementMatch,
      seasonMatch: seasonMatch ?? this.seasonMatch,
      elementMatch: elementMatch ?? this.elementMatch,
      isFavorite: isFavorite ?? this.isFavorite,
      isPublic: isPublic ?? this.isPublic,
      appreciationCount: appreciationCount ?? this.appreciationCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Returns formatted date range text based on artwork type
  String get dateRangeText {
    switch (type) {
      case ArtworkType.daily:
        // "Jan 15, 2025"
        return '${_monthName(startDate.month)} ${startDate.day}, ${startDate.year}';
      case ArtworkType.weekly:
        // "Jan 1 - Jan 7, 2025"
        if (startDate.month == endDate.month) {
          return '${_monthNameShort(startDate.month)} ${startDate.day} - ${endDate.day}, ${endDate.year}';
        } else {
          return '${_monthNameShort(startDate.month)} ${startDate.day} - ${_monthNameShort(endDate.month)} ${endDate.day}, ${endDate.year}';
        }
      case ArtworkType.monthly:
        // "January 2025"
        return '${_monthName(startDate.month)} ${startDate.year}';
    }
  }

  /// Returns the number of entries included in this artwork
  int get entryCount => entryIds.length;

  // Helper methods for date formatting
  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  String _monthNameShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  // ============================================================================
  // EQUATABLE
  // ============================================================================

  @override
  List<Object?> get props => [
        id,
        userId,
        entryIds,
        type,
        visualizationMode,
        imagePath,
        thumbnailPath,
        imageUrl,
        thumbnailUrl,
        colorPalette,
        dominantColor,
        title,
        description,
        geographyMatch,
        painterMatch,
        movementMatch,
        seasonMatch,
        elementMatch,
        isFavorite,
        isPublic,
        appreciationCount,
        startDate,
        endDate,
        createdAt,
      ];
}
