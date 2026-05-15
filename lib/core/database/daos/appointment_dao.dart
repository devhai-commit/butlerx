import '../app_database.dart';

class AppointmentDao {
  AppointmentDao(this._db);

  final AppDatabase _db;

  Future<List<AppointmentRow>> getAllForUser(String userId) async {
    final result = await _db.execute(
      'SELECT * FROM appointments WHERE user_id = @userId ORDER BY start_at ASC',
      parameters: {'userId': userId},
    );
    return result.map((r) => AppointmentRow.fromMap(r)).toList();
  }

  Future<List<AppointmentRow>> getUpcomingForUser(
    String userId,
    int nowMs, {
    int limit = 20,
  }) async {
    final result = await _db.execute(
      'SELECT * FROM appointments WHERE user_id = @userId AND start_at >= @nowMs ORDER BY start_at ASC LIMIT @limit',
      parameters: {'userId': userId, 'nowMs': nowMs, 'limit': limit},
    );
    return result.map((r) => AppointmentRow.fromMap(r)).toList();
  }

  Future<List<AppointmentRow>> getForDay(
    String userId,
    int dayStartMs,
    int dayEndMs,
  ) async {
    final result = await _db.execute(
      'SELECT * FROM appointments WHERE user_id = @userId AND start_at >= @dayStartMs AND start_at < @dayEndMs ORDER BY start_at ASC',
      parameters: {
        'userId': userId,
        'dayStartMs': dayStartMs,
        'dayEndMs': dayEndMs,
      },
    );
    return result.map((r) => AppointmentRow.fromMap(r)).toList();
  }

  Future<AppointmentRow?> getById(String id) async {
    final result = await _db.execute(
      'SELECT * FROM appointments WHERE id = @id',
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return AppointmentRow.fromMap(result.first);
  }

  Future<void> upsert(AppointmentRow row) async {
    await _db.execute(
      '''
      INSERT INTO appointments (
        id, user_id, title, start_at, end_at, description, location,
        reminder_offset, source, raw_transcript, created_at, updated_at, notification_id
      )
      VALUES (
        @id, @userId, @title, @startAt, @endAt, @description, @location,
        @reminderOffset, @source, @rawTranscript, @createdAt, @updatedAt, @notificationId
      )
      ON CONFLICT (id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        title = EXCLUDED.title,
        start_at = EXCLUDED.start_at,
        end_at = EXCLUDED.end_at,
        description = EXCLUDED.description,
        location = EXCLUDED.location,
        reminder_offset = EXCLUDED.reminder_offset,
        source = EXCLUDED.source,
        raw_transcript = EXCLUDED.raw_transcript,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at,
        notification_id = EXCLUDED.notification_id
      ''',
      parameters: {
        'id': row.id,
        'userId': row.userId,
        'title': row.title,
        'startAt': row.startAt,
        'endAt': row.endAt,
        'description': row.description,
        'location': row.location,
        'reminderOffset': row.reminderOffset,
        'source': row.source,
        'rawTranscript': row.rawTranscript,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'notificationId': row.notificationId,
      },
    );
  }

  Future<void> deleteById(String id) async {
    await _db.execute(
      'DELETE FROM appointments WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
