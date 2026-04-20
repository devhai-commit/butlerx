import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/appointment.dart';

part 'reminder_service.g.dart';

@riverpod
ReminderService reminderService(Ref ref) => ReminderService();

final class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<void> scheduleReminder(Appointment appt) async {
    await initialize();
    final fireAt = appt.reminderFireAt;
    if (!fireAt.isAfter(DateTime.now())) return;

    final notifId = appt.notificationId ?? appt.id.hashCode.abs() % 100000;

    await _plugin.zonedSchedule(
      notifId,
      'Nhắc nhở: ${appt.title}',
      _buildBody(appt),
      tz.TZDateTime.from(fireAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'butlerx_reminders',
          'Nhắc nhở lịch hẹn',
          channelDescription: 'Thông báo nhắc nhở lịch hẹn từ ButlerX',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int notifId) async {
    await initialize();
    await _plugin.cancel(notifId);
  }

  Future<void> cancelForAppointment(Appointment appt) async {
    final id = appt.notificationId ?? appt.id.hashCode.abs() % 100000;
    await cancelReminder(id);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  String _buildBody(Appointment appt) {
    final time =
        '${appt.startAt.hour.toString().padLeft(2, '0')}:${appt.startAt.minute.toString().padLeft(2, '0')}';
    final offset = appt.reminderOffset;
    final prefix = offset == ReminderOffset.atTime
        ? 'Bây giờ'
        : '${offset.label} —';
    final location =
        appt.location != null ? ' tại ${appt.location}' : '';
    return '$prefix $time$location';
  }
}
