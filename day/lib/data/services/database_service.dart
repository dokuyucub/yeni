import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/models.dart';

/// DatabaseService - Manages SQLite database for Day app
/// Singleton class that handles database initialization and operations
class DatabaseService {
  // Private constructor
  DatabaseService._();

  // Singleton instance
  static final DatabaseService instance = DatabaseService._();

  // Factory constructor returns singleton instance
  factory DatabaseService() => instance;

  // Database instance
  Database? _database;

  // ============================================================================
  // GETTER
  // ============================================================================

  /// Returns the database instance, initializing it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize the database
  Future<Database> _initDatabase() async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create the database path
    final path = join(directory.path, 'day_database.db');

    // Open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create all database tables
  Future<void> _onCreate(Database db, int version) async {
    // ========================================================================
    // DAILY ENTRIES TABLE
    // ========================================================================
    await db.execute('''
      CREATE TABLE daily_entries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        primary_color TEXT NOT NULL,
        secondary_color TEXT,
        note TEXT,
        voice_note_path TEXT,
        mood_score INTEGER,
        energy_score INTEGER,
        steps INTEGER,
        sleep_hours REAL,
        sleep_quality INTEGER,
        heart_rate_avg INTEGER,
        heart_rate_min INTEGER,
        heart_rate_max INTEGER,
        hrv_avg INTEGER,
        weather_condition TEXT,
        temperature REAL,
        humidity INTEGER,
        music_genre TEXT,
        music_energy REAL,
        music_tempo REAL,
        screen_time_minutes INTEGER,
        active_minutes INTEGER,
        calories_burned REAL,
        photo_path TEXT,
        photo_colors TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ========================================================================
    // ARTWORKS TABLE
    // ========================================================================
    await db.execute('''
      CREATE TABLE artworks (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        entry_ids TEXT NOT NULL,
        type TEXT NOT NULL,
        visualization_mode TEXT NOT NULL,
        image_path TEXT,
        thumbnail_path TEXT,
        image_url TEXT,
        thumbnail_url TEXT,
        color_palette TEXT NOT NULL,
        dominant_color TEXT,
        title TEXT,
        description TEXT,
        geography_match TEXT,
        painter_match TEXT,
        movement_match TEXT,
        season_match TEXT,
        element_match TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_public INTEGER NOT NULL DEFAULT 0,
        appreciation_count INTEGER NOT NULL DEFAULT 0,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // ========================================================================
    // JOURNAL ENTRIES TABLE
    // ========================================================================
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        prompt TEXT,
        content TEXT,
        voice_path TEXT,
        mood_before INTEGER,
        mood_after INTEGER,
        linked_entry_id TEXT,
        tags TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ========================================================================
    // COLLECTIONS TABLE
    // ========================================================================
    await db.execute('''
      CREATE TABLE collections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        artwork_ids TEXT NOT NULL,
        cover_artwork_id TEXT,
        icon_name TEXT,
        color_hex TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ========================================================================
    // USER BADGES TABLE
    // ========================================================================
    await db.execute('''
      CREATE TABLE user_badges (
        id TEXT PRIMARY KEY,
        badge_id TEXT NOT NULL,
        unlocked_at TEXT NOT NULL,
        progress INTEGER,
        target INTEGER
      )
    ''');

    // ========================================================================
    // USER PROFILE TABLE
    // ========================================================================
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        email TEXT,
        display_name TEXT,
        avatar_url TEXT,
        avatar_artwork_id TEXT,
        is_premium INTEGER NOT NULL DEFAULT 0,
        premium_expires_at TEXT,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        total_entries INTEGER NOT NULL DEFAULT 0,
        total_artworks INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        last_entry_at TEXT,
        timezone TEXT,
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        notification_time TEXT,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        analytics_enabled INTEGER NOT NULL DEFAULT 1,
        has_completed_onboarding INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ========================================================================
    // INDEXES
    // ========================================================================

    // Index for querying entries by date
    await db.execute('''
      CREATE INDEX idx_entries_date ON daily_entries(date)
    ''');

    // Index for querying artworks by creation date
    await db.execute('''
      CREATE INDEX idx_artworks_created ON artworks(created_at)
    ''');

    // Index for querying journal entries by date
    await db.execute('''
      CREATE INDEX idx_journals_date ON journal_entries(date)
    ''');
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
