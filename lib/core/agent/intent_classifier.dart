import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../features/chat/data/services/openai_service.dart';

enum AgentIntent {
  chat,
  scheduleCreate,
  scheduleQuery,
  reminderCreate,
  healthLog,
  mealGenerate,
}

final class IntentResult {
  const IntentResult({
    required this.intent,
    required this.entities,
    required this.responseText,
    this.confidence = 1.0,
  });

  final AgentIntent intent;
  final Map<String, dynamic> entities;
  final String responseText;
  final double confidence;
}

final intentClassifierProvider = Provider<IntentClassifier>((ref) {
  return IntentClassifier(ref.watch(openAiServiceProvider));
});

final class IntentClassifier {
  const IntentClassifier(this._openAi);
  final OpenAiService _openAi;

  Future<IntentResult> classify(String transcript) async {
    final key = await _openAi.getApiKey();
    if (key == null || key.isEmpty) {
      throw const ValidationException(
          'Cần API key để phân tích. Vào Cài đặt để thêm.');
    }
    OpenAI.apiKey = key;

    final now = DateTime.now();
    final systemPrompt = '''
Bạn là bộ phân loại ý định cho trợ lý AI ButlerX (tiếng Việt).
Hôm nay là ${now.day}/${now.month}/${now.year}, ${_weekdayVn(now.weekday)}.

Phân tích tin nhắn và trả về JSON:
{
  "intent": "chat|schedule.create|schedule.query|reminder.create|health.log|meal.generate",
  "confidence": 0.0-1.0,
  "entities": { ... },
  "responseText": "phản hồi ngắn bằng tiếng Việt xác nhận hành động"
}

Entities theo intent:
- schedule.create: { "title": string, "startAt": "ISO8601", "endAt": "ISO8601|null", "location": "string|null" }
- schedule.query: { "date": "ISO8601 date" }
- reminder.create: { "title": string, "scheduledAt": "ISO8601", "repeatRule": "none|daily|weekly|monthly" }
- health.log: { "weightKg": number|null, "heightCm": number|null, "systolic": int|null, "diastolic": int|null, "heartRate": int|null, "bloodSugar": number|null }
- meal.generate: {}
- chat: {}

Quy tắc ngày giờ:
- "sáng mai" = ngày mai 8:00, "chiều nay" = hôm nay 14:00, "tối nay" = hôm nay 19:00
- "tuần sau" = thứ Hai tuần sau, mặc định giờ = 9:00
- Chỉ trả JSON, không giải thích thêm.
''';

    try {
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  systemPrompt),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  transcript),
            ],
          ),
        ],
        temperature: 0,
        maxTokens: 400,
        responseFormat: {'type': 'json_object'},
      );

      final raw =
          response.choices.first.message.content?.first.text ?? '';
      if (raw.isEmpty) return _fallbackChat();

      final json = jsonDecode(raw) as Map<String, dynamic>;
      return IntentResult(
        intent: _parseIntent(json['intent'] as String? ?? 'chat'),
        entities:
            (json['entities'] as Map<String, dynamic>?) ?? const {},
        responseText:
            json['responseText'] as String? ?? 'Tôi hiểu rồi.',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      );
    } on RequestFailedException catch (e) {
      throw ServerException('Lỗi phân tích ý định: ${e.message}');
    } on FormatException {
      return _fallbackChat();
    }
  }

  IntentResult _fallbackChat() => const IntentResult(
        intent: AgentIntent.chat,
        entities: {},
        responseText: '',
      );

  AgentIntent _parseIntent(String s) => switch (s) {
        'schedule.create' => AgentIntent.scheduleCreate,
        'schedule.query' => AgentIntent.scheduleQuery,
        'reminder.create' => AgentIntent.reminderCreate,
        'health.log' => AgentIntent.healthLog,
        'meal.generate' => AgentIntent.mealGenerate,
        _ => AgentIntent.chat,
      };

  String _weekdayVn(int wd) => switch (wd) {
        1 => 'Thứ Hai',
        2 => 'Thứ Ba',
        3 => 'Thứ Tư',
        4 => 'Thứ Năm',
        5 => 'Thứ Sáu',
        6 => 'Thứ Bảy',
        7 => 'Chủ Nhật',
        _ => '',
      };
}
