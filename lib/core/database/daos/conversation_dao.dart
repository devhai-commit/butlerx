import '../app_database.dart';

class ConversationDao {
  ConversationDao(this._db);

  final AppDatabase _db;

  Future<ConversationRow?> getById(String id) async {
    final result = await _db.execute(
      'SELECT * FROM conversations WHERE id = @id',
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return ConversationRow.fromMap(result.first);
  }

  Future<List<ConversationRow>> getAllForUser(String userId) async {
    final result = await _db.execute(
      'SELECT * FROM conversations WHERE user_id = @userId ORDER BY created_at DESC',
      parameters: {'userId': userId},
    );
    return result.map((r) => ConversationRow.fromMap(r)).toList();
  }

  Future<void> upsert(ConversationRow row) async {
    await _db.execute(
      '''
      INSERT INTO conversations (id, user_id, title, created_at, updated_at)
      VALUES (@id, @userId, @title, @createdAt, @updatedAt)
      ON CONFLICT (id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        title = EXCLUDED.title,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at
      ''',
      parameters: {
        'id': row.id,
        'userId': row.userId,
        'title': row.title,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
      },
    );
  }

  Future<void> deleteById(String id) async {
    await _db.execute(
      'DELETE FROM conversations WHERE id = @id',
      parameters: {'id': id},
    );
  }

  Future<List<ChatMessageRow>> getMessagesForConversation(
    String conversationId,
  ) async {
    final result = await _db.execute(
      'SELECT * FROM chat_messages WHERE conversation_id = @conversationId ORDER BY created_at ASC',
      parameters: {'conversationId': conversationId},
    );
    return result.map((r) => ChatMessageRow.fromMap(r)).toList();
  }

  Future<void> upsertMessage(ChatMessageRow row) async {
    await _db.execute(
      '''
      INSERT INTO chat_messages (id, conversation_id, role, content, created_at)
      VALUES (@id, @conversationId, @role, @content, @createdAt)
      ON CONFLICT (id) DO UPDATE SET
        conversation_id = EXCLUDED.conversation_id,
        role = EXCLUDED.role,
        content = EXCLUDED.content,
        created_at = EXCLUDED.created_at
      ''',
      parameters: {
        'id': row.id,
        'conversationId': row.conversationId,
        'role': row.role,
        'content': row.content,
        'createdAt': row.createdAt,
      },
    );
  }
}
