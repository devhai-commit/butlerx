import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../health/presentation/providers/health_notifier.dart';
import '../../data/services/meal_plan_service.dart';
import '../../domain/entities/meal_plan.dart';

part 'meal_plan_notifier.g.dart';

final class MealPlanState {
  const MealPlanState({
    this.plan,
    this.isLoading = false,
    this.error,
  });

  final MealPlan? plan;
  final bool isLoading;
  final String? error;

  MealPlanState copyWith({
    MealPlan? Function()? plan,
    bool? isLoading,
    String? Function()? error,
  }) =>
      MealPlanState(
        plan: plan != null ? plan() : this.plan,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );
}

@riverpod
class MealPlanNotifier extends _$MealPlanNotifier {
  @override
  MealPlanState build() => const MealPlanState();

  Future<void> generate() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    final profile = authState.profile;
    final latestRecord = ref.read(healthNotifierProvider).latest;

    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final plan = await ref.read(mealPlanServiceProvider).generate(
            userId: profile.uid,
            profile: profile,
            latestRecord: latestRecord,
          );
      state = state.copyWith(plan: () => plan, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() => state = state.copyWith(error: () => null);
}
