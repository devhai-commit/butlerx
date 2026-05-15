import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/agent/agent_notifier.dart';

class VoiceWaveform extends StatelessWidget {
  const VoiceWaveform({
    super.key,
    required this.phase,
    this.barCount = 7,
    this.color,
  });

  final AgentPhase phase;
  final int barCount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? Theme.of(context).colorScheme.tertiary;
    final isActive = phase == AgentPhase.listening;

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (i) {
          final baseHeight = 6.0 + (i % 3) * 4.0;
          final maxScale = 1.5 + (i % 5) * 0.5;
          final delayMs = i * 80;
          final durationMs = 280 + (i % 3) * 100;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: isActive
                ? Container(
                    width: 4,
                    height: baseHeight,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                    .animate(
                      onPlay: (c) => c.repeat(reverse: true),
                      delay: Duration(milliseconds: delayMs),
                    )
                    .scaleY(
                      begin: 0.3,
                      end: maxScale,
                      duration: Duration(milliseconds: durationMs),
                      curve: Curves.easeInOut,
                    )
                : Container(
                    width: 4,
                    height: 6,
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
          );
        }),
      ),
    );
  }
}
