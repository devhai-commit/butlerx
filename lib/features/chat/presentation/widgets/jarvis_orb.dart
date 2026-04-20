import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../presentation/providers/chat_notifier.dart';

class JarvisOrb extends StatelessWidget {
  const JarvisOrb({super.key, required this.orbState, this.size = 80});

  final OrbState orbState;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (color, pulseMs, scaleEnd) = switch (orbState) {
      OrbState.idle => (cs.primary, 3000, 1.0),
      OrbState.listening => (cs.tertiary, 600, 1.15),
      OrbState.thinking => (cs.secondary, 900, 1.1),
      OrbState.speaking => (cs.primary, 700, 1.12),
    };

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: Offset(scaleEnd, scaleEnd),
                duration: Duration(milliseconds: pulseMs),
                curve: Curves.easeInOut,
              )
              .fadeIn(),

          // Middle ring
          Container(
            width: size * 0.75,
            height: size * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.25),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: Offset(scaleEnd * 0.95, scaleEnd * 0.95),
                duration: Duration(milliseconds: (pulseMs * 0.8).round()),
                curve: Curves.easeInOut,
              ),

          // Core
          Container(
            width: size * 0.52,
            height: size * 0.52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.9),
                  color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _iconFor(orbState),
              color: cs.onPrimary,
              size: size * 0.28,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(OrbState s) => switch (s) {
        OrbState.idle => Icons.home_rounded,
        OrbState.listening => Icons.mic,
        OrbState.thinking => Icons.psychology_outlined,
        OrbState.speaking => Icons.volume_up_outlined,
      };
}
