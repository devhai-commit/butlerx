import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/appointment.dart';

part 'appointment_repository.g.dart';

@riverpod
AppointmentRepository appointmentRepository(Ref ref) =>
    AppointmentRepository();

final class AppointmentRepository {
  static const _kPrefix = 'appt_';
  static const _kListKey = 'appointments_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Appointment>> getAll(String userId) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList('$_kListKey$userId') ?? [];
    final result = <Appointment>[];
    for (final id in ids) {
      final raw = prefs.getString('$_kPrefix$id');
      if (raw != null) {
        result.add(Appointment.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      }
    }
    result.sort((a, b) => a.startAt.compareTo(b.startAt));
    return result;
  }

  Future<List<Appointment>> getUpcoming(String userId, {int limit = 20}) async {
    final all = await getAll(userId);
    final now = DateTime.now();
    return all.where((a) => a.startAt.isAfter(now)).take(limit).toList();
  }

  Future<List<Appointment>> getForDay(String userId, DateTime day) async {
    final all = await getAll(userId);
    return all.where((a) => _sameDay(a.startAt, day)).toList();
  }

  Future<Appointment> save(Appointment appt) async {
    final prefs = await _prefs;
    await prefs.setString('$_kPrefix${appt.id}', jsonEncode(appt.toJson()));
    final ids = prefs.getStringList('$_kListKey${appt.userId}') ?? [];
    if (!ids.contains(appt.id)) ids.add(appt.id);
    await prefs.setStringList('$_kListKey${appt.userId}', ids);
    return appt;
  }

  Future<void> delete(String userId, String id) async {
    final prefs = await _prefs;
    await prefs.remove('$_kPrefix$id');
    final ids = prefs.getStringList('$_kListKey$userId') ?? [];
    ids.remove(id);
    await prefs.setStringList('$_kListKey$userId', ids);
  }

  Future<Appointment?> getById(String id) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_kPrefix$id');
    if (raw == null) return null;
    return Appointment.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
