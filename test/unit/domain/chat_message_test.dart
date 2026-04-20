import 'package:butlerx/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessage _make({
  MessageRole role = MessageRole.user,
  String content = 'Xin chào',
  bool isStreaming = false,
}) =>
    ChatMessage(
      id: 'msg-1',
      conversationId: 'conv-1',
      role: role,
      content: content,
      createdAt: DateTime(2024, 1, 1),
      isStreaming: isStreaming,
    );

void main() {
  group('ChatMessage', () {
    test('isUser returns true for user role', () {
      expect(_make(role: MessageRole.user).isUser, isTrue);
      expect(_make(role: MessageRole.assistant).isUser, isFalse);
    });

    test('isAssistant returns true for assistant role', () {
      expect(_make(role: MessageRole.assistant).isAssistant, isTrue);
      expect(_make(role: MessageRole.user).isAssistant, isFalse);
    });

    test('copyWith updates content only', () {
      final original = _make(isStreaming: true);
      final updated = original.copyWith(content: 'Xin chào bạn', isStreaming: false);
      expect(updated.id, original.id);
      expect(updated.content, 'Xin chào bạn');
      expect(updated.isStreaming, isFalse);
      expect(updated.role, original.role);
    });

    test('equality based on id', () {
      final a = _make();
      final b = a.copyWith(content: 'khác');
      expect(a, equals(b));
    });

    group('serialization', () {
      test('toJson/fromJson round-trips all fields', () {
        final original = _make(role: MessageRole.assistant, content: 'Tôi có thể giúp gì?');
        final restored = ChatMessage.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.conversationId, original.conversationId);
        expect(restored.role, original.role);
        expect(restored.content, original.content);
        expect(restored.createdAt, original.createdAt);
      });

      test('fromJson handles all MessageRole values', () {
        for (final role in MessageRole.values) {
          final msg = _make(role: role);
          final restored = ChatMessage.fromJson(msg.toJson());
          expect(restored.role, role);
        }
      });
    });
  });
}
