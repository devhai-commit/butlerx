import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import '../services/stt_service.dart';

part 'stt_provider.g.dart';

final class SttState {
  const SttState({
    this.isListening = false,
    this.transcript = '',
    this.confidence = 0.0,
    this.isAvailable = false,
    this.error,
  });

  final bool isListening;
  final String transcript;
  final double confidence;
  final bool isAvailable;
  final String? error;

  SttState copyWith({
    bool? isListening,
    String? transcript,
    double? confidence,
    bool? isAvailable,
    String? Function()? error,
  }) =>
      SttState(
        isListening: isListening ?? this.isListening,
        transcript: transcript ?? this.transcript,
        confidence: confidence ?? this.confidence,
        isAvailable: isAvailable ?? this.isAvailable,
        error: error != null ? error() : this.error,
      );
}

@Riverpod(keepAlive: true)
class SttNotifier extends _$SttNotifier {
  @override
  SttState build() {
    Future.microtask(_init);
    return const SttState();
  }

  Future<void> _init() async {
    final stt = ref.read(sttServiceProvider);
    final available = await stt.initialize();
    state = state.copyWith(isAvailable: available);
  }

  Future<void> startListening() async {
    final stt = ref.read(sttServiceProvider);
    if (!stt.isAvailable) {
      state = state.copyWith(
        error: () => 'Microphone không khả dụng. Kiểm tra quyền truy cập.',
      );
      return;
    }

    state = state.copyWith(
      isListening: true,
      transcript: '',
      confidence: 0.0,
      error: () => null,
    );

    await stt.startListening(
      onResult: _onResult,
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    state = state.copyWith(
      transcript: result.recognizedWords,
      confidence: result.confidence,
      isListening: !result.finalResult,
    );
  }

  Future<void> stopListening() async {
    final stt = ref.read(sttServiceProvider);
    await stt.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> cancel() async {
    final stt = ref.read(sttServiceProvider);
    await stt.cancel();
    state = state.copyWith(
      isListening: false,
      transcript: '',
    );
  }

  void clearError() => state = state.copyWith(error: () => null);
}
