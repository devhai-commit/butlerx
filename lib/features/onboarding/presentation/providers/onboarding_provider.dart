import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'onboarding_provider.g.dart';

final class OnboardingState {
  const OnboardingState({
    this.step = 0,
    this.displayName = '',
    this.birthdate,
    this.gender,
    this.addressTitle,
    this.personalityTag,
    this.isSaving = false,
  });

  final int step;
  final String displayName;
  final DateTime? birthdate;
  final Gender? gender;
  final AddressTitle? addressTitle;
  final PersonalityTag? personalityTag;
  final bool isSaving;

  static const int totalSteps = 5;

  bool get canAdvance => switch (step) {
        0 => displayName.trim().isNotEmpty,
        1 => birthdate != null,
        2 => gender != null,
        3 => addressTitle != null,
        4 => personalityTag != null,
        _ => false,
      };

  OnboardingState copyWith({
    int? step,
    String? displayName,
    DateTime? birthdate,
    Gender? gender,
    AddressTitle? addressTitle,
    PersonalityTag? personalityTag,
    bool? isSaving,
  }) =>
      OnboardingState(
        step: step ?? this.step,
        displayName: displayName ?? this.displayName,
        birthdate: birthdate ?? this.birthdate,
        gender: gender ?? this.gender,
        addressTitle: addressTitle ?? this.addressTitle,
        personalityTag: personalityTag ?? this.personalityTag,
        isSaving: isSaving ?? this.isSaving,
      );
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void setName(String name) => state = state.copyWith(displayName: name);
  void setBirthdate(DateTime date) => state = state.copyWith(birthdate: date);
  void setGender(Gender g) => state = state.copyWith(gender: g);
  void setAddressTitle(AddressTitle t) => state = state.copyWith(addressTitle: t);
  void setPersonality(PersonalityTag p) => state = state.copyWith(personalityTag: p);

  void nextStep() {
    if (state.step < OnboardingState.totalSteps - 1) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void prevStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  Future<void> complete() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    state = state.copyWith(isSaving: true);
    final updated = authState.profile.copyWith(
      displayName: state.displayName.trim(),
      birthdate: state.birthdate,
      gender: state.gender,
      addressTitle: state.addressTitle,
      personalityTag: state.personalityTag,
      onboardingComplete: true,
    );
    await ref.read(authNotifierProvider.notifier).updateProfile(updated);
    state = state.copyWith(isSaving: false);
  }
}
