import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../chat/data/services/openai_service.dart';

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
    VoiceIntentParser(ref.watch(openAiServiceProvider));

final class VoiceIntentParser {
  VoiceIntentParser(this._openAi);
  final OpenAiService _openAi;

  Future<ParsedAppointment?> parse(String transcript) async {
    final key = await _openAi.getApiKey();
    if (key == null || key.isEmpty) {
      throw const ValidationException(
          'Cần API key để phân tích giọng nói. Vào Cài đặt để thêm.');
    }
    OpenAI.apiKey = key;

    final now = DateTime.now();
    final systemPrompt = '''
Bạn là trợ lý phân tích lịch hẹn tiếng Việt. Hôm nay là ${now.day}/${now.month}/${now.year}.
Người dùng nói một câu về lịch hẹn. Hãy trích xuất thông tin và trả về JSON với format:
{
  "title": "tên lịch hẹn",
  "startAt": "ISO8601 datetime",
  "endAt": "ISO8601 datetime hoặc null",
  "location": "địa điểm hoặc null",
  "description": "ghi chú thêm hoặc null"
}
Quy tắc ngày giờ:
- "sáng mai" = ngày mai 8:00
- "chiều nay" = hôm nay 14:00
- "tối nay" = hôm nay 19:00
- "tuần sau" = thứ Hai tuần sau
- Nếu không có giờ = 9:00 sáng
- Chỉ trả về JSON, không giải thích thêm.
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
        maxTokens: 300,
        responseFormat: {"type": "json_object"},
      );

      final raw = response.choices.first.message.content?.first.text ?? '';
      if (raw.isEmpty) return null;

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final startRaw = json['startAt'] as String?;
      if (startRaw == null) return null;

      return ParsedAppointment(
        title: json['title'] as String? ?? 'Lịch hẹn',
        startAt: DateTime.parse(startRaw),
        endAt: json['endAt'] != null
            ? DateTime.tryParse(json['endAt'] as String)
            : null,
        location: json['location'] as String?,
        description: json['description'] as String?,
      );
    } on RequestFailedException catch (e) {
      throw ServerException('Lỗi phân tích giọng nói: ${e.message}');
    } on FormatException {
      return null;
    }
  }
}
