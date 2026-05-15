import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/agent/intent_classifier.dart';

part 'voice_intent_parser.g.dart';

final class ParsedAppointment {
  const ParsedAppointment({
    required this.title,
    required this.startAt,
    this.endAt,
    this.location,
    this.description,
  });

  final String title;
  final DateTime startAt;
  final DateTime? endAt;
  final String? location;
  final String? description;
}

@riverpod
VoiceIntentParser voiceIntentParser(Ref ref) =>
    VoiceIntentParser(ref.watch(intentClassifierProvider));

/// Parses Vietnamese voice transcripts into appointment data.
/// Delegates to [IntentClassifier] to reuse the shared GPT-4o-mini pipeline.
final class VoiceIntentParser {
  VoiceIntentParser(this._classifier);
  final IntentClassifier _classifier;

  Future<ParsedAppointment?> parse(String transcript) async {
    final result = await _classifier.classify(transcript);

    if (result.intent != AgentIntent.scheduleCreate) return null;

    final e = result.entities;
    final startRaw = e['startAt'] as String?;
    if (startRaw == null) return null;

    final startAt = DateTime.tryParse(startRaw);
    if (startAt == null) return null;

    final endRaw = e['endAt'] as String?;

    return ParsedAppointment(
      title: e['title'] as String? ?? 'Lịch hẹn',
      startAt: startAt,
      endAt: endRaw != null ? DateTime.tryParse(endRaw) : null,
      location: e['location'] as String?,
    );
  }
}
