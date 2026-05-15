import 'dart:math' as math;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (primaryColor, accentColor, pulseMs, scaleEnd) = switch (orbState) {
      OrbState.idle => (cs.primaryContainer, cs.secondary, 2000, 1.04),
      OrbState.listening => (cs.tertiary, cs.primary, 650, 1.20),
      OrbState.thinking => (cs.secondary, cs.primary, 900, 1.14),
      OrbState.speaking => (cs.primary, cs.secondary, 700, 1.12),
    };

    // Glow colors from stitch-ui: 0 0 40px rgba(177,204,255,0.3) + inset rgba(65,228,192,0.2)
    final glowColor = isDark
        ? primaryColor.withValues(alpha: 0.30)
        : primaryColor.withValues(alpha: 0.25);

    return SizedBox.square(
      dimension: size * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost diffuse glow
          Container(
            width: size * 1.5,
            height: size * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: glowColor.withValues(alpha: 0.06),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(0.85, 0.85),
                end: Offset(scaleEnd * 1.08, scaleEnd * 1.08),
                duration: Duration(milliseconds: (pulseMs * 1.3).round()),
                curve: Curves.easeInOut,
              ),

          // Mid glow ring
          Container(
            width: size * 1.1,
            height: size * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: glowColor.withValues(alpha: 0.10),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(0.95, 0.95),
                end: Offset(scaleEnd, scaleEnd),
                duration: Duration(milliseconds: pulseMs),
                curve: Curves.easeInOut,
              ),

          // Core orb — gradient from stitch-ui orb-glow: radial-gradient(circle at 30% 30%, #a9c7ff, #295ea6)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                colors: isDark
                    ? [
                        const Color(0xFFA9C7FF),
                        const Color(0xFF295EA6),
                      ]
                    : [
                        primaryColor.withValues(alpha: 0.95),
                        cs.primary,
                      ],
              ),
              boxShadow: [
                // Outer glow: rgba(177,204,255,0.3)
                BoxShadow(
                  color: const Color(0xFFB1CCFF).withValues(alpha: 0.30),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
                // Inner teal glow: rgba(65,228,192,0.2)
                BoxShadow(
                  color: const Color(0xFF41E4C0).withValues(alpha: 0.20),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ],
            ),
            // Glass overlay inside the orb
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: Icon(
                _iconFor(orbState),
                color: Colors.white.withValues(alpha: 0.90),
                size: size * 0.35,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(0.97, 0.97),
                end: const Offset(1.02, 1.02),
                duration: Duration(milliseconds: pulseMs),
                curve: Curves.easeInOut,
              ),

          // Accent ring (only for active states)
          if (orbState != OrbState.idle)
            Container(
              width: size * 1.05,
              height: size * 1.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: Offset(scaleEnd * 0.98, scaleEnd * 0.98),
                  duration: Duration(milliseconds: (pulseMs * 0.7).round()),
                  curve: Curves.easeInOut,
                )
                .fadeIn(begin: 0.0, duration: 300.ms),

          // Particle dots for speaking/thinking
          if (orbState == OrbState.speaking || orbState == OrbState.thinking)
            ..._buildParticles(accentColor, size, pulseMs),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(Color color, double size, int pulseMs) {
    const angles = [0.0, 60.0, 120.0, 180.0, 240.0, 300.0];
    final radius = size * 0.60;

    return angles.asMap().entries.map((entry) {
      final i = entry.key;
      final rad = entry.value * math.pi / 180.0;
      final dx = radius * math.cos(rad);
      final dy = radius * math.sin(rad);
      final delayMs = i * (pulseMs ~/ angles.length);

      return Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.75),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        )
            .animate(
              onPlay: (c) => c.repeat(reverse: true),
              delay: Duration(milliseconds: delayMs),
            )
            .scale(
              begin: const Offset(0.3, 0.3),
              end: const Offset(1.4, 1.4),
              duration: Duration(milliseconds: pulseMs ~/ 2),
              curve: Curves.easeInOut,
            )
            .fadeIn(begin: 0.1),
      );
    }).toList();
  }

  IconData _iconFor(OrbState s) => switch (s) {
        OrbState.idle => Icons.home_rounded,
        OrbState.listening => Icons.mic_rounded,
        OrbState.thinking => Icons.psychology_outlined,
        OrbState.speaking => Icons.volume_up_rounded,
      };
}
