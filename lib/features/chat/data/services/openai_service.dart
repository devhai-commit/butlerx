import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/chat_message.dart';

part 'openai_service.g.dart';

@riverpod
OpenAiService openAiService(Ref ref) => OpenAiService();

final class OpenAiService {
  OpenAiService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> setApiKey(String key) async {
    await _storage.write(key: StorageKeys.openAiApiKey, value: key.trim());
    OpenAI.apiKey = key.trim();
  }

  Future<String?> getApiKey() =>
      _storage.read(key: StorageKeys.openAiApiKey);

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  Future<void> initFromStorage() async {
    final key = await getApiKey();
    if (key != null && key.isNotEmpty) OpenAI.apiKey = key;
  }

  /// Streams assistant reply tokens. Yields partial content as they arrive.
  Stream<String> streamChat({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
  }) async* {
    final key = await getApiKey();
    if (key == null || key.isEmpty) {
      throw const ValidationException(
        'Chưa cài API key. Vào Cài đặt để thêm OpenAI API key.',
      );
    }
    OpenAI.apiKey = key;

    OpenAI.showLogs = false;
    OpenAI.showResponsesLogs = false;

    final messages = <OpenAIChatCompletionChoiceMessageModel>[
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
        ],
      ),
      ...history.where((m) => !m.isStreaming).map(
            (m) => OpenAIChatCompletionChoiceMessageModel(
              role: m.isUser
                  ? OpenAIChatMessageRole.user
                  : OpenAIChatMessageRole.assistant,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    m.content),
              ],
            ),
          ),
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage),
        ],
      ),
    ];

    try {
      final stream = OpenAI.instance.chat.createStream(
        model: AppConstants.openAiModel,
        messages: messages,
        temperature: 0.8,
        maxTokens: 1024,
      );

      await for (final chunk in stream) {
        final content = chunk.choices.firstOrNull?.delta.content;
        if (content != null) {
          for (final item in content) {
            final text = item.text;
            if (text != null && text.isNotEmpty) yield text;
          }
        }
      }
    } on RequestFailedException catch (e) {
      throw switch (e.statusCode) {
        401 => const ValidationException('API key không hợp lệ'),
        429 => const ValidationException(
            'Vượt quá giới hạn API. Thử lại sau'),
        _ => ServerException('Lỗi OpenAI: ${e.message}'),
      };
    }
  }

  Future<void> deleteApiKey() =>
      _storage.delete(key: StorageKeys.openAiApiKey);
}
