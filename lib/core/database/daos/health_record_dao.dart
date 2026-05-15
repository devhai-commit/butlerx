import '../app_database.dart';

class HealthRecordDao {
  HealthRecordDao(this._db);

  final AppDatabase _db;

  Future<List<HealthRecordRow>> getAllForUser(String userId) async {
    final result = await _db.execute(
      'SELECT * FROM health_records WHERE user_id = @userId ORDER BY recorded_at DESC',
      parameters: {'userId': userId},
    );
    return result.map((r) => HealthRecordRow.fromMap(r)).toList();
  }

  Future<HealthRecordRow?> getLatestForUser(String userId) async {
    final result = await _db.execute(
      'SELECT * FROM health_records WHERE user_id = @userId ORDER BY recorded_at DESC LIMIT 1',
      parameters: {'userId': userId},
    );
    if (result.isEmpty) return null;
    return HealthRecordRow.fromMap(result.first);
  }

  Future<void> upsert(HealthRecordRow row) async {
    await _db.execute(
      '''
      INSERT INTO health_records (
        id, user_id, recorded_at, weight_kg, height_cm,
        blood_pressure_systolic, blood_pressure_diastolic,
        heart_rate_bpm, blood_sugar_mmol, notes
      )
      VALUES (
        @id, @userId, @recordedAt, @weightKg, @heightCm,
        @bloodPressureSystolic, @bloodPressureDiastolic,
        @heartRateBpm, @bloodSugarMmol, @notes
      )
      ON CONFLICT (id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        recorded_at = EXCLUDED.recorded_at,
        weight_kg = EXCLUDED.weight_kg,
        height_cm = EXCLUDED.height_cm,
        blood_pressure_systolic = EXCLUDED.blood_pressure_systolic,
        blood_pressure_diastolic = EXCLUDED.blood_pressure_diastolic,
        heart_rate_bpm = EXCLUDED.heart_rate_bpm,
        blood_sugar_mmol = EXCLUDED.blood_sugar_mmol,
        notes = EXCLUDED.notes
      ''',
      parameters: {
        'id': row.id,
        'userId': row.userId,
        'recordedAt': row.recordedAt,
        'weightKg': row.weightKg,
        'heightCm': row.heightCm,
        'bloodPressureSystolic': row.bloodPressureSystolic,
        'bloodPressureDiastolic': row.bloodPressureDiastolic,
        'heartRateBpm': row.heartRateBpm,
        'bloodSugarMmol': row.bloodSugarMmol,
        'notes': row.notes,
      },
    );
  }

  Future<void> deleteById(String userId, String id) async {
    await _db.execute(
      'DELETE FROM health_records WHERE id = @id AND user_id = @userId',
      parameters: {'id': id, 'userId': userId},
    );
  }
}
