import '../app_database.dart';

class ReminderDao {
  ReminderDao(this._db);

  final AppDatabase _db;

  Future<List<ReminderRow>> getAllForUser(String userId) async {
    final result = await _db.execute(
      'SELECT * FROM reminders WHERE user_id = @userId ORDER BY scheduled_at ASC',
      parameters: {'userId': userId},
    );
    return result.map((r) => ReminderRow.fromMap(r)).toList();
  }

  Future<List<ReminderRow>> getActiveForUser(String userId) async {
    final result = await _db.execute(
      'SELECT * FROM reminders WHERE user_id = @userId AND is_active = 1 ORDER BY scheduled_at ASC',
      parameters: {'userId': userId},
    );
    return result.map((r) => ReminderRow.fromMap(r)).toList();
  }

  Future<void> upsert(ReminderRow row) async {
    await _db.execute(
      '''
      INSERT INTO reminders (
        id, user_id, title, body, scheduled_at,
        repeat_rule, is_active, linked_appointment_id, created_at
      )
      VALUES (
        @id, @userId, @title, @body, @scheduledAt,
        @repeatRule, @isActive, @linkedAppointmentId, @createdAt
      )
      ON CONFLICT (id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        title = EXCLUDED.title,
        body = EXCLUDED.body,
        scheduled_at = EXCLUDED.scheduled_at,
        repeat_rule = EXCLUDED.repeat_rule,
        is_active = EXCLUDED.is_active,
        linked_appointment_id = EXCLUDED.linked_appointment_id,
        created_at = EXCLUDED.created_at
      ''',
      parameters: {
        'id': row.id,
        'userId': row.userId,
        'title': row.title,
        'body': row.body,
        'scheduledAt': row.scheduledAt,
        'repeatRule': row.repeatRule,
        'isActive': row.isActive,
        'linkedAppointmentId': row.linkedAppointmentId,
        'createdAt': row.createdAt,
      },
    );
  }

  Future<void> deleteById(String userId, String id) async {
    await _db.execute(
      'DELETE FROM reminders WHERE id = @id AND user_id = @userId',
      parameters: {'id': id, 'userId': userId},
    );
  }
}
