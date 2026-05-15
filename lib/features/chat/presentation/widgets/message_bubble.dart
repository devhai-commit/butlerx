import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/tts_provider.dart';
import '../../domain/entities/chat_message.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message, this.isNew = false});

  final ChatMessage message;
  final bool isNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;

    const radius = 18.0;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(radius),
      topRight: const Radius.circular(radius),
      bottomLeft: Radius.circular(isUser ? radius : 4),
      bottomRight: Radius.circular(isUser ? 4 : radius),
    );

    final bubble = GestureDetector(
      onLongPress: message.content.isNotEmpty
          ? () => _copyToClipboard(context, message.content)
          : null,
      child: isUser
          ? _UserBubble(message: message, cs: cs, borderRadius: borderRadius)
          : _AssistantBubble(
              message: message,
              cs: cs,
              isDark: isDark,
              borderRadius: borderRadius,
            ),
    );

    final row = Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) ...[
          _OrbAvatar(cs: cs),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                ),
                child: bubble,
              ),
              if (!isUser && !message.isStreaming && message.content.isNotEmpty)
                _AssistantActions(message: message),
            ],
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          _UserAvatar(cs: cs),
        ],
      ],
    );

    if (isNew) {
      return row
          .animate()
          .slideY(begin: 0.25, end: 0, duration: 280.ms, curve: Curves.easeOut)
          .fadeIn(duration: 220.ms);
    }
    return row;
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã sao chép'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Orb Avatar (assistant) ──────────────────────────────────────────────────

class _OrbAvatar extends StatelessWidget {
  const _OrbAvatar({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            const Color(0xFFA9C7FF),
            cs.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB1CCFF).withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(Icons.home_rounded, size: 14, color: Colors.white),
    );
  }
}

// ─── User Avatar ──────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: cs.primary.withValues(alpha: 0.15),
      child: Icon(Icons.person_rounded, size: 15, color: cs.primary),
    );
  }
}

// ─── User Bubble ─────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  const _UserBubble({
    required this.message,
    required this.cs,
    required this.borderRadius,
  });

  final ChatMessage message;
  final ColorScheme cs;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            Color.lerp(cs.primary, cs.secondary, 0.25)!,
          ],
        ),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: cs.onPrimary,
          fontSize: 15,
          height: 1.5,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─── Assistant Bubble ─────────────────────────────────────────────────────────

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({
    required this.message,
    required this.cs,
    required this.isDark,
    required this.borderRadius,
  });

  final ChatMessage message;
  final ColorScheme cs;
  final bool isDark;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter:
          ui.ImageFilter.blur(sigmaX: isDark ? 12 : 0, sigmaY: isDark ? 12 : 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF282A2F).withValues(alpha: 0.7)
              : cs.surfaceContainerHigh,
          borderRadius: borderRadius,
          border: Border.all(
            color: isDark
                ? const Color(0xFF41E4C0).withValues(alpha: 0.18)
                : cs.outlineVariant.withValues(alpha: 0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF295EA6).withValues(alpha: 0.15)
                  : cs.shadow.withValues(alpha: 0.04),
              blurRadius: isDark ? 20 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: message.isStreaming && message.content.isEmpty
            ? _ThinkingDots(color: cs.secondary)
            : Text(
                message.content,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 15,
                  height: 1.55,
                  letterSpacing: 0.1,
                ),
              ),
      ),
    );
  }
}

// ─── Assistant Actions ────────────────────────────────────────────────────────

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
          _ActionIcon(
            icon: Icons.copy_outlined,
            tooltip: 'Sao chép',
            color: cs.onSurfaceVariant,
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã sao chép'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: cs.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          if (ttsState.enabled) ...[
            const SizedBox(width: 4),
            _ActionIcon(
              icon: ttsState.isSpeaking
                  ? Icons.stop_circle_outlined
                  : Icons.volume_up_outlined,
              tooltip: ttsState.isSpeaking ? 'Dừng' : 'Đọc to',
              color: ttsState.isSpeaking ? cs.secondary : cs.onSurfaceVariant,
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
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

// ─── Thinking Dots ────────────────────────────────────────────────────────────

class _ThinkingDots extends StatelessWidget {
  const _ThinkingDots({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 0.5,
                end: 1.1,
                duration: 600.ms,
                delay: Duration(milliseconds: i * 180),
                curve: Curves.easeInOut,
              )
              .fadeIn(
                begin: 0.3,
                duration: 300.ms,
                delay: Duration(milliseconds: i * 180),
              ),
        );
      }),
    );
  }
}
