import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_notifier.dart';
import '../widgets/jarvis_orb.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();
  String _previousLastId = '';

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: AppConstants.animNormal,
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    _focusNode.unfocus();
    await ref.read(chatNotifierProvider.notifier).sendMessage(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    final messages = chatState.messages;
    final lastId = messages.lastOrNull?.id ?? '';
    final isNewMessage = lastId != _previousLastId;
    if (isNewMessage) {
      _previousLastId = lastId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    final greeting = authState is AuthAuthenticated
        ? 'Xin chào ${authState.profile.addressTitle.label} ${authState.profile.firstNameGreeting}!'
        : 'Xin chào!';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ButlerX'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Cuộc trò chuyện mới',
            onPressed: () =>
                ref.read(chatNotifierProvider.notifier).startNewConversation(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Orb + greeting
          _OrbHeader(
            orbState: chatState.orbState,
            greeting: messages.isEmpty ? greeting : null,
          ),

          // Error banner
          if (chatState.error != null)
            _ErrorBanner(
              message: chatState.error!,
              onDismiss: () =>
                  ref.read(chatNotifierProvider.notifier).clearError(),
            ),

          // Message list
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(greeting: greeting)
                : ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isNew = isNewMessage && i == messages.length - 1;
                      return MessageBubble(message: msg, isNew: isNew);
                    },
                  ),
          ),

          // Input bar
          _InputBar(
            controller: _textCtrl,
            focusNode: _focusNode,
            isLoading: chatState.orbState != OrbState.idle,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _OrbHeader extends StatelessWidget {
  const _OrbHeader({required this.orbState, this.greeting});
  final OrbState orbState;
  final String? greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JarvisOrb(orbState: orbState, size: 72),
          if (greeting != null) ...[
            const SizedBox(height: 10),
            Text(
              greeting!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              _statusLabel(orbState),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(OrbState s) => switch (s) {
        OrbState.idle => 'Tôi có thể giúp gì cho bạn?',
        OrbState.listening => 'Đang nghe...',
        OrbState.thinking => 'Đang suy nghĩ...',
        OrbState.speaking => 'Đang trả lời...',
      };
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.greeting});
  final String greeting;

  static const _suggestions = [
    'Hôm nay thời tiết thế nào?',
    'Giúp tôi lên thực đơn cho tuần này',
    'Nhắc tôi uống nước mỗi 2 tiếng',
    'Tôi nên ăn gì để giảm cân?',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Gợi ý câu hỏi',
            style: TextStyle(color: cs.outline, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._suggestions.map(
            (s) => _SuggestionChip(text: s),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  const _SuggestionChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () =>
          ref.read(chatNotifierProvider.notifier).sendMessage(text),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 18, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 14)),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: cs.outline),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => isLoading ? null : onSend(),
                enabled: !isLoading,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: AppConstants.animFast,
              child: isLoading
                  ? SizedBox.square(
                      dimension: 44,
                      child: Center(
                        child: SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    )
                  : IconButton.filled(
                      onPressed: onSend,
                      icon: const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        minimumSize: const Size(44, 44),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(color: cs.error, fontSize: 13)),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: cs.error),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
