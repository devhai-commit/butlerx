import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/health/domain/entities/health_record.dart';
import '../../features/health/presentation/providers/health_notifier.dart';
import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/presentation/providers/reminder_notifier.dart';
import '../../features/scheduling/domain/entities/appointment.dart';
import '../../features/scheduling/presentation/providers/schedule_notifier.dart';
import 'intent_classifier.dart';

final class ActionRouter {
  const ActionRouter(this._ref);
  final Ref _ref;

  String? get _uid {
    final auth = _ref.read(authNotifierProvider);
    return auth is AuthAuthenticated ? auth.profile.uid : null;
  }

  Future<String> route(IntentResult result) async {
    return switch (result.intent) {
      AgentIntent.scheduleCreate => await _createSchedule(result),
      AgentIntent.scheduleQuery => _querySchedule(result),
      AgentIntent.reminderCreate => await _createReminder(result),
      AgentIntent.healthLog => await _logHealth(result),
      AgentIntent.mealGenerate => result.responseText,
      AgentIntent.chat => result.responseText,
    };
  }

  Future<String> _createSchedule(IntentResult result) async {
    final uid = _uid;
    if (uid == null) return 'Vui lòng đăng nhập để đặt lịch.';

    final e = result.entities;
    final startRaw = e['startAt'] as String?;
    if (startRaw == null) return result.responseText;

    final startAt = DateTime.tryParse(startRaw);
    if (startAt == null) return result.responseText;

    final endRaw = e['endAt'] as String?;
    final appt = Appointment(
      userId: uid,
      title: e['title'] as String? ?? 'Lịch hẹn',
      startAt: startAt,
      endAt: endRaw != null ? DateTime.tryParse(endRaw) : null,
      location: e['location'] as String?,
      source: AppointmentSource.voice,
    );

    await _ref
        .read(scheduleNotifierProvider.notifier)
        .addAppointment(appt);
    return result.responseText;
  }

  String _querySchedule(IntentResult result) {
    final dateRaw = result.entities['date'] as String?;
    final date =
        dateRaw != null ? DateTime.tryParse(dateRaw) : DateTime.now();
    if (date == null) return result.responseText;

    final appointments =
        _ref.read(scheduleNotifierProvider).forDay(date);
    if (appointments.isEmpty) {
      return 'Ngày đó bạn không có lịch hẹn nào.';
    }
    final list = appointments.map((a) {
      final h = a.startAt.hour.toString().padLeft(2, '0');
      final m = a.startAt.minute.toString().padLeft(2, '0');
      return '$h:$m - ${a.title}';
    }).join(', ');
    return 'Lịch của bạn: $list.';
  }

  Future<String> _createReminder(IntentResult result) async {
    final uid = _uid;
    if (uid == null) return 'Vui lòng đăng nhập để đặt nhắc nhở.';

    final e = result.entities;
    final scheduledRaw = e['scheduledAt'] as String?;
    if (scheduledRaw == null) return result.responseText;

    final scheduledAt = DateTime.tryParse(scheduledRaw);
    if (scheduledAt == null) return result.responseText;

    final repeatStr = e['repeatRule'] as String? ?? 'none';
    final repeatRule = RepeatRule.values.byName(repeatStr);

    final reminder = Reminder(
      userId: uid,
      title: e['title'] as String? ?? 'Nhắc nhở',
      scheduledAt: scheduledAt,
      repeatRule: repeatRule,
    );

    await _ref
        .read(reminderNotifierProvider.notifier)
        .addReminder(reminder);
    return result.responseText;
  }

  Future<String> _logHealth(IntentResult result) async {
    final uid = _uid;
    if (uid == null) return 'Vui lòng đăng nhập để ghi chép sức khỏe.';

    final e = result.entities;
    final record = HealthRecord(
      userId: uid,
      recordedAt: DateTime.now(),
      weightKg: (e['weightKg'] as num?)?.toDouble(),
      heightCm: (e['heightCm'] as num?)?.toDouble(),
      bloodPressureSystolic: e['systolic'] as int?,
      bloodPressureDiastolic: e['diastolic'] as int?,
      heartRateBpm: e['heartRate'] as int?,
      bloodSugarMmol: (e['bloodSugar'] as num?)?.toDouble(),
    );

    await _ref.read(healthNotifierProvider.notifier).addRecord(record);
    return result.responseText;
  }
}
