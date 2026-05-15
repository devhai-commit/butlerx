import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/entities/health_record.dart';

part 'health_repository.g.dart';

@riverpod
HealthRepository healthRepository(Ref ref) =>
    HealthRepository(ref.watch(appDatabaseProvider));

final class HealthRepository {
  HealthRepository(this._db);

  final AppDatabase _db;

  Future<List<HealthRecord>> getAll(String userId) async {
    final rows = await _db.healthRecordDao.getAllForUser(userId);
    return rows.map(_rowToRecord).toList();
  }

  Future<HealthRecord?> getLatest(String userId) async {
    final row = await _db.healthRecordDao.getLatestForUser(userId);
    return row != null ? _rowToRecord(row) : null;
  }

  Future<HealthRecord> save(HealthRecord record) async {
    await _db.healthRecordDao.upsert(
      HealthRecordRow(
        id: record.id,
        userId: record.userId,
        recordedAt: record.recordedAt.millisecondsSinceEpoch,
        weightKg: record.weightKg,
        heightCm: record.heightCm,
        bloodPressureSystolic: record.bloodPressureSystolic,
        bloodPressureDiastolic: record.bloodPressureDiastolic,
        heartRateBpm: record.heartRateBpm,
        bloodSugarMmol: record.bloodSugarMmol,
        notes: record.notes,
      ),
    );
    return record;
  }

  Future<void> delete(String userId, String id) =>
      _db.healthRecordDao.deleteById(userId, id);

  // ── Helpers ───────────────────────────────────────────────────────────────

  HealthRecord _rowToRecord(HealthRecordRow row) => HealthRecord(
        id: row.id,
        userId: row.userId,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(row.recordedAt),
        weightKg: row.weightKg,
        heightCm: row.heightCm,
        bloodPressureSystolic: row.bloodPressureSystolic,
        bloodPressureDiastolic: row.bloodPressureDiastolic,
        heartRateBpm: row.heartRateBpm,
        bloodSugarMmol: row.bloodSugarMmol,
        notes: row.notes,
      );
}
