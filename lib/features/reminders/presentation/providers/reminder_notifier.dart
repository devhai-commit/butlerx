import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../domain/entities/reminder.dart';

part 'reminder_notifier.g.dart';

final class ReminderState {
  const ReminderState({
    this.reminders = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Reminder> reminders;
  final bool isLoading;
  final String? error;

  List<Reminder> get active => reminders.where((r) => r.isActive).toList();
  List<Reminder> get upcoming =>
      active.where((r) => r.isUpcoming).toList();

  ReminderState copyWith({
    List<Reminder>? reminders,
    bool? isLoading,
    String? Function()? error,
  }) =>
      ReminderState(
        reminders: reminders ?? this.reminders,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );
}

@riverpod
class ReminderNotifier extends _$ReminderNotifier {
  static final _notifPlugin = FlutterLocalNotificationsPlugin();

  @override
  ReminderState build() {
    Future.microtask(_load);
    return const ReminderState();
  }

  String? get _uid {
    final auth = ref.read(authNotifierProvider);
    return auth is AuthAuthenticated ? auth.profile.uid : null;
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) return;
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final reminders =
          await ref.read(reminderRepositoryProvider).getAll(uid);
      state = state.copyWith(reminders: reminders, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    final saved =
        await ref.read(reminderRepositoryProvider).save(reminder);
    final updated = [...state.reminders, saved]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    state = state.copyWith(reminders: updated);
    if (saved.isActive) await _scheduleNotification(saved);
  }

  Future<void> toggleActive(String id) async {
    final idx = state.reminders.indexWhere((r) => r.id == id);
    if (idx < 0) return;
    final updated = state.reminders[idx]
        .copyWith(isActive: !state.reminders[idx].isActive);
    await ref.read(reminderRepositoryProvider).save(updated);
    final list = [...state.reminders];
    list[idx] = updated;
    state = state.copyWith(reminders: list);
    if (updated.isActive) {
      await _scheduleNotification(updated);
    } else {
      await _cancelNotification(updated);
    }
  }

  Future<void> deleteReminder(String id) async {
    final uid = _uid;
    if (uid == null) return;
    final reminder = state.reminders.firstWhere((r) => r.id == id);
    await _cancelNotification(reminder);
    await ref.read(reminderRepositoryProvider).delete(uid, id);
    state = state.copyWith(
      reminders: state.reminders.where((r) => r.id != id).toList(),
    );
  }

  void clearError() => state = state.copyWith(error: () => null);

  Future<void> _scheduleNotification(Reminder reminder) async {
    if (!reminder.scheduledAt.isAfter(DateTime.now())) return;
    try {
      await _notifPlugin.zonedSchedule(
        reminder.notificationId,
        'Nhắc nhở: ${reminder.title}',
        reminder.body ?? '',
        tz.TZDateTime.from(reminder.scheduledAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'butlerx_reminders',
            'Nhắc nhở',
            channelDescription: 'Thông báo nhắc nhở từ ButlerX',
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
    } catch (_) {
      // Notification scheduling may fail on some devices
    }
  }

  Future<void> _cancelNotification(Reminder reminder) async {
    try {
      await _notifPlugin.cancel(reminder.notificationId);
    } catch (_) {}
  }
}
