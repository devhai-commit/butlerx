import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(appDatabaseProvider));

final class ChatRepository {
  ChatRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  String newMessageId() => _uuid.v4();

  Future<Conversation> createConversation(String userId) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.conversationDao.upsert(
      ConversationRow(
        id: id,
        userId: userId,
        title: 'Cuộc trò chuyện mới',
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: null,
      ),
    );
    return Conversation(
      id: id,
      userId: userId,
      title: 'Cuộc trò chuyện mới',
      createdAt: now,
    );
  }

  Future<Conversation?> loadConversation(String id) async {
    final row = await _db.conversationDao.getById(id);
    if (row == null) return null;
    final msgs = await _db.conversationDao.getMessagesForConversation(id);
    return _rowToConversation(row, msgs);
  }

  Future<List<Conversation>> listConversations(String userId) async {
    final rows = await _db.conversationDao.getAllForUser(userId);
    final result = <Conversation>[];
    for (final row in rows) {
      final msgs =
          await _db.conversationDao.getMessagesForConversation(row.id);
      result.add(_rowToConversation(row, msgs));
    }
    return result;
  }

  Future<Conversation> addMessage(
    Conversation conversation,
    ChatMessage message,
  ) async {
    await _db.conversationDao.upsertMessage(
      ChatMessageRow(
        id: message.id,
        conversationId: conversation.id,
        role: message.role.name,
        content: message.content,
        createdAt: message.createdAt.millisecondsSinceEpoch,
      ),
    );

    final updated = conversation.copyWith(
      messages: [...conversation.messages, message],
      updatedAt: DateTime.now(),
    );

    final firstUser = updated.messages.firstWhere(
      (m) => m.isUser,
      orElse: () => message,
    );
    final titled = updated.copyWith(title: _truncate(firstUser.content, 40));

    await _db.conversationDao.upsert(
      ConversationRow(
        id: titled.id,
        userId: titled.userId,
        title: titled.title,
        createdAt: titled.createdAt.millisecondsSinceEpoch,
        updatedAt: titled.updatedAt?.millisecondsSinceEpoch,
      ),
    );

    return titled;
  }

  Future<Conversation> updateLastMessage(
    Conversation conversation,
    ChatMessage message,
  ) async {
    await _db.conversationDao.upsertMessage(
      ChatMessageRow(
        id: message.id,
        conversationId: conversation.id,
        role: message.role.name,
        content: message.content,
        createdAt: message.createdAt.millisecondsSinceEpoch,
      ),
    );

    final messages = [...conversation.messages];
    final idx = messages.indexWhere((m) => m.id == message.id);
    if (idx >= 0) {
      messages[idx] = message;
    } else {
      messages.add(message);
    }

    final now = DateTime.now();
    final updated = conversation.copyWith(messages: messages, updatedAt: now);

    await _db.conversationDao.upsert(
      ConversationRow(
        id: updated.id,
        userId: updated.userId,
        title: updated.title,
        createdAt: updated.createdAt.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ),
    );

    return updated;
  }

  Future<void> deleteConversation(
    String userId,
    String conversationId,
  ) =>
      _db.conversationDao.deleteById(conversationId);

  // ── Helpers ───────────────────────────────────────────────────────────────

  Conversation _rowToConversation(
    ConversationRow row,
    List<ChatMessageRow> msgRows,
  ) =>
      Conversation(
        id: row.id,
        userId: row.userId,
        title: row.title,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
        updatedAt: row.updatedAt != null
            ? DateTime.fromMillisecondsSinceEpoch(row.updatedAt!)
            : null,
        messages: msgRows.map(_rowToMessage).toList(),
      );

  ChatMessage _rowToMessage(ChatMessageRow row) => ChatMessage(
        id: row.id,
        conversationId: row.conversationId,
        role: MessageRole.values.byName(row.role),
        content: row.content,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      );

  String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}...';
}
