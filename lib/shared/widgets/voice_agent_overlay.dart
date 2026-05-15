import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agent/agent_notifier.dart';
import '../../features/chat/presentation/providers/chat_notifier.dart';
import '../../features/chat/presentation/widgets/jarvis_orb.dart';
import 'voice_waveform.dart';

class VoiceAgentOverlay extends ConsumerWidget {
  const VoiceAgentOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentState = ref.watch(agentNotifierProvider);

    if (!agentState.isVisible) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final orbState = switch (agentState.phase) {
      AgentPhase.idle => OrbState.idle,
      AgentPhase.listening => OrbState.listening,
      AgentPhase.processing => OrbState.thinking,
      AgentPhase.speaking => OrbState.speaking,
    };

    final statusLabel = switch (agentState.phase) {
      AgentPhase.idle => 'Sẵn sàng',
      AgentPhase.listening => 'Đang lắng nghe...',
      AgentPhase.processing => 'Đang xử lý...',
      AgentPhase.speaking => 'Đang trả lời...',
    };

    return GestureDetector(
      onTap: () => ref.read(agentNotifierProvider.notifier).dismiss(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: const Color(0xFF0C0E13).withValues(alpha: 0.88),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Large orb
                JarvisOrb(orbState: orbState, size: 130)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .scale(
                      begin: const Offset(0.65, 0.65),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 28),

                // Status label
                Text(
                  statusLabel,
                  style: tt.titleMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(begin: 0.6, duration: 1000.ms),

                const SizedBox(height: 28),

                // Waveform
                VoiceWaveform(phase: agentState.phase, color: cs.secondary),

                const SizedBox(height: 36),

                // Transcript bubble
                if (agentState.transcript.isNotEmpty)
                  _InfoBubble(
                    label: 'Bạn nói',
                    text: agentState.transcript,
                    borderColor: cs.tertiary,
                    labelColor: cs.tertiary,
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2),

                // Response bubble
                if (agentState.response.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoBubble(
                    label: 'ButlerX',
                    text: agentState.response,
                    borderColor: cs.secondary,
                    labelColor: cs.secondary,
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2),
                ],

                // Error
                if (agentState.error != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: Text(
                      agentState.error!,
                      style: tt.bodyMedium?.copyWith(color: cs.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const Spacer(),

                // Stop listening button
                if (agentState.phase == AgentPhase.listening)
                  _StopButton(cs: cs, ref: ref),

                const SizedBox(height: 20),

                Text(
                  'Nhấn bất kỳ đâu để đóng',
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.30),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stop Button ──────────────────────────────────────────────────────────────

class _StopButton extends StatelessWidget {
  const _StopButton({required this.cs, required this.ref});
  final ColorScheme cs;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(agentNotifierProvider.notifier).stopListening(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: cs.tertiary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: cs.tertiary.withValues(alpha: 0.30),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stop_circle_outlined, color: cs.tertiary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Dừng nghe',
              style: TextStyle(
                color: cs.tertiary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2);
  }
}

// ─── Info Bubble ──────────────────────────────────────────────────────────────

class _InfoBubble extends StatelessWidget {
  const _InfoBubble({
    required this.label,
    required this.text,
    required this.borderColor,
    required this.labelColor,
  });

  final String label;
  final String text;
  final Color borderColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1D2024).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.30),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.90),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
