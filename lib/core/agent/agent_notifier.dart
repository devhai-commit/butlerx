import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chat/presentation/providers/chat_notifier.dart';
import '../../shared/providers/stt_provider.dart';
import '../../shared/providers/tts_provider.dart';
import 'action_router.dart';
import 'intent_classifier.dart';

enum AgentPhase { idle, listening, processing, speaking }

final class AgentState {
  const AgentState({
    this.phase = AgentPhase.idle,
    this.transcript = '',
    this.response = '',
    this.isVisible = false,
    this.error,
  });

  final AgentPhase phase;
  final String transcript;
  final String response;
  final bool isVisible;
  final String? error;

  AgentState copyWith({
    AgentPhase? phase,
    String? transcript,
    String? response,
    bool? isVisible,
    String? Function()? error,
  }) =>
      AgentState(
        phase: phase ?? this.phase,
        transcript: transcript ?? this.transcript,
        response: response ?? this.response,
        isVisible: isVisible ?? this.isVisible,
        error: error != null ? error() : this.error,
      );
}

final agentNotifierProvider =
    NotifierProvider<AgentNotifier, AgentState>(AgentNotifier.new);

final class AgentNotifier extends Notifier<AgentState> {
  Timer? _autoDismissTimer;

  @override
  AgentState build() {
    ref.onDispose(() => _autoDismissTimer?.cancel());

    // Auto-process when STT stops listening
    ref.listen<SttState>(sttNotifierProvider, (prev, next) {
      if (state.phase != AgentPhase.listening) return;
      if ((prev?.isListening ?? false) && !next.isListening) {
        final transcript = next.transcript.trim();
        if (transcript.isNotEmpty) {
          unawaited(_processTranscript(transcript));
        } else {
          // STT stopped with no speech - show error then auto-dismiss
          state = state.copyWith(
            phase: AgentPhase.idle,
            error: () => 'Không nghe được giọng nói. Nhấn mic để thử lại.',
          );
          _autoDismissTimer?.cancel();
          _autoDismissTimer = Timer(const Duration(seconds: 2), () {
            state = const AgentState();
          });
        }
      }
    });

    // Auto-dismiss when TTS speaking finishes
    ref.listen<TtsState>(ttsNotifierProvider, (prev, next) {
      if (state.phase != AgentPhase.speaking) return;
      if ((prev?.isSpeaking ?? false) && !next.isSpeaking) {
        _autoDismissTimer?.cancel();
        state = state.copyWith(phase: AgentPhase.idle, isVisible: false);
      }
    });

    return const AgentState();
  }

  Future<void> activate() async {
    if (state.phase != AgentPhase.idle) return;

    state = state.copyWith(
      isVisible: true,
      phase: AgentPhase.listening,
      transcript: '',
      response: '',
      error: () => null,
    );

    await ref.read(sttNotifierProvider.notifier).startListening();
  }

  Future<void> stopListening() async {
    if (state.phase != AgentPhase.listening) return;
    await ref.read(sttNotifierProvider.notifier).stopListening();
    // The STT listener in build() will handle the transition
  }

  Future<void> dismiss() async {
    _autoDismissTimer?.cancel();
    await ref.read(sttNotifierProvider.notifier).cancel();
    await ref.read(ttsNotifierProvider.notifier).stop();
    state = const AgentState();
  }

  Future<void> _processTranscript(String transcript) async {
    if (state.phase == AgentPhase.processing ||
        state.phase == AgentPhase.speaking) {
      return;
    }

    state = state.copyWith(
      phase: AgentPhase.processing,
      transcript: transcript,
      error: () => null,
    );

    try {
      final classifier = ref.read(intentClassifierProvider);
      final result = await classifier.classify(transcript);

      // For chat intent, route to the chat feature and dismiss overlay
      if (result.intent == AgentIntent.chat) {
        unawaited(
          ref.read(chatNotifierProvider.notifier).sendMessage(transcript),
        );
        state = state.copyWith(phase: AgentPhase.idle, isVisible: false);
        return;
      }

      final response = await ActionRouter(ref).route(result);

      state = state.copyWith(
        phase: AgentPhase.speaking,
        response: response,
      );

      unawaited(ref.read(ttsNotifierProvider.notifier).speak(response));

      // Timer fallback: dismiss after estimated reading time
      // (the TTS listener in build() will cancel this if TTS fires first)
      final wordCount = response.split(' ').length;
      _autoDismissTimer?.cancel();
      _autoDismissTimer = Timer(
        Duration(milliseconds: 3000 + wordCount * 150),
        () {
          if (state.phase == AgentPhase.speaking) {
            state = state.copyWith(phase: AgentPhase.idle, isVisible: false);
          }
        },
      );
    } on Exception catch (e) {
      state = state.copyWith(
        phase: AgentPhase.idle,
        error: () => e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
