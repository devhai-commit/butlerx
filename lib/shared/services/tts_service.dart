import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_service.g.dart';

@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) => TtsService();

final class TtsService {
  final _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    await _tts.setLanguage('vi-VN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await _init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setRate(double rate) async {
    await _init();
    await _tts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await _init();
    await _tts.setPitch(pitch);
  }

  void onComplete(VoidCallback cb) => _tts.setCompletionHandler(cb);
  void onStart(VoidCallback cb) => _tts.setStartHandler(cb);
}
