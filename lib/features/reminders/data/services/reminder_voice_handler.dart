import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/agent/intent_classifier.dart';
import '../../domain/entities/reminder.dart';

final reminderVoiceHandlerProvider = Provider<ReminderVoiceHandler>((ref) {
  return ReminderVoiceHandler(ref.watch(intentClassifierProvider));
});

/// Parses free-form Vietnamese voice input into a [Reminder].
///
/// Example inputs:
/// - "Nhắc tôi uống thuốc lúc 8 giờ sáng"
/// - "Đặt nhắc nhở họp lúc 2 giờ chiều mai"
/// - "Nhắc uống nước mỗi ngày lúc 7 giờ sáng"
final class ReminderVoiceHandler {
  const ReminderVoiceHandler(this._classifier);
  final IntentClassifier _classifier;

  Future<({Reminder reminder, String responseText})?> parse(
    String transcript,
    String userId,
  ) async {
    final result = await _classifier.classify(transcript);
    if (result.intent != AgentIntent.reminderCreate) return null;

    final e = result.entities;
    final scheduledRaw = e['scheduledAt'] as String?;
    if (scheduledRaw == null) return null;

    final scheduledAt = DateTime.tryParse(scheduledRaw);
    if (scheduledAt == null) return null;

    final repeatStr = e['repeatRule'] as String? ?? 'none';
    final repeatRule = RepeatRule.values.byName(repeatStr);

    final reminder = Reminder(
      userId: userId,
      title: e['title'] as String? ?? 'Nhắc nhở',
      scheduledAt: scheduledAt,
      repeatRule: repeatRule,
    );

    return (reminder: reminder, responseText: result.responseText);
  }
}
