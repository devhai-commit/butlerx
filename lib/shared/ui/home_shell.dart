import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (route: AppRoutes.chat, icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Trò chuyện'),
    (route: AppRoutes.schedule, icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Lịch hẹn'),
    (route: AppRoutes.health, icon: Icons.favorite_outline, activeIcon: Icons.favorite, label: 'Sức khỏe'),
    (route: AppRoutes.mealPlan, icon: Icons.restaurant_outlined, activeIcon: Icons.restaurant, label: 'Thực đơn'),
    (route: AppRoutes.settings, icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Cài đặt'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexWhere((t) => location.startsWith(t.route));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: current,
        onDestinationSelected: (i) => context.go(_tabs[i].route),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon),
          selectedIcon: Icon(t.activeIcon),
          label: t.label,
        )).toList(),
      ),
    );
  }
}
