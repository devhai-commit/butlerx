import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

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
      if (_available) {
        _patchWindowsTextRecognition();
      }
    } catch (e) {
      debugPrint('STT init failed: $e');
      _available = false;
    }
    return _available;
  }

  // The speech_to_text_windows 1.0.0+beta.8 plugin sends old JSON format:
  //   {"recognizedWords":"text","finalResult":true}
  // But speech_to_text 7.x expects:
  //   {"alternates":[{"recognizedWords":"text","recognizedPhrases":null,"confidence":-1}],"finalResult":true}
  // This patch intercepts and transforms the callback before it reaches the main package.
  void _patchWindowsTextRecognition() {
    final original = SpeechToTextPlatform.instance.onTextRecognition;
    if (original == null) return;
    SpeechToTextPlatform.instance.onTextRecognition = (String json) {
      if (json.isEmpty) return;
      original(_toNewFormat(json));
    };
  }

  String _toNewFormat(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (!map.containsKey('alternates') && map.containsKey('recognizedWords')) {
        return jsonEncode({
          'alternates': [
            {
              'recognizedWords': (map['recognizedWords'] as String?) ?? '',
              'recognizedPhrases': null,
              'confidence': -1.0,
            }
          ],
          'finalResult': (map['finalResult'] as bool?) ?? false,
        });
      }
      return json;
    } catch (_) {
      return json;
    }
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
        cancelOnError: false,
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
