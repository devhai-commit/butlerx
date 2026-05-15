import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import 'daos/appointment_dao.dart';
import 'daos/conversation_dao.dart';
import 'daos/health_record_dao.dart';
import 'daos/reminder_dao.dart';

// ── Row types ──────────────────────────────────────────────────────────────────

class ConversationRow {
  const ConversationRow({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final int createdAt;
  final int? updatedAt;

  factory ConversationRow.fromMap(Map<String, dynamic> m) => ConversationRow(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        title: m['title'] as String,
        createdAt: m['created_at'] as int,
        updatedAt: m['updated_at'] as int?,
      );
}

class ChatMessageRow {
  const ChatMessageRow({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String role;
  final String content;
  final int createdAt;

  factory ChatMessageRow.fromMap(Map<String, dynamic> m) => ChatMessageRow(
        id: m['id'] as String,
        conversationId: m['conversation_id'] as String,
        role: m['role'] as String,
        content: m['content'] as String,
        createdAt: m['created_at'] as int,
      );
}

class AppointmentRow {
  const AppointmentRow({
    required this.id,
    required this.userId,
    required this.title,
    required this.startAt,
    this.endAt,
    this.description,
    this.location,
    required this.reminderOffset,
    required this.source,
    this.rawTranscript,
    required this.createdAt,
    required this.updatedAt,
    this.notificationId,
  });

  final String id;
  final String userId;
  final String title;
  final int startAt;
  final int? endAt;
  final String? description;
  final String? location;
  final int reminderOffset;
  final String source;
  final String? rawTranscript;
  final int createdAt;
  final int updatedAt;
  final int? notificationId;

  factory AppointmentRow.fromMap(Map<String, dynamic> m) => AppointmentRow(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        title: m['title'] as String,
        startAt: m['start_at'] as int,
        endAt: m['end_at'] as int?,
        description: m['description'] as String?,
        location: m['location'] as String?,
        reminderOffset: m['reminder_offset'] as int,
        source: m['source'] as String,
        rawTranscript: m['raw_transcript'] as String?,
        createdAt: m['created_at'] as int,
        updatedAt: m['updated_at'] as int,
        notificationId: m['notification_id'] as int?,
      );
}

class SpecialOccasionRow {
  const SpecialOccasionRow({
    required this.id,
    this.userId,
    required this.label,
    required this.month,
    required this.day,
    this.year,
    required this.category,
    required this.isLunar,
  });

  final String id;
  final String? userId;
  final String label;
  final int month;
  final int day;
  final int? year;
  final String category;
  final bool isLunar;

  factory SpecialOccasionRow.fromMap(Map<String, dynamic> m) =>
      SpecialOccasionRow(
        id: m['id'] as String,
        userId: m['user_id'] as String?,
        label: m['label'] as String,
        month: m['month'] as int,
        day: m['day'] as int,
        year: m['year'] as int?,
        category: m['category'] as String,
        isLunar: m['is_lunar'] == 1 || m['is_lunar'] == true,
      );
}

class HealthRecordRow {
  const HealthRecordRow({
    required this.id,
    required this.userId,
    required this.recordedAt,
    this.weightKg,
    this.heightCm,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRateBpm,
    this.bloodSugarMmol,
    this.notes,
  });

  final String id;
  final String userId;
  final int recordedAt;
  final double? weightKg;
  final double? heightCm;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRateBpm;
  final double? bloodSugarMmol;
  final String? notes;

  factory HealthRecordRow.fromMap(Map<String, dynamic> m) => HealthRecordRow(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        recordedAt: m['recorded_at'] as int,
        weightKg: (m['weight_kg'] as num?)?.toDouble(),
        heightCm: (m['height_cm'] as num?)?.toDouble(),
        bloodPressureSystolic: m['blood_pressure_systolic'] as int?,
        bloodPressureDiastolic: m['blood_pressure_diastolic'] as int?,
        heartRateBpm: m['heart_rate_bpm'] as int?,
        bloodSugarMmol: (m['blood_sugar_mmol'] as num?)?.toDouble(),
        notes: m['notes'] as String?,
      );
}

class ReminderRow {
  const ReminderRow({
    required this.id,
    required this.userId,
    required this.title,
    this.body,
    required this.scheduledAt,
    required this.repeatRule,
    required this.isActive,
    this.linkedAppointmentId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? body;
  final int scheduledAt;
  final String repeatRule;
  final bool isActive;
  final String? linkedAppointmentId;
  final int createdAt;

  factory ReminderRow.fromMap(Map<String, dynamic> m) => ReminderRow(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        title: m['title'] as String,
        body: m['body'] as String?,
        scheduledAt: m['scheduled_at'] as int,
        repeatRule: m['repeat_rule'] as String,
        isActive: m['is_active'] == 1 || m['is_active'] == true,
        linkedAppointmentId: m['linked_appointment_id'] as String?,
        createdAt: m['created_at'] as int,
      );
}

// ── Internal Drift backend (no typed tables — raw SQL only) ───────────────────

class _RawDb extends GeneratedDatabase {
  _RawDb(super.e);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => 1;
}

// ── Database ───────────────────────────────────────────────────────────────────

class AppDatabase {
  AppDatabase() {
    _db = _RawDb(_openExecutor());
    _initialized = _createSchema();
  }

  static QueryExecutor _openExecutor() {
    if (kIsWeb) {
      return driftDatabase(
        name: 'butlerx',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
    }
    return driftDatabase(name: 'butlerx');
  }

  late final _RawDb _db;
  late final Future<void> _initialized;

  late final ConversationDao conversationDao = ConversationDao(this);
  late final AppointmentDao appointmentDao = AppointmentDao(this);
  late final HealthRecordDao healthRecordDao = HealthRecordDao(this);
  late final ReminderDao reminderDao = ReminderDao(this);

  Future<void> _createSchema() async {
    await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS conversations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');
    await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL
          REFERENCES conversations(id) ON DELETE CASCADE,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS appointments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        start_at INTEGER NOT NULL,
        end_at INTEGER,
        description TEXT,
        location TEXT,
        reminder_offset INTEGER NOT NULL,
        source TEXT NOT NULL,
        raw_transcript TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        notification_id INTEGER
      )
    ''');
    await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS special_occasions (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        label TEXT NOT NULL,
        month INTEGER NOT NULL,
        day INTEGER NOT NULL,
        year INTEGER,
        category TEXT NOT NULL,
        is_lunar INTEGER NOT NULL
      )
    ''');
    await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS health_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        recorded_at INTEGER NOT NULL,
        weight_kg REAL,
        height_cm REAL,
        blood_pressure_systolic INTEGER,
        blood_pressure_diastolic INTEGER,
        heart_rate_bpm INTEGER,
        blood_sugar_mmol REAL,
        notes TEXT
      )
    ''');
    await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS reminders (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT,
        scheduled_at INTEGER NOT NULL,
        repeat_rule TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        linked_appointment_id TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  /// Executes a SQL statement. Named parameters use @name syntax.
  /// Returns rows for SELECT queries; empty list for mutations.
  Future<List<Map<String, dynamic>>> execute(
    String sql, {
    Map<String, Object?>? parameters,
  }) async {
    await _initialized;
    final (convertedSql, args) = _convertNamedParams(sql, parameters);
    if (sql.trimLeft().toUpperCase().startsWith('SELECT')) {
      final rows = await _db
          .customSelect(
            convertedSql,
            variables: args.map((v) => Variable<Object>(v)).toList(),
          )
          .get();
      return rows.map((r) => r.data).toList();
    }
    await _db.customStatement(convertedSql, args);
    return const [];
  }

  /// Converts @name parameters to positional ? and builds the args list.
  static (String, List<Object?>) _convertNamedParams(
    String sql,
    Map<String, Object?>? params,
  ) {
    if (params == null || params.isEmpty) return (sql, const []);
    final args = <Object?>[];
    final converted = sql.replaceAllMapped(
      RegExp(r'@(\w+)'),
      (m) {
        final v = params[m.group(1)!];
        // SQLite stores booleans as 0/1
        args.add(v is bool ? (v ? 1 : 0) : v);
        return '?';
      },
    );
    return (converted, args);
  }

  Future<void> close() async {
    try {
      await _db.close();
    } on Exception {
      // Connection may not have been established
    }
  }
}
