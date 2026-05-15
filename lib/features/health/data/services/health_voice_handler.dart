import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/agent/intent_classifier.dart';
import '../../domain/entities/health_record.dart';

final healthVoiceHandlerProvider = Provider<HealthVoiceHandler>((ref) {
  return HealthVoiceHandler(ref.watch(intentClassifierProvider));
});

/// Parses free-form Vietnamese voice input into a [HealthRecord].
///
/// Example inputs:
/// - "Cân nặng hôm nay 68 kg"
/// - "Huyết áp 120/80, nhịp tim 72"
/// - "Đường huyết 5.8, cân 70 kg"
final class HealthVoiceHandler {
  const HealthVoiceHandler(this._classifier);
  final IntentClassifier _classifier;

  Future<HealthRecord?> parse(String transcript, String userId) async {
    final result = await _classifier.classify(transcript);
    if (result.intent != AgentIntent.healthLog) return null;

    final e = result.entities;
    final hasData = e['weightKg'] != null ||
        e['systolic'] != null ||
        e['heartRate'] != null ||
        e['bloodSugar'] != null ||
        e['heightCm'] != null;

    if (!hasData) return null;

    return HealthRecord(
      userId: userId,
      recordedAt: DateTime.now(),
      weightKg: (e['weightKg'] as num?)?.toDouble(),
      heightCm: (e['heightCm'] as num?)?.toDouble(),
      bloodPressureSystolic: e['systolic'] as int?,
      bloodPressureDiastolic: e['diastolic'] as int?,
      heartRateBpm: e['heartRate'] as int?,
      bloodSugarMmol: (e['bloodSugar'] as num?)?.toDouble(),
    );
  }

  /// Returns the Vietnamese confirmation text from the classifier.
  Future<String?> parseWithResponse(
    String transcript,
    String userId,
  ) async {
    final result = await _classifier.classify(transcript);
    if (result.intent != AgentIntent.healthLog) return null;

    final e = result.entities;
    final hasData = e['weightKg'] != null ||
        e['systolic'] != null ||
        e['heartRate'] != null ||
        e['bloodSugar'] != null ||
        e['heightCm'] != null;

    if (!hasData) return null;
    return result.responseText;
  }
}
