import 'package:uuid/uuid.dart';

final class HealthRecord {
  HealthRecord({
    String? id,
    required this.userId,
    required this.recordedAt,
    this.weightKg,
    this.heightCm,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRateBpm,
    this.bloodSugarMmol,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String userId;
  final DateTime recordedAt;
  final double? weightKg;
  final double? heightCm;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRateBpm;
  final double? bloodSugarMmol;
  final String? notes;

  double? get bmi {
    if (weightKg == null || heightCm == null || heightCm! <= 0) return null;
    final hm = heightCm! / 100;
    return weightKg! / (hm * hm);
  }

  String? get bmiLabel {
    final b = bmi;
    if (b == null) return null;
    return switch (b) {
      < 18.5 => 'Thiếu cân',
      < 25.0 => 'Bình thường',
      < 30.0 => 'Thừa cân',
      _ => 'Béo phì',
    };
  }

  String? get bloodPressureLabel {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return null;
    }
    final s = bloodPressureSystolic!;
    final d = bloodPressureDiastolic!;
    if (s < 120 && d < 80) return 'Bình thường';
    if (s < 130 && d < 80) return 'Huyết áp cao nhẹ';
    if (s < 140 || d < 90) return 'Tăng huyết áp độ 1';
    return 'Tăng huyết áp độ 2';
  }

  HealthRecord copyWith({
    DateTime? recordedAt,
    double? weightKg,
    double? heightCm,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRateBpm,
    double? bloodSugarMmol,
    String? notes,
  }) =>
      HealthRecord(
        id: id,
        userId: userId,
        recordedAt: recordedAt ?? this.recordedAt,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        bloodPressureSystolic:
            bloodPressureSystolic ?? this.bloodPressureSystolic,
        bloodPressureDiastolic:
            bloodPressureDiastolic ?? this.bloodPressureDiastolic,
        heartRateBpm: heartRateBpm ?? this.heartRateBpm,
        bloodSugarMmol: bloodSugarMmol ?? this.bloodSugarMmol,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'recordedAt': recordedAt.toIso8601String(),
        'weightKg': weightKg,
        'heightCm': heightCm,
        'bloodPressureSystolic': bloodPressureSystolic,
        'bloodPressureDiastolic': bloodPressureDiastolic,
        'heartRateBpm': heartRateBpm,
        'bloodSugarMmol': bloodSugarMmol,
        'notes': notes,
      };

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        id: json['id'] as String,
        userId: json['userId'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        bloodPressureSystolic: json['bloodPressureSystolic'] as int?,
        bloodPressureDiastolic: json['bloodPressureDiastolic'] as int?,
        heartRateBpm: json['heartRateBpm'] as int?,
        bloodSugarMmol: (json['bloodSugarMmol'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HealthRecord && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
