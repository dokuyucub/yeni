import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// JournalEntry - Represents a journal entry with text or voice content
/// Allows users to reflect on their day with optional mood tracking
class JournalEntry extends Equatable {
  /// Unique identifier for this entry
  final String id;

  /// Date of this journal entry
  final DateTime date;

  /// Optional prompt/question shown to the user
  final String? prompt;

  /// User's written response
  final String? content;

  /// Path to voice recording (if user recorded audio)
  final String? voicePath;

  /// Mood before writing (1-5 scale)
  final int? moodBefore;

  /// Mood after writing (1-5 scale)
  final int? moodAfter;

  /// Link to DailyEntry of the same day
  final String? linkedEntryId;

  /// User-added tags for organization
  final List<String>? tags;

  /// Timestamp when entry was created
  final DateTime createdAt;

  /// Timestamp when entry was last updated
  final DateTime updatedAt;

  // ============================================================================
  // CONSTRUCTORS
  // ============================================================================

  /// Main constructor
  const JournalEntry({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.prompt,
    this.content,
    this.voicePath,
    this.moodBefore,
    this.moodAfter,
    this.linkedEntryId,
    this.tags,
  });

  /// Create a new journal entry with auto-generated ID and timestamps
  factory JournalEntry.create({
    required DateTime date,
    String? prompt,
    String? content,
    String? voicePath,
    int? moodBefore,
    int? moodAfter,
    String? linkedEntryId,
    List<String>? tags,
  }) {
    final now = DateTime.now();
    return JournalEntry(
      id: const Uuid().v4(),
      date: date,
      prompt: prompt,
      content: content,
      voicePath: voicePath,
      moodBefore: moodBefore,
      moodAfter: moodAfter,
      linkedEntryId: linkedEntryId,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a journal entry from a database map
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      prompt: map['prompt'] as String?,
      content: map['content'] as String?,
      voicePath: map['voicePath'] as String?,
      moodBefore: map['moodBefore'] as int?,
      moodAfter: map['moodAfter'] as int?,
      linkedEntryId: map['linkedEntryId'] as String?,
      tags: map['tags'] != null
          ? (map['tags'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // ============================================================================
  // METHODS
  // ============================================================================

  /// Convert journal entry to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'prompt': prompt,
      'content': content,
      'voicePath': voicePath,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'linkedEntryId': linkedEntryId,
      'tags': tags?.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this entry with updated fields
  /// Automatically updates the updatedAt timestamp
  JournalEntry copyWith({
    String? id,
    DateTime? date,
    String? prompt,
    String? content,
    String? voicePath,
    int? moodBefore,
    int? moodAfter,
    String? linkedEntryId,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      prompt: prompt ?? this.prompt,
      content: content ?? this.content,
      voicePath: voicePath ?? this.voicePath,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      linkedEntryId: linkedEntryId ?? this.linkedEntryId,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Returns true if entry has written content
  bool get hasContent => content != null && content!.isNotEmpty;

  /// Returns true if entry has voice recording
  bool get hasVoice => voicePath != null;

  /// Returns the word count of the content
  int get wordCount {
    if (content == null || content!.isEmpty) return 0;
    return content!.split(' ').where((word) => word.isNotEmpty).length;
  }

  // ============================================================================
  // EQUATABLE
  // ============================================================================

  @override
  List<Object?> get props => [
        id,
        date,
        prompt,
        content,
        voicePath,
        moodBefore,
        moodAfter,
        linkedEntryId,
        tags,
        createdAt,
        updatedAt,
      ];
}
