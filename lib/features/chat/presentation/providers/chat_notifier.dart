import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/openai_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/persona_prompt_builder.dart';

part 'chat_notifier.g.dart';

enum OrbState { idle, listening, thinking, speaking }

final class ChatState {
  const ChatState({
    this.conversation,
    this.orbState = OrbState.idle,
    this.isLoading = false,
    this.error,
  });

  final Conversation? conversation;
  final OrbState orbState;
  final bool isLoading;
  final String? error;

  List<ChatMessage> get messages => conversation?.messages ?? [];

  ChatState copyWith({
    Conversation? conversation,
    OrbState? orbState,
    bool? isLoading,
    String? Function()? error,
  }) =>
      ChatState(
        conversation: conversation ?? this.conversation,
        orbState: orbState ?? this.orbState,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );
}

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  ChatState build() {
    // Load or create conversation when provider initializes
    Future.microtask(_initConversation);
    return const ChatState(orbState: OrbState.idle);
  }

  Future<void> _initConversation() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    final repo = ref.read(chatRepositoryProvider);
    final conversations = await repo.listConversations(authState.profile.uid);

    if (conversations.isNotEmpty) {
      state = state.copyWith(conversation: conversations.first);
    } else {
      final conv = await repo.createConversation(authState.profile.uid);
      state = state.copyWith(conversation: conv);
    }
  }

  Future<void> sendMessage(String text) async {
    final input = text.trim();
    if (input.isEmpty) return;

    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    final repo = ref.read(chatRepositoryProvider);
    final openAi = ref.read(openAiServiceProvider);

    // Ensure conversation exists
    var conversation = state.conversation ??
        await repo.createConversation(authState.profile.uid);

    // Add user message immediately
    final userMsg = ChatMessage(
      id: repo.newMessageId(),
      conversationId: conversation.id,
      role: MessageRole.user,
      content: input,
      createdAt: DateTime.now(),
    );
    conversation = await repo.addMessage(conversation, userMsg);
    state = state.copyWith(
      conversation: conversation,
      orbState: OrbState.thinking,
      error: () => null,
    );

    // Create streaming assistant message placeholder
    final assistantId = repo.newMessageId();
    var assistantMsg = ChatMessage(
      id: assistantId,
      conversationId: conversation.id,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    conversation = await repo.addMessage(conversation, assistantMsg);
    state = state.copyWith(conversation: conversation);

    // Build system prompt from user profile
    final systemPrompt = PersonaPromptBuilder.build(authState.profile);

    // Stream response
    final buffer = StringBuffer();
    try {
      state = state.copyWith(orbState: OrbState.speaking);

      await for (final token in openAi.streamChat(
        systemPrompt: systemPrompt,
        history: conversation.messages
            .where((m) => m.id != assistantId)
            .toList(),
        userMessage: input,
      )) {
        buffer.write(token);
        assistantMsg = assistantMsg.copyWith(
          content: buffer.toString(),
          isStreaming: true,
        );
        conversation = await repo.updateLastMessage(conversation, assistantMsg);
        state = state.copyWith(conversation: conversation);
      }

      // Finalize message
      assistantMsg = assistantMsg.copyWith(
        content: buffer.toString(),
        isStreaming: false,
      );
      conversation = await repo.updateLastMessage(conversation, assistantMsg);
      state = state.copyWith(
        conversation: conversation,
        orbState: OrbState.idle,
      );
    } catch (e) {
      // Remove empty streaming message on error, show error
      final msgs = conversation.messages
          .where((m) => m.id != assistantId)
          .toList();
      conversation = conversation.copyWith(messages: msgs);
      state = state.copyWith(
        conversation: conversation,
        orbState: OrbState.idle,
        error: () => e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> startNewConversation() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;
    final repo = ref.read(chatRepositoryProvider);
    final conv = await repo.createConversation(authState.profile.uid);
    state = state.copyWith(
      conversation: conv,
      orbState: OrbState.idle,
      error: () => null,
    );
  }

  void clearError() => state = state.copyWith(error: () => null);
}
