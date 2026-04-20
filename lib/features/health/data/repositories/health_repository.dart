import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/health_record.dart';

part 'health_repository.g.dart';

@riverpod
HealthRepository healthRepository(Ref ref) => HealthRepository();

final class HealthRepository {
  static const _kPrefix = 'health_';
  static const _kListKey = 'health_records_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<HealthRecord>> getAll(String userId) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList('$_kListKey$userId') ?? [];
    final result = <HealthRecord>[];
    for (final id in ids) {
      final raw = prefs.getString('$_kPrefix$id');
      if (raw != null) {
        result.add(
            HealthRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      }
    }
    result.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return result;
  }

  Future<HealthRecord?> getLatest(String userId) async {
    final all = await getAll(userId);
    return all.firstOrNull;
  }

  Future<HealthRecord> save(HealthRecord record) async {
    final prefs = await _prefs;
    await prefs.setString(
        '$_kPrefix${record.id}', jsonEncode(record.toJson()));
    final ids = prefs.getStringList('$_kListKey${record.userId}') ?? [];
    if (!ids.contains(record.id)) ids.add(record.id);
    await prefs.setStringList('$_kListKey${record.userId}', ids);
    return record;
  }

  Future<void> delete(String userId, String id) async {
    final prefs = await _prefs;
    await prefs.remove('$_kPrefix$id');
    final ids = prefs.getStringList('$_kListKey$userId') ?? [];
    ids.remove(id);
    await prefs.setStringList('$_kListKey$userId', ids);
  }
}
