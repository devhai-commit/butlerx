import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/stt_provider.dart';
import '../../../../shared/providers/tts_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_notifier.dart';
import '../widgets/jarvis_orb.dart';
import '../widgets/message_bubble.dart';
import 'conversation_list_page.dart';

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
        title: Text(
          'ButlerX',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.history_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Lịch sử trò chuyện',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ConversationListPage(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_comment_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JarvisOrb(orbState: orbState, size: 68),
          if (greeting != null) ...[
            const SizedBox(height: 14),
            Text(
              greeting!,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _statusLabel(orbState),
              style: TextStyle(
                color: cs.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
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

  // Stitch-UI accent colors: primary blue, secondary teal, tertiary lavender
  static const _categories = [
    _SuggestionCategory(
      icon: Icons.psychology_outlined,
      label: 'Trò chuyện',
      color: Color(0xFF295EA6),
      suggestions: [
        'Kể cho tôi nghe một điều thú vị',
        'Hôm nay tôi nên làm gì?',
      ],
    ),
    _SuggestionCategory(
      icon: Icons.favorite_outline,
      label: 'Sức khỏe',
      color: Color(0xFF006B5C),
      suggestions: [
        'Tôi nên ăn gì để giảm cân?',
        'Bài tập cardio nào phù hợp cho người mới?',
      ],
    ),
    _SuggestionCategory(
      icon: Icons.calendar_today_outlined,
      label: 'Lịch & Nhắc nhở',
      color: Color(0xFF5038A0),
      suggestions: [
        'Nhắc tôi uống nước mỗi 2 tiếng',
        'Giúp tôi lên kế hoạch tuần này',
      ],
    ),
    _SuggestionCategory(
      icon: Icons.restaurant_outlined,
      label: 'Bữa ăn',
      color: Color(0xFF006B5C),
      suggestions: [
        'Giúp tôi lên thực đơn cho tuần này',
        'Món ăn nào dễ nấu và bổ dưỡng?',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              'Bạn muốn làm gì hôm nay?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
            ),
          ),
          ..._categories.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            return _CategorySection(
              category: cat,
              isDark: isDark,
              animDelay: Duration(milliseconds: 80 + i * 70),
            );
          }),
        ],
      ),
    );
  }
}

class _SuggestionCategory {
  const _SuggestionCategory({
    required this.icon,
    required this.label,
    required this.color,
    required this.suggestions,
  });
  final IconData icon;
  final String label;
  final Color color;
  final List<String> suggestions;
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.isDark,
    required this.animDelay,
  });
  final _SuggestionCategory category;
  final bool isDark;
  final Duration animDelay;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = isDark
        ? Color.lerp(category.color, Colors.white, 0.25)!
        : category.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.2 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(category.icon, size: 15, color: accent),
                ),
                const SizedBox(width: 8),
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          ...category.suggestions.map(
            (s) => _SuggestionChip(text: s, accent: accent, isDark: isDark),
          ),
          const SizedBox(height: 4),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 0.25,
          end: 0,
          duration: 350.ms,
          delay: animDelay,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 300.ms, delay: animDelay);
  }
}

class _SuggestionChip extends ConsumerWidget {
  const _SuggestionChip({
    required this.text,
    required this.accent,
    required this.isDark,
  });
  final String text;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => ref.read(chatNotifierProvider.notifier).sendMessage(text),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: 0.85),
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.north_east_rounded,
              size: 13,
              color: accent.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ttsState = ref.watch(ttsNotifierProvider);
    final sttState = ref.watch(sttNotifierProvider);

    // Update text field with live transcript
    if (sttState.isListening && sttState.transcript.isNotEmpty) {
      controller.text = sttState.transcript;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1D2024).withValues(alpha: 0.95)
              : cs.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : cs.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // TTS toggle button
            IconButton(
              icon: Icon(
                ttsState.enabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_outlined,
                size: 22,
              ),
              color: ttsState.enabled ? cs.primary : cs.outline,
              tooltip: ttsState.enabled ? 'Tắt đọc to' : 'Bật đọc to',
              onPressed: () =>
                  ref.read(ttsNotifierProvider.notifier).toggle(),
            ),
            // Microphone button
            IconButton(
              icon: Icon(
                sttState.isListening
                    ? Icons.mic_rounded
                    : Icons.mic_none_outlined,
                size: 22,
              ),
              color: sttState.isListening ? cs.error : cs.outline,
              tooltip: sttState.isListening ? 'Dừng nghe' : 'Nói',
              onPressed: () {
                if (sttState.isListening) {
                  ref.read(sttNotifierProvider.notifier).stopListening();
                  // Auto-send if there's transcript
                  if (controller.text.trim().isNotEmpty) {
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      onSend,
                    );
                  }
                } else {
                  ref.read(sttNotifierProvider.notifier).startListening();
                }
              },
            ),
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
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary,
                            Color.lerp(cs.primary, cs.secondary, 0.3)!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onSend,
                          customBorder: const CircleBorder(),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
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
