import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/meal_plan.dart';
import '../providers/meal_plan_notifier.dart';

class MealPlanPage extends ConsumerWidget {
  const MealPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealPlanNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    ref.listen(mealPlanNotifierProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: cs.error,
          action: SnackBarAction(
            label: 'OK',
            textColor: cs.onError,
            onPressed: () =>
                ref.read(mealPlanNotifierProvider.notifier).clearError(),
          ),
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn'),
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              tooltip: 'Tạo thực đơn mới',
              onPressed: () =>
                  ref.read(mealPlanNotifierProvider.notifier).generate(),
            ),
        ],
      ),
      body: state.isLoading
          ? _LoadingView()
          : state.plan == null
              ? _EmptyView(
                  onGenerate: () =>
                      ref.read(mealPlanNotifierProvider.notifier).generate(),
                )
              : _PlanView(plan: state.plan!),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Đang tạo thực đơn phù hợp…',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

// ── Empty ─────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onGenerate});
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_outlined,
                size: 72, color: cs.outlineVariant),
            const SizedBox(height: 20),
            Text(
              'Chưa có thực đơn',
              style: tt.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút bên dưới để AI tạo thực đơn 7 ngày dựa trên dữ liệu sức khoẻ của bạn.',
              style: tt.bodyMedium?.copyWith(color: cs.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Tạo thực đơn'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plan View ─────────────────────────────────────────────────────────────────

class _PlanView extends StatelessWidget {
  const _PlanView({required this.plan});
  final MealPlan plan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final genDate =
        '${plan.generatedAt.day.toString().padLeft(2, '0')}/${plan.generatedAt.month.toString().padLeft(2, '0')}/${plan.generatedAt.year}';

    return CustomScrollView(
      slivers: [
        if (plan.healthContext != null)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: cs.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plan.healthContext!,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Cập nhật: $genDate',
              style: tt.labelSmall?.copyWith(color: cs.outline),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList.separated(
          itemCount: plan.days.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _DayCard(meal: plan.days[i]),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 88)),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.meal});
  final DailyMeal meal;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.dayLabel,
              style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: cs.primary),
            ),
            const SizedBox(height: 10),
            _MealRow(icon: Icons.wb_sunny_outlined, label: 'Sáng', value: meal.breakfast),
            const SizedBox(height: 6),
            _MealRow(icon: Icons.light_mode_outlined, label: 'Trưa', value: meal.lunch),
            const SizedBox(height: 6),
            _MealRow(icon: Icons.nights_stay_outlined, label: 'Tối', value: meal.dinner),
            if (meal.snack != null) ...[
              const SizedBox(height: 6),
              _MealRow(
                  icon: Icons.cookie_outlined,
                  label: 'Phụ',
                  value: meal.snack!),
            ],
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.outline),
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: cs.outline)),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
