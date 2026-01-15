import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// DailyEntry - Main data model representing a day's mood, health, and activity data
/// This model captures all information logged by the user for a single day
class DailyEntry extends Equatable {
  /// Unique identifier for this entry
  final String id;

  /// Date of this entry (day only, time is ignored)
  final DateTime date;

  /// Primary mood color as hex string (e.g., "FF5733")
  final String primaryColor;

  /// Optional secondary mood color as hex string
  final String? secondaryColor;

  /// Optional text note (max 500 characters)
  final String? note;

  /// Optional path to voice note recording
  final String? voiceNotePath;

  /// Optional manual mood score (1-5 scale)
  final int? moodScore;

  /// Optional manual energy score (1-5 scale)
  final int? energyScore;

  /// Step count for the day
  final int? steps;

  /// Total hours of sleep
  final double? sleepHours;

  /// Sleep quality score (1-5 scale, calculated)
  final int? sleepQuality;

  /// Average heart rate for the day
  final int? heartRateAvg;

  /// Minimum heart rate recorded
  final int? heartRateMin;

  /// Maximum heart rate recorded
  final int? heartRateMax;

  /// Average heart rate variability (HRV)
  final int? hrvAvg;

  /// Weather condition (e.g., "sunny", "cloudy", "rainy")
  final String? weatherCondition;

  /// Temperature in degrees
  final double? temperature;

  /// Humidity percentage
  final int? humidity;

  /// Dominant music genre listened to
  final String? musicGenre;

  /// Music energy level from Spotify API (0.0-1.0)
  final double? musicEnergy;

  /// Average music tempo in BPM
  final double? musicTempo;

  /// Total screen time in minutes
  final int? screenTimeMinutes;

  /// Total active minutes
  final int? activeMinutes;

  /// Total calories burned
  final double? caloriesBurned;

  /// Path to photo taken this day
  final String? photoPath;

  /// Colors extracted from photo
  final List<String>? photoColors;

  /// Timestamp when entry was created
  final DateTime createdAt;

  /// Timestamp when entry was last updated
  final DateTime updatedAt;

  // ============================================================================
  // CONSTRUCTORS
  // ============================================================================

  /// Main constructor
  const DailyEntry({
    required this.id,
    required this.date,
    required this.primaryColor,
    required this.createdAt,
    required this.updatedAt,
    this.secondaryColor,
    this.note,
    this.voiceNotePath,
    this.moodScore,
    this.energyScore,
    this.steps,
    this.sleepHours,
    this.sleepQuality,
    this.heartRateAvg,
    this.heartRateMin,
    this.heartRateMax,
    this.hrvAvg,
    this.weatherCondition,
    this.temperature,
    this.humidity,
    this.musicGenre,
    this.musicEnergy,
    this.musicTempo,
    this.screenTimeMinutes,
    this.activeMinutes,
    this.caloriesBurned,
    this.photoPath,
    this.photoColors,
  });

