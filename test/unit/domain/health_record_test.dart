import 'package:flutter_test/flutter_test.dart';

import 'package:butlerx/features/health/domain/entities/health_record.dart';

void main() {
  group('HealthRecord', () {
    late HealthRecord full;

    setUp(() {
      full = HealthRecord(
        userId: 'u1',
        recordedAt: DateTime(2026, 4, 20, 9, 0),
        weightKg: 70.0,
        heightCm: 170.0,
        bloodPressureSystolic: 118,
        bloodPressureDiastolic: 78,
        heartRateBpm: 72,
        bloodSugarMmol: 5.2,
        notes: 'Cảm thấy khoẻ',
      );
    });

    test('generates a non-empty id when none provided', () {
      expect(full.id, isNotEmpty);
    });

    group('bmi', () {
      test('computes correctly for 70kg / 170cm', () {
        final bmi = full.bmi;
        expect(bmi, isNotNull);
        expect(bmi!, closeTo(24.22, 0.1));
      });

      test('returns null when weight is missing', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now(), heightCm: 170);
        expect(r.bmi, isNull);
      });

      test('returns null when height is missing', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now(), weightKg: 70);
        expect(r.bmi, isNull);
      });

      test('returns null when height is zero', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now(), weightKg: 70, heightCm: 0);
        expect(r.bmi, isNull);
      });
    });

    group('bmiLabel', () {
      test('Thiếu cân for BMI < 18.5', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now(), weightKg: 45, heightCm: 170);
        expect(r.bmiLabel, equals('Thiếu cân'));
      });

      test('Bình thường for BMI 18.5–24.9', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now(), weightKg: 60, heightCm: 170);
        expect(r.bmiLabel, equals('Bình thường'));
      });

      test('Thừa cân for BMI 25–29.9', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now(), weightKg: 75, heightCm: 170);
        expect(r.bmiLabel, equals('Thừa cân'));
      });

      test('Béo phì for BMI >= 30', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now(), weightKg: 90, heightCm: 170);
        expect(r.bmiLabel, equals('Béo phì'));
      });

      test('returns null when bmi is null', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now());
        expect(r.bmiLabel, isNull);
      });
    });

    group('bloodPressureLabel', () {
      test('Bình thường for systolic < 120 and diastolic < 80', () {
        expect(full.bloodPressureLabel, equals('Bình thường'));
      });

      test('Huyết áp cao nhẹ for 120–129 / < 80', () {
        final r = HealthRecord(
            userId: 'u',
            recordedAt: DateTime.now(),
            bloodPressureSystolic: 125,
            bloodPressureDiastolic: 75);
        expect(r.bloodPressureLabel, equals('Huyết áp cao nhẹ'));
      });

      test('Tăng huyết áp độ 2 for >= 140 / >= 90', () {
        final r = HealthRecord(
            userId: 'u',
            recordedAt: DateTime.now(),
            bloodPressureSystolic: 145,
            bloodPressureDiastolic: 92);
        expect(r.bloodPressureLabel, equals('Tăng huyết áp độ 2'));
      });

      test('returns null when blood pressure is missing', () {
        final r = HealthRecord(userId: 'u', recordedAt: DateTime.now());
        expect(r.bloodPressureLabel, isNull);
      });
    });

    test('copyWith preserves unchanged fields', () {
      final updated = full.copyWith(weightKg: 68.5);
      expect(updated.id, equals(full.id));
      expect(updated.userId, equals(full.userId));
      expect(updated.weightKg, equals(68.5));
      expect(updated.heightCm, equals(full.heightCm));
      expect(updated.notes, equals(full.notes));
    });

    test('toJson / fromJson round-trips correctly', () {
      final json = full.toJson();
      final restored = HealthRecord.fromJson(json);
      expect(restored.id, equals(full.id));
      expect(restored.userId, equals(full.userId));
      expect(restored.weightKg, equals(full.weightKg));
      expect(restored.heightCm, equals(full.heightCm));
      expect(restored.bloodPressureSystolic, equals(full.bloodPressureSystolic));
      expect(restored.heartRateBpm, equals(full.heartRateBpm));
      expect(restored.bloodSugarMmol, equals(full.bloodSugarMmol));
      expect(restored.notes, equals(full.notes));
    });

    test('toJson handles null optional fields', () {
      final r = HealthRecord(userId: 'u', recordedAt: DateTime.now());
      final json = r.toJson();
      expect(json['weightKg'], isNull);
      expect(json['heightCm'], isNull);
      expect(json['notes'], isNull);
    });

    test('equality based on id', () {
      expect(full, equals(full));
      final other = HealthRecord(userId: 'u1', recordedAt: DateTime.now());
      expect(full, isNot(equals(other)));
    });
  });
}
