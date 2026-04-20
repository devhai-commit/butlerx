import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/health/presentation/pages/health_page.dart';
import '../features/meal_plan/presentation/pages/meal_plan_page.dart';
import '../features/scheduling/presentation/pages/schedule_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../shared/ui/home_shell.dart';

part 'router.g.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String chat = '/home/chat';
  static const String schedule = '/home/schedule';
  static const String health = '/home/health';
  static const String mealPlan = '/home/meal-plan';
  static const String settings = '/home/settings';
}

@riverpod
GoRouter router(Ref ref) {

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authStatus = ref.read(authNotifierProvider);
      final isAuth = authStatus is AuthAuthenticated;
      final onboardingDone =
          isAuth ? authStatus.profile.onboardingComplete : false;

      final loc = state.uri.toString();

      // While loading an explicit action, stay where we are.
      if (authStatus is AuthLoading) return null;

      if (!isAuth) {
        if (loc == AppRoutes.login || loc == AppRoutes.register) return null;
        return AppRoutes.login;
      }

      // Authenticated but onboarding incomplete
      if (!onboardingDone) {
        if (loc == AppRoutes.onboarding) return null;
        return AppRoutes.onboarding;
      }

      // Authenticated & onboarding done — redirect from auth pages
      if (loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.onboarding ||
          loc == AppRoutes.splash) {
        return AppRoutes.chat;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.chat,
            builder: (_, __) => const ChatPage(),
          ),
          GoRoute(
            path: AppRoutes.schedule,
            builder: (_, __) => const SchedulePage(),
          ),
          GoRoute(
            path: AppRoutes.health,
            builder: (_, __) => const HealthPage(),
          ),
          GoRoute(
            path: AppRoutes.mealPlan,
            builder: (_, __) => const MealPlanPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, __) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.home_rounded, size: 56, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text('ButlerX', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Trợ lý gia đình thông minh', style: TextStyle(color: cs.outline, fontSize: 16)),
            const SizedBox(height: 40),
            CircularProgressIndicator(color: cs.primary),
          ],
        ),
      ),
    );
  }
}

