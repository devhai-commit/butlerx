import 'chat_message.dart';

final class Conversation {
  const Conversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    this.messages = const [],
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ChatMessage> messages;

  Conversation copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) =>
      Conversation(
        id: id,
        userId: userId,
        title: title ?? this.title,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        messages: messages ?? this.messages,
      );
}
