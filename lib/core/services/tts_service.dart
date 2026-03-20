import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS(Text-to-Speech) 음성 읽기 서비스 — 오프라인 동작
class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isPlaying = false;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  String _language = 'ko-KR';
  int _speedIndex = 2; // 기본 1.0x

  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;
  String get speedLabel => _speedLabels[_speedIndex];

  /// 배속 옵션: 0.5x ~ 2.0x
  static const _speedValues = [0.3, 0.4, 0.5, 0.65, 0.8];
  static const _speedLabels = ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x'];

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage(_language);
    await _tts.setSpeechRate(_speechRate);
    await _tts.setPitch(_pitch);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() {
      _isPlaying = false;
      notifyListeners();
    });

    _tts.setCancelHandler(() {
      _isPlaying = false;
      notifyListeners();
    });

    _initialized = true;
  }

  Future<void> speak(String text) async {
    await init();
    if (_isPlaying) { await stop(); return; }
    _isPlaying = true;
    notifyListeners();
    await _tts.speak(text);
  }

  Future<void> speakVerses(List<String> verses) async {
    await init();
    final fullText = verses.join('. ');
    _isPlaying = true;
    notifyListeners();
    await _tts.speak(fullText);
  }

  Future<void> stop() async {
    _isPlaying = false;
    notifyListeners();
    await _tts.stop();
  }

  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
    await _tts.pause();
  }

  /// 배속 순환 (0.5x → 0.75x → 1.0x → 1.25x → 1.5x → 0.5x)
  Future<void> cycleSpeed() async {
    _speedIndex = (_speedIndex + 1) % _speedValues.length;
    _speechRate = _speedValues[_speedIndex];
    await _tts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  Future<void> setRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _tts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _tts.setLanguage(lang);
  }

  Future<void> setKorean() => setLanguage('ko-KR');
  Future<void> setEnglish() => setLanguage('en-US');
}
