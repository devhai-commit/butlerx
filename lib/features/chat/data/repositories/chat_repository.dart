import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) => ChatRepository();

final class ChatRepository {
  static const _kConversationPrefix = 'conversation_';
  static const _maxStoredConversations = 20;
  static const _uuid = Uuid();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Conversation> createConversation(String userId) async {
    final id = _uuid.v4();
    final conv = Conversation(
      id: id,
      userId: userId,
      title: 'Cuộc trò chuyện mới',
      createdAt: DateTime.now(),
    );
    await _saveConversation(conv);
    return conv;
  }

  Future<Conversation?> loadConversation(String id) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_kConversationPrefix$id');
    if (raw == null) return null;
    return _decodeConversation(raw);
  }

  Future<List<Conversation>> listConversations(String userId) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList('conversations_$userId') ?? [];
    final convs = <Conversation>[];
    for (final id in ids) {
      final c = await loadConversation(id);
      if (c != null) convs.add(c);
    }
    convs.sort((a, b) =>
        (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
    return convs;
  }

  Future<Conversation> addMessage(Conversation conversation, ChatMessage message) async {
    final updated = conversation.copyWith(
      messages: [...conversation.messages, message],
      updatedAt: DateTime.now(),
    );
    // Auto-title from first user message
    final title = updated.messages.firstWhere(
      (m) => m.isUser,
      orElse: () => message,
    );
    final titledConv = updated.copyWith(
      title: _truncate(title.content, 40),
    );
    await _saveConversation(titledConv);
    return titledConv;
  }

  Future<Conversation> updateLastMessage(Conversation conversation, ChatMessage message) async {
    final messages = [...conversation.messages];
    final idx = messages.indexWhere((m) => m.id == message.id);
    if (idx >= 0) {
      messages[idx] = message;
    } else {
      messages.add(message);
    }
    final updated = conversation.copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
    );
    await _saveConversation(updated);
    return updated;
  }

  Future<void> deleteConversation(String userId, String conversationId) async {
    final prefs = await _prefs;
    await prefs.remove('$_kConversationPrefix$conversationId');
    final ids = prefs.getStringList('conversations_$userId') ?? [];
    ids.remove(conversationId);
    await prefs.setStringList('conversations_$userId', ids);
  }

  Future<void> _saveConversation(Conversation conv) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_kConversationPrefix${conv.id}',
      _encodeConversation(conv),
    );
    final ids = prefs.getStringList('conversations_${conv.userId}') ?? [];
    if (!ids.contains(conv.id)) {
      ids.insert(0, conv.id);
      // Trim old conversations
      if (ids.length > _maxStoredConversations) {
        final removed = ids.sublist(_maxStoredConversations);
        for (final id in removed) {
          await prefs.remove('$_kConversationPrefix$id');
        }
        ids.removeRange(_maxStoredConversations, ids.length);
      }
      await prefs.setStringList('conversations_${conv.userId}', ids);
    }
  }

  String _encodeConversation(Conversation c) => jsonEncode({
        'id': c.id,
        'userId': c.userId,
        'title': c.title,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt?.toIso8601String(),
        'messages': c.messages.map((m) => m.toJson()).toList(),
      });

  Conversation _decodeConversation(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final msgs = (json['messages'] as List<dynamic>)
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
    return Conversation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      messages: msgs,
    );
  }

  String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}...';

  String newMessageId() => _uuid.v4();
}
