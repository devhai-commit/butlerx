import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../widgets/agent_fab.dart';
import '../widgets/voice_agent_overlay.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _TabItem(
      route: AppRoutes.chat,
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Trợ lý',
    ),
    _TabItem(
      route: AppRoutes.schedule,
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Lịch hẹn',
    ),
    _TabItem(
      route: AppRoutes.health,
      icon: Icons.favorite_outline_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Sức khỏe',
    ),
    _TabItem(
      route: AppRoutes.settings,
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Cài đặt',
    ),
  ];

  int _currentIndex(String location) {
    if (location.startsWith(AppRoutes.reminders)) return 1;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.route));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final current = _currentIndex(location);

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: child,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: const AgentFab(),
          bottomNavigationBar: _GlassBottomNav(
            tabs: _tabs,
            currentIndex: current,
            onTabTap: (i) => context.go(_tabs[i].route),
          ),
        ),
        const VoiceAgentOverlay(),
      ],
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _TabItem {
  const _TabItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ─── Glassmorphic Bottom Nav ─────────────────────────────────────────────────

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTabTap,
  });

  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final left = tabs.sublist(0, 2);
    final right = tabs.sublist(2);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1D2024).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  // Left half: Chat, Schedule
                  ...left.asMap().entries.map(
                        (e) => _NavItem(
                          tab: e.value,
                          isActive: currentIndex == e.key,
                          onTap: () => onTabTap(e.key),
                          cs: cs,
                        ),
                      ),
                  // Center gap for FAB
                  const SizedBox(width: 72),
                  // Right half: Health, Settings
                  ...right.asMap().entries.map(
                        (e) => _NavItem(
                          tab: e.value,
                          isActive: currentIndex == e.key + 2,
                          onTap: () => onTabTap(e.key + 2),
                          cs: cs,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.cs,
  });

  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: cs.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? cs.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                color: isActive ? cs.primary : cs.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? cs.primary : cs.onSurfaceVariant,
                letterSpacing: isActive ? 0.2 : 0,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}
