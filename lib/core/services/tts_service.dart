import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS 음성 읽기 서비스 — 절 단위 읽기 + 현재 절 하이라이트
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
  int _speedIndex = 2;

  // 절 단위 재생 추적
  int _currentVerseIndex = -1;   // 현재 읽고 있는 절 인덱스 (-1 = 미재생)
  List<String> _verseQueue = [];  // 읽을 절 목록
  bool _verseModeActive = false;  // 절 단위 모드 활성화 여부

  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;
  String get speedLabel => _speedLabels[_speedIndex];
  int get currentVerseIndex => _currentVerseIndex;

  static const _speedValues = [0.3, 0.4, 0.5, 0.65, 0.8];
  static const _speedLabels = ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x'];

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage(_language);
    await _tts.setSpeechRate(_speechRate);
    await _tts.setPitch(_pitch);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() {
      if (_verseModeActive) {
        // 다음 절로 이동
        _playNextVerse();
      } else {
        _isPlaying = false;
        _currentVerseIndex = -1;
        notifyListeners();
      }
    });

    _tts.setCancelHandler(() {
      _isPlaying = false;
      _currentVerseIndex = -1;
      _verseModeActive = false;
      _verseQueue = [];
      notifyListeners();
    });

    _initialized = true;
  }

  /// 단일 텍스트 읽기
  Future<void> speak(String text) async {
    await init();
    if (_isPlaying) { await stop(); return; }
    _verseModeActive = false;
    _currentVerseIndex = -1;
    _isPlaying = true;
    notifyListeners();
    await _tts.speak(text);
  }

  /// 절 단위 순차 읽기 (하이라이트 연동)
  Future<void> speakVerses(List<String> verses) async {
    await init();
    if (verses.isEmpty) return;

    _verseQueue = List.from(verses);
    _verseModeActive = true;
    _currentVerseIndex = 0;
    _isPlaying = true;
    notifyListeners();

    await _tts.speak(_verseQueue[0]);
  }

  /// 다음 절 재생 (내부 호출)
  void _playNextVerse() {
    final nextIndex = _currentVerseIndex + 1;
    if (nextIndex < _verseQueue.length) {
      _currentVerseIndex = nextIndex;
      notifyListeners();
      _tts.speak(_verseQueue[nextIndex]);
    } else {
      // 모든 절 읽기 완료
      _isPlaying = false;
      _currentVerseIndex = -1;
      _verseModeActive = false;
      _verseQueue = [];
      notifyListeners();
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    _currentVerseIndex = -1;
    _verseModeActive = false;
    _verseQueue = [];
    notifyListeners();
    await _tts.stop();
  }

  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
    await _tts.pause();
  }

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
