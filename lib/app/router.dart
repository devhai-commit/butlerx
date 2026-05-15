import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/health/presentation/pages/health_page.dart';
import '../features/meal_plan/presentation/pages/meal_plan_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/reminders/presentation/pages/reminders_page.dart';
import '../features/scheduling/presentation/pages/schedule_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../shared/ui/home_shell.dart';

part 'router.g.dart';

/// Guards the splash screen from being dismissed before its animation completes.
final splashCompleteProvider = StateProvider<bool>((ref) => false);

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
  static const String reminders = '/home/reminders';
  static const String settings = '/home/settings';
}

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final loc = state.uri.toString();

      // Keep splash visible until animation completes (min ~2.2s)
      if (loc == AppRoutes.splash && !ref.read(splashCompleteProvider)) {
        return null;
      }

      final authStatus = ref.read(authNotifierProvider);
      final isAuth = authStatus is AuthAuthenticated;
      final onboardingDone =
          isAuth ? authStatus.profile.onboardingComplete : false;

      if (authStatus is AuthLoading) return null;

      if (!isAuth) {
        if (loc == AppRoutes.login || loc == AppRoutes.register) return null;
        return AppRoutes.login;
      }

      if (!onboardingDone) {
        if (loc == AppRoutes.onboarding) return null;
        return AppRoutes.onboarding;
      }

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
            path: AppRoutes.reminders,
            builder: (_, __) => const RemindersPage(),
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
    ref.listen(splashCompleteProvider, (_, __) => notifyListeners());
  }
}

// ─── Splash Screen ───────────────────────────────────────────────────────────

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Signal router to allow navigation after animation completes
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      ref.read(splashCompleteProvider.notifier).state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.6,
            colors: [
              cs.primaryContainer.withValues(alpha: isDark ? 0.5 : 0.35),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Glowing logo
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.45),
                      blurRadius: 48,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: cs.tertiary.withValues(alpha: 0.2),
                      blurRadius: 80,
                      spreadRadius: 16,
                    ),
                  ],
                ),
                child: Icon(Icons.home_rounded, size: 62, color: cs.onPrimary),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.15, 0.15),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // App name
              Text(
                'ButlerX',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                    ),
              )
                  .animate()
                  .slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 550.ms,
                    delay: 350.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: 450.ms, delay: 350.ms),

              const SizedBox(height: 10),

              // Tagline
              Text(
                'Trợ lý gia đình thông minh',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: cs.outline,
                      letterSpacing: 0.4,
                    ),
              )
                  .animate()
                  .slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 550.ms,
                    delay: 550.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: 450.ms, delay: 550.ms),

              const Spacer(flex: 3),

              // Loading progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor:
                        cs.primaryContainer.withValues(alpha: 0.5),
                    color: cs.primary,
                    minHeight: 3,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 900.ms),

              const SizedBox(height: 52),
            ],
          ),
        ),
      ),
    );
  }
}
