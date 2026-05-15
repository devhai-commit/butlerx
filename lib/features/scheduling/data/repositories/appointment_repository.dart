import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/entities/appointment.dart';

part 'appointment_repository.g.dart';

@riverpod
AppointmentRepository appointmentRepository(Ref ref) =>
    AppointmentRepository(ref.watch(appDatabaseProvider));

final class AppointmentRepository {
  AppointmentRepository(this._db);

  final AppDatabase _db;

  Future<List<Appointment>> getAll(String userId) async {
    final rows = await _db.appointmentDao.getAllForUser(userId);
    return rows.map(_rowToAppointment).toList();
  }

  Future<List<Appointment>> getUpcoming(
    String userId, {
    int limit = 20,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final rows = await _db.appointmentDao
        .getUpcomingForUser(userId, nowMs, limit: limit);
    return rows.map(_rowToAppointment).toList();
  }

  Future<List<Appointment>> getForDay(String userId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await _db.appointmentDao.getForDay(
      userId,
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
    return rows.map(_rowToAppointment).toList();
  }

  Future<Appointment?> getById(String id) async {
    final row = await _db.appointmentDao.getById(id);
    return row != null ? _rowToAppointment(row) : null;
  }

  Future<Appointment> save(Appointment appt) async {
    await _db.appointmentDao.upsert(
      AppointmentRow(
        id: appt.id,
        userId: appt.userId,
        title: appt.title,
        startAt: appt.startAt.millisecondsSinceEpoch,
        endAt: appt.endAt?.millisecondsSinceEpoch,
        description: appt.description,
        location: appt.location,
        reminderOffset: appt.reminderOffset.minutes,
        source: appt.source.name,
        rawTranscript: appt.rawTranscript,
        createdAt: appt.createdAt.millisecondsSinceEpoch,
        updatedAt: appt.updatedAt.millisecondsSinceEpoch,
        notificationId: appt.notificationId,
      ),
    );
    return appt;
  }

  Future<void> delete(String userId, String id) =>
      _db.appointmentDao.deleteById(id);

  // ── Helpers ───────────────────────────────────────────────────────────────

  Appointment _rowToAppointment(AppointmentRow row) => Appointment(
        id: row.id,
        userId: row.userId,
        title: row.title,
        startAt: DateTime.fromMillisecondsSinceEpoch(row.startAt),
        endAt: row.endAt != null
            ? DateTime.fromMillisecondsSinceEpoch(row.endAt!)
            : null,
        description: row.description,
        location: row.location,
        reminderOffset: ReminderOffset.values.firstWhere(
          (r) => r.minutes == row.reminderOffset,
          orElse: () => ReminderOffset.fifteenMin,
        ),
        source: AppointmentSource.values.byName(row.source),
        rawTranscript: row.rawTranscript,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
        notificationId: row.notificationId,
      );
}
