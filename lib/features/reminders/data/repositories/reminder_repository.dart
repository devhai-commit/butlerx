import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/reminder.dart';

part 'reminder_repository.g.dart';

@riverpod
ReminderRepository reminderRepository(Ref ref) => ReminderRepository();

final class ReminderRepository {
  static const _kPrefix = 'reminder_';
  static const _kListKey = 'reminders_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Reminder>> getAll(String userId) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList('$_kListKey$userId') ?? [];
    final result = <Reminder>[];
    for (final id in ids) {
      final raw = prefs.getString('$_kPrefix$id');
      if (raw != null) {
        result.add(
            Reminder.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      }
    }
    result.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result;
  }

  Future<List<Reminder>> getActive(String userId) async {
    final all = await getAll(userId);
    return all.where((r) => r.isActive).toList();
  }

  Future<Reminder> save(Reminder reminder) async {
    final prefs = await _prefs;
    await prefs.setString(
        '$_kPrefix${reminder.id}', jsonEncode(reminder.toJson()));
    final ids = prefs.getStringList('$_kListKey${reminder.userId}') ?? [];
    if (!ids.contains(reminder.id)) ids.add(reminder.id);
    await prefs.setStringList('$_kListKey${reminder.userId}', ids);
    return reminder;
  }

  Future<void> delete(String userId, String id) async {
    final prefs = await _prefs;
    await prefs.remove('$_kPrefix$id');
    final ids = prefs.getStringList('$_kListKey$userId') ?? [];
    ids.remove(id);
    await prefs.setStringList('$_kListKey$userId', ids);
  }
}