  /// Create a new entry with auto-generated ID and timestamps
  factory DailyEntry.create({
    required DateTime date,
    required String primaryColor,
    String? secondaryColor,
    String? note,
    String? voiceNotePath,
    int? moodScore,
    int? energyScore,
    int? steps,
    double? sleepHours,
    int? sleepQuality,
    int? heartRateAvg,
    int? heartRateMin,
    int? heartRateMax,
    int? hrvAvg,
    String? weatherCondition,
    double? temperature,
    int? humidity,
    String? musicGenre,
    double? musicEnergy,
    double? musicTempo,
    int? screenTimeMinutes,
    int? activeMinutes,
    double? caloriesBurned,
    String? photoPath,
    List<String>? photoColors,
  }) {
    final now = DateTime.now();
    return DailyEntry(
      id: const Uuid().v4(),
      date: date,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      note: note,
      voiceNotePath: voiceNotePath,
      moodScore: moodScore,
      energyScore: energyScore,
      steps: steps,
      sleepHours: sleepHours,
      sleepQuality: sleepQuality,
      heartRateAvg: heartRateAvg,
      heartRateMin: heartRateMin,
      heartRateMax: heartRateMax,
      hrvAvg: hrvAvg,
      weatherCondition: weatherCondition,
      temperature: temperature,
      humidity: humidity,
      musicGenre: musicGenre,
      musicEnergy: musicEnergy,
      musicTempo: musicTempo,
      screenTimeMinutes: screenTimeMinutes,
      activeMinutes: activeMinutes,
      caloriesBurned: caloriesBurned,
      photoPath: photoPath,
      photoColors: photoColors,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create an entry from a database map
  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      primaryColor: map['primaryColor'] as String,
      secondaryColor: map['secondaryColor'] as String?,
      note: map['note'] as String?,
      voiceNotePath: map['voiceNotePath'] as String?,
      moodScore: map['moodScore'] as int?,
      energyScore: map['energyScore'] as int?,
      steps: map['steps'] as int?,
      sleepHours: map['sleepHours'] as double?,
      sleepQuality: map['sleepQuality'] as int?,
      heartRateAvg: map['heartRateAvg'] as int?,
      heartRateMin: map['heartRateMin'] as int?,
      heartRateMax: map['heartRateMax'] as int?,
      hrvAvg: map['hrvAvg'] as int?,
      weatherCondition: map['weatherCondition'] as String?,
      temperature: map['temperature'] as double?,
      humidity: map['humidity'] as int?,
      musicGenre: map['musicGenre'] as String?,
      musicEnergy: map['musicEnergy'] as double?,
      musicTempo: map['musicTempo'] as double?,
      screenTimeMinutes: map['screenTimeMinutes'] as int?,
      activeMinutes: map['activeMinutes'] as int?,
      caloriesBurned: map['caloriesBurned'] as double?,
      photoPath: map['photoPath'] as String?,
      photoColors: map['photoColors'] != null
          ? (map['photoColors'] as String).split(',')
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // ============================================================================
  // METHODS
  // ============================================================================

  /// Convert entry to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'note': note,
      'voiceNotePath': voiceNotePath,
      'moodScore': moodScore,
      'energyScore': energyScore,
      'steps': steps,
      'sleepHours': sleepHours,
      'sleepQuality': sleepQuality,
      'heartRateAvg': heartRateAvg,
      'heartRateMin': heartRateMin,
      'heartRateMax': heartRateMax,
      'hrvAvg': hrvAvg,
      'weatherCondition': weatherCondition,
      'temperature': temperature,
      'humidity': humidity,
      'musicGenre': musicGenre,
      'musicEnergy': musicEnergy,
      'musicTempo': musicTempo,
      'screenTimeMinutes': screenTimeMinutes,
      'activeMinutes': activeMinutes,
      'caloriesBurned': caloriesBurned,
      'photoPath': photoPath,
      'photoColors': photoColors?.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this entry with updated fields
  /// Automatically updates the updatedAt timestamp
  DailyEntry copyWith({
    String? id,
    DateTime? date,
    String? primaryColor,
    String? secondaryColor,
    String? note,
    String? voiceNotePath,
    int? moodScore,
    int? energyScore,
    int? steps,
    double? sleepHours,
    int? sleepQuality,
    int? heartRateAvg,
    int? heartRateMin,
    int? heartRateMax,
    int? hrvAvg,
    String? weatherCondition,
    double? temperature,
    int? humidity,
    String? musicGenre,
    double? musicEnergy,
    double? musicTempo,
    int? screenTimeMinutes,
    int? activeMinutes,
    double? caloriesBurned,
    String? photoPath,
    List<String>? photoColors,
    DateTime? createdAt,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      note: note ?? this.note,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      moodScore: moodScore ?? this.moodScore,
      energyScore: energyScore ?? this.energyScore,
      steps: steps ?? this.steps,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateMin: heartRateMin ?? this.heartRateMin,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      hrvAvg: hrvAvg ?? this.hrvAvg,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      musicGenre: musicGenre ?? this.musicGenre,
      musicEnergy: musicEnergy ?? this.musicEnergy,
      musicTempo: musicTempo ?? this.musicTempo,
      screenTimeMinutes: screenTimeMinutes ?? this.screenTimeMinutes,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      photoPath: photoPath ?? this.photoPath,
      photoColors: photoColors ?? this.photoColors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Parse primary color hex string to Color
  Color get primaryColorValue {
    try {
      String hex = primaryColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }

  /// Parse secondary color hex string to Color (if exists)
  Color? get secondaryColorValue {
    if (secondaryColor == null) return null;
    try {
      String hex = secondaryColor!.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Returns true if any health data is present
  bool get hasHealthData {
    return steps != null ||
        sleepHours != null ||
        sleepQuality != null ||
        heartRateAvg != null ||
        heartRateMin != null ||
        heartRateMax != null ||
        hrvAvg != null ||
        activeMinutes != null ||
        caloriesBurned != null;
  }

  /// Returns true if any music data is present
  bool get hasMusicData {
    return musicGenre != null ||
        musicEnergy != null ||
        musicTempo != null;
  }

  /// Returns true if weather data is present
  bool get hasWeatherData {
    return weatherCondition != null;
  }

  // ============================================================================
  // EQUATABLE
  // ============================================================================

  @override
  List<Object?> get props => [
        id,
        date,
        primaryColor,
        secondaryColor,
        note,
        voiceNotePath,
        moodScore,
        energyScore,
        steps,
        sleepHours,
        sleepQuality,
        heartRateAvg,
        heartRateMin,
        heartRateMax,
        hrvAvg,
        weatherCondition,
        temperature,
        humidity,
        musicGenre,
        musicEnergy,
        musicTempo,
        screenTimeMinutes,
        activeMinutes,
        caloriesBurned,
        photoPath,
        photoColors,
        createdAt,
        updatedAt,
      ];
}
