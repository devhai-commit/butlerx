import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/tts_service.dart';

part 'tts_provider.g.dart';

final class TtsState {
  const TtsState({
    this.enabled = false,
    this.rate = 0.5,
    this.pitch = 1.0,
    this.isSpeaking = false,
  });

  final bool enabled;
  final double rate;
  final double pitch;
  final bool isSpeaking;

  TtsState copyWith({
    bool? enabled,
    double? rate,
    double? pitch,
    bool? isSpeaking,
  }) =>
      TtsState(
        enabled: enabled ?? this.enabled,
        rate: rate ?? this.rate,
        pitch: pitch ?? this.pitch,
        isSpeaking: isSpeaking ?? this.isSpeaking,
      );
}

@Riverpod(keepAlive: true)
class TtsNotifier extends _$TtsNotifier {
  static const _kEnabled = 'tts_enabled';
  static const _kRate = 'tts_rate';
  static const _kPitch = 'tts_pitch';

  @override
  TtsState build() {
    Future.microtask(_load);
    return const TtsState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = TtsState(
      enabled: prefs.getBool(_kEnabled) ?? false,
      rate: prefs.getDouble(_kRate) ?? 0.5,
      pitch: prefs.getDouble(_kPitch) ?? 1.0,
    );
    final svc = ref.read(ttsServiceProvider);
    await svc.setRate(state.rate);
    await svc.setPitch(state.pitch);
    svc.onComplete(() {
      if (state.isSpeaking) state = state.copyWith(isSpeaking: false);
    });
  }

  Future<void> toggle() async {
    final newEnabled = !state.enabled;
    state = state.copyWith(enabled: newEnabled);
    if (!newEnabled) {
      await ref.read(ttsServiceProvider).stop();
      state = state.copyWith(isSpeaking: false);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, newEnabled);
  }

  Future<void> speak(String text) async {
    if (!state.enabled || text.trim().isEmpty) return;
    state = state.copyWith(isSpeaking: true);
    await ref.read(ttsServiceProvider).speak(text);
  }

  Future<void> speakMessage(String text) => speak(text);

  Future<void> stop() async {
    await ref.read(ttsServiceProvider).stop();
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> setRate(double rate) async {
    state = state.copyWith(rate: rate);
    await ref.read(ttsServiceProvider).setRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kRate, rate);
  }

  Future<void> setPitch(double pitch) async {
    state = state.copyWith(pitch: pitch);
    await ref.read(ttsServiceProvider).setPitch(pitch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kPitch, pitch);
  }
}
