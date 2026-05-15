import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/entities/reminder.dart';

part 'reminder_repository.g.dart';

@riverpod
ReminderRepository reminderRepository(Ref ref) =>
    ReminderRepository(ref.watch(appDatabaseProvider));

final class ReminderRepository {
  ReminderRepository(this._db);

  final AppDatabase _db;

  Future<List<Reminder>> getAll(String userId) async {
    final rows = await _db.reminderDao.getAllForUser(userId);
    return rows.map(_rowToReminder).toList();
  }

  Future<List<Reminder>> getActive(String userId) async {
    final rows = await _db.reminderDao.getActiveForUser(userId);
    return rows.map(_rowToReminder).toList();
  }

  Future<Reminder> save(Reminder reminder) async {
    await _db.reminderDao.upsert(
      ReminderRow(
        id: reminder.id,
        userId: reminder.userId,
        title: reminder.title,
        body: reminder.body,
        scheduledAt: reminder.scheduledAt.millisecondsSinceEpoch,
        repeatRule: reminder.repeatRule.name,
        isActive: reminder.isActive,
        linkedAppointmentId: reminder.linkedAppointmentId,
        createdAt: reminder.createdAt.millisecondsSinceEpoch,
      ),
    );
    return reminder;
  }

  Future<void> delete(String userId, String id) =>
      _db.reminderDao.deleteById(userId, id);

  // ── Helpers ───────────────────────────────────────────────────────────────

  Reminder _rowToReminder(ReminderRow row) => Reminder(
        id: row.id,
        userId: row.userId,
        title: row.title,
        body: row.body,
        scheduledAt: DateTime.fromMillisecondsSinceEpoch(row.scheduledAt),
        repeatRule: RepeatRule.values.byName(row.repeatRule),
        isActive: row.isActive,
        linkedAppointmentId: row.linkedAppointmentId,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      );
}
