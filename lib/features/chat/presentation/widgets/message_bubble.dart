import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/tts_provider.dart';
import '../../domain/entities/chat_message.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message, this.isNew = false});

  final ChatMessage message;
  final bool isNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    final bubble = GestureDetector(
      onLongPress: message.content.isNotEmpty
          ? () => _copyToClipboard(context, message.content)
          : null,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppConstants.radiusLg),
            topRight: const Radius.circular(AppConstants.radiusLg),
            bottomLeft:
                Radius.circular(isUser ? AppConstants.radiusLg : 4),
            bottomRight:
                Radius.circular(isUser ? 4 : AppConstants.radiusLg),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: message.isStreaming && message.content.isEmpty
            ? _ThinkingDots(color: cs.onSurfaceVariant)
            : Text(
                message.content,
                style: TextStyle(
                  color: isUser ? cs.onPrimary : cs.onSurface,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
      ),
    );

    final row = Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) ...[
          CircleAvatar(
            radius: 14,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.home_rounded, size: 16, color: cs.primary),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              bubble,
              if (!isUser && !message.isStreaming && message.content.isNotEmpty)
                _AssistantActions(message: message),
            ],
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 14,
            backgroundColor: cs.secondaryContainer,
            child: Icon(Icons.person, size: 16, color: cs.secondary),
          ),
        ],
      ],
    );

    if (isNew) {
      return row
          .animate()
          .slideY(begin: 0.3, end: 0, duration: 250.ms, curve: Curves.easeOut)
          .fadeIn(duration: 200.ms);
    }
    return row;
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AssistantActions extends ConsumerWidget {
  const _AssistantActions({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ttsState = ref.watch(ttsNotifierProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy button
          _ActionIcon(
            icon: Icons.copy_outlined,
            tooltip: 'Sao chép',
            color: cs.outline,
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          // TTS button (only shown when TTS is enabled)
          if (ttsState.enabled)
            _ActionIcon(
              icon: ttsState.isSpeaking
                  ? Icons.stop_circle_outlined
                  : Icons.volume_up_outlined,
              tooltip: ttsState.isSpeaking ? 'Dừng' : 'Đọc to',
              color: ttsState.isSpeaking ? cs.primary : cs.outline,
              onTap: () {
                if (ttsState.isSpeaking) {
                  ref.read(ttsNotifierProvider.notifier).stop();
                } else {
                  ref
                      .read(ttsNotifierProvider.notifier)
                      .speakMessage(message.content);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _ThinkingDots extends StatelessWidget {
  const _ThinkingDots({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                begin: 0.6,
                end: 1.0,
                duration: 600.ms,
                delay: Duration(milliseconds: i * 150),
                curve: Curves.easeInOut,
              ),
        );
      }),
    );
  }
}
