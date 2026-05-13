import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

part 'stt_service.g.dart';

@Riverpod(keepAlive: true)
SttService sttService(Ref ref) => SttService();

final class SttService {
  final _stt = SpeechToText();
  bool _initialized = false;
  bool _available = false;

  bool get isAvailable => _available;
  bool get isListening => _stt.isListening;

  Future<bool> initialize() async {
    if (_initialized) return _available;
    try {
      _available = await _stt.initialize(
        onError: (error) {
          debugPrint('STT error: ${error.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('STT status: $status');
        },
      );
      _initialized = true;
    } catch (e) {
      debugPrint('STT init failed: $e');
      _available = false;
    }
    return _available;
  }

  Future<void> startListening({
    required void Function(SpeechRecognitionResult result) onResult,
    String localeId = 'vi-VN',
    Duration? listenFor,
  }) async {
    if (!_initialized) await initialize();
    if (!_available) return;

    await _stt.listen(
      onResult: onResult,
      localeId: localeId,
      listenFor: listenFor ?? const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_stt.isListening) {
      await _stt.stop();
    }
  }

  Future<void> cancel() async {
    if (_stt.isListening) {
      await _stt.cancel();
    }
  }
}
