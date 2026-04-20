import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../providers/onboarding_provider.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return PopScope(
      canPop: state.step == 0,
      onPopInvoked: (didPop) {
        if (!didPop) notifier.prevStep();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _ProgressBar(current: state.step, total: OnboardingState.totalSteps),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppConstants.animNormal,
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween(
                      begin: const Offset(0.2, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(state.step),
                    child: _stepWidget(state.step, state, notifier),
                  ),
                ),
              ),
              _BottomNav(state: state, notifier: notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepWidget(int step, OnboardingState state, OnboardingNotifier notifier) =>
      switch (step) {
        0 => _NameStep(name: state.displayName, onChanged: notifier.setName),
        1 => _BirthdateStep(selected: state.birthdate, onChanged: notifier.setBirthdate),
        2 => _GenderStep(selected: state.gender, onChanged: notifier.setGender),
        3 => _AddressTitleStep(selected: state.addressTitle, onChanged: notifier.setAddressTitle),
        4 => _PersonalityStep(selected: state.personalityTag, onChanged: notifier.setPersonality),
        _ => const SizedBox.shrink(),
      };
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bước ${current + 1}/$total', style: TextStyle(color: cs.outline, fontSize: 13)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (current + 1) / total,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav({required this.state, required this.notifier});
  final OnboardingState state;
  final OnboardingNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLast = state.step == OnboardingState.totalSteps - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: isLast ? 'Bắt đầu' : 'Tiếp tục',
            isLoading: state.isSaving,
            onPressed: state.canAdvance
                ? () async {
                    if (isLast) {
                      await notifier.complete();
                      if (context.mounted) context.go(AppRoutes.chat);
                    } else {
                      notifier.nextStep();
                    }
                  }
                : null,
          ),
          if (state.step > 0) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: notifier.prevStep,
              child: const Text('Quay lại'),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Step 0: Name ────────────────────────────────────────────────────────────

class _NameStep extends StatefulWidget {
  const _NameStep({required this.name, required this.onChanged});
  final String name;
  final ValueChanged<String> onChanged;

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.person_outline,
      title: 'Xin chào! Tôi là ButlerX',
      subtitle: 'Hãy để tôi làm quen với bạn nhé',
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Tên của bạn',
          hintText: 'Ví dụ: Minh, Hoa, An...',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
      ),
    );
  }
}

// ─── Step 1: Birthdate ───────────────────────────────────────────────────────

class _BirthdateStep extends StatelessWidget {
  const _BirthdateStep({required this.selected, required this.onChanged});
  final DateTime? selected;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selected ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = selected != null
        ? '${selected!.day}/${selected!.month}/${selected!.year}'
        : 'Chọn ngày sinh';

    return _StepScaffold(
      icon: Icons.cake_outlined,
      title: 'Ngày sinh của bạn?',
      subtitle: 'Tôi sẽ nhớ ngày đặc biệt này',
      child: InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: selected != null ? cs.primary : cs.outline),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: selected != null ? cs.primary : cs.outline),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: selected != null ? cs.onSurface : cs.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step 2: Gender ──────────────────────────────────────────────────────────

class _GenderStep extends StatelessWidget {
  const _GenderStep({required this.selected, required this.onChanged});
  final Gender? selected;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.wc_outlined,
      title: 'Giới tính của bạn?',
      subtitle: 'Tôi sẽ xưng hô phù hợp hơn',
      child: Column(
        children: Gender.values.map((g) {
          final (label, icon) = switch (g) {
            Gender.male => ('Nam', Icons.male),
            Gender.female => ('Nữ', Icons.female),
            Gender.other => ('Khác', Icons.transgender),
          };
          return _SelectCard(
            label: label,
            icon: icon,
            selected: selected == g,
            onTap: () => onChanged(g),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 3: Address Title ───────────────────────────────────────────────────

class _AddressTitleStep extends StatelessWidget {
  const _AddressTitleStep({required this.selected, required this.onChanged});
  final AddressTitle? selected;
  final ValueChanged<AddressTitle> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.record_voice_over_outlined,
      title: 'Bạn muốn tôi xưng hô thế nào?',
      subtitle: 'Tôi sẽ gọi bạn là...',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: AddressTitle.values.map((t) {
          final isSelected = selected == t;
          return _ChipCard(
            label: t.label,
            selected: isSelected,
            onTap: () => onChanged(t),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 4: Personality ─────────────────────────────────────────────────────

class _PersonalityStep extends StatelessWidget {
  const _PersonalityStep({required this.selected, required this.onChanged});
  final PersonalityTag? selected;
  final ValueChanged<PersonalityTag> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.psychology_outlined,
      title: 'Bạn muốn tôi như thế nào?',
      subtitle: 'Tôi sẽ điều chỉnh cách trò chuyện',
      child: Column(
        children: PersonalityTag.values.map((p) {
          final (icon, desc) = switch (p) {
            PersonalityTag.formal => (Icons.business_outlined, 'Lịch sự, trang trọng, chuyên nghiệp'),
            PersonalityTag.warm => (Icons.favorite_outline, 'Thân thiện, ấm áp, quan tâm'),
            PersonalityTag.playful => (Icons.emoji_emotions_outlined, 'Vui vẻ, hài hước, dí dỏm'),
          };
          return _SelectCard(
            label: p.label,
            icon: icon,
            description: desc,
            selected: selected == p,
            onTap: () => onChanged(p),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: cs.primary, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: cs.outline, fontSize: 15)),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.description,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surface,
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? cs.primary : cs.outline, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  if (description != null)
                    Text(description!, style: TextStyle(fontSize: 13, color: cs.outline)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

class _ChipCard extends StatelessWidget {
  const _ChipCard({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: selected ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}
