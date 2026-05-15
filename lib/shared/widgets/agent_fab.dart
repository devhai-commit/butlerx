import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agent/agent_notifier.dart';

class AgentFab extends ConsumerWidget {
  const AgentFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(agentNotifierProvider.select((s) => s.phase));
    final isVisible =
        ref.watch(agentNotifierProvider.select((s) => s.isVisible));

    if (isVisible) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final isListening = phase == AgentPhase.listening;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isListening
              ? [cs.tertiary, cs.secondary]
              : [cs.primary, Color.lerp(cs.primary, cs.secondary, 0.3)!],
        ),
        boxShadow: [
          BoxShadow(
            color: (isListening ? cs.tertiary : cs.primary)
                .withValues(alpha: 0.40),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: cs.secondary.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(agentNotifierProvider.notifier).activate(),
          customBorder: const CircleBorder(),
          child: Icon(
            isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    )
        .animate(
          key: ValueKey(isListening),
          onPlay: (c) => c.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.07, 1.07),
          duration: Duration(milliseconds: isListening ? 650 : 1800),
          curve: Curves.easeInOut,
        );
  }
}
