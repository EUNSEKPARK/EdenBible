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

  /// TTS 엔진 사용 가능 여부
  bool _engineAvailable = false;
  bool get engineAvailable => _engineAvailable;

  // 절 단위 재생 추적
  int _currentVerseIndex = -1;
  int _startOffset = 0;          // 선택된 절부터 시작할 때 오프셋
  List<String> _verseQueue = [];
  bool _verseModeActive = false;
  bool _changingSpeed = false; // 배속 변경 중 cancel 핸들러 무시용

  // 단어 단위 하이라이트 추적
  int _wordStart = 0;
  int _wordEnd = 0;

  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;
  String get speedLabel => _speedLabels[_speedIndex];

  /// 현재 읽고 있는 절의 실제 인덱스 (전체 목록 기준)
  int get currentVerseIndex => _currentVerseIndex >= 0 ? _currentVerseIndex + _startOffset : -1;

  /// 현재 읽고 있는 단어의 시작/끝 위치 (절 텍스트 내)
  int get wordStart => _wordStart;
  int get wordEnd => _wordEnd;

  static const _speedValues = [0.3, 0.4, 0.5, 0.65, 0.8, 0.9, 1.0];
  static const _speedLabels = ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '1.75x', '2.0x'];

  Future<void> init() async {
    if (_initialized && _engineAvailable) return;

    try {
      // ── 1. TTS 엔진 존재 여부 확인 ──
      final engines = await _tts.getEngines;
      if (engines == null || (engines as List).isEmpty) {
        debugPrint('[TtsService] ⚠️ TTS 엔진이 설치되어 있지 않습니다.');
        _engineAvailable = false;
        _initialized = true;
        return;
      }
      debugPrint('[TtsService] 사용 가능한 TTS 엔진: $engines');

      // ── 2. 언어 지원 여부 확인 ──
      final langAvailable = await _tts.isLanguageAvailable(_language);
      if (langAvailable != true && langAvailable != 1) {
        debugPrint('[TtsService] ⚠️ "$_language" 언어가 지원되지 않습니다. 사용 가능 여부: $langAvailable');
        // 한국어가 안 되면 영어라도 시도
        if (_language == 'ko-KR') {
          final enAvailable = await _tts.isLanguageAvailable('en-US');
          if (enAvailable == true || enAvailable == 1) {
            debugPrint('[TtsService] 영어(en-US)로 대체합니다.');
            _language = 'en-US';
          } else {
            debugPrint('[TtsService] ⚠️ 영어(en-US)도 지원되지 않습니다.');
            _engineAvailable = false;
            _initialized = true;
            return;
          }
        }
      }

      // ── 3. TTS 설정 적용 ──
      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(1.0);

      // ── 4. 콜백 설정 ──
      _tts.setCompletionHandler(() {
        if (_verseModeActive) {
          _playNextVerse();
        } else {
          _isPlaying = false;
          _currentVerseIndex = -1;
          _startOffset = 0;
          notifyListeners();
        }
      });

      _tts.setCancelHandler(() {
        if (_changingSpeed) return; // 배속 변경 중에는 상태 초기화 방지
        _isPlaying = false;
        _currentVerseIndex = -1;
        _startOffset = 0;
        _wordStart = 0;
        _wordEnd = 0;
        _verseModeActive = false;
        _verseQueue = [];
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        debugPrint('[TtsService] ❌ TTS 에러: $msg');
        _isPlaying = false;
        _currentVerseIndex = -1;
        _startOffset = 0;
        _wordStart = 0;
        _wordEnd = 0;
        _verseModeActive = false;
        _verseQueue = [];
        notifyListeners();
      });

      // 단어 단위 진행 추적 (Android/iOS)
      _tts.setProgressHandler((String text, int start, int end, String word) {
        _wordStart = start;
        _wordEnd = end;
        notifyListeners();
      });

      _engineAvailable = true;
      _initialized = true;
      debugPrint('[TtsService] ✅ TTS 초기화 완료 (언어: $_language)');
    } catch (e) {
      debugPrint('[TtsService] ❌ TTS 초기화 실패: $e');
      _engineAvailable = false;
      _initialized = false; // 재시도 허용
    }
  }

  /// 단일 텍스트 읽기
  Future<void> speak(String text) async {
    await init();
    if (!_engineAvailable) {
      debugPrint('[TtsService] ⚠️ TTS 엔진이 없어 음성을 재생할 수 없습니다.');
      return;
    }
    if (_isPlaying) { await stop(); return; }
    _verseModeActive = false;
    _currentVerseIndex = -1;
    _startOffset = 0;
    _wordStart = 0;
    _wordEnd = 0;
    _isPlaying = true;
    notifyListeners();
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[TtsService] ❌ speak 실패: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// 절 단위 순차 읽기 (하이라이트 연동)
  /// [startOffset]: 전체 절 목록에서의 시작 인덱스 (0-based)
  Future<void> speakVerses(List<String> verses, {int startOffset = 0}) async {
    await init();
    if (!_engineAvailable) {
      debugPrint('[TtsService] ⚠️ TTS 엔진이 없어 음성을 재생할 수 없습니다.');
      return;
    }
    if (verses.isEmpty) return;

    _verseQueue = List.from(verses);
    _verseModeActive = true;
    _currentVerseIndex = 0;
    _startOffset = startOffset;
    _wordStart = 0;
    _wordEnd = 0;
    _isPlaying = true;
    notifyListeners();

    try {
      await _tts.speak(_verseQueue[0]);
    } catch (e) {
      debugPrint('[TtsService] ❌ speakVerses 실패: $e');
      _isPlaying = false;
      _verseModeActive = false;
      _verseQueue = [];
      notifyListeners();
    }
  }

  void _playNextVerse() {
    final nextIndex = _currentVerseIndex + 1;
    if (nextIndex < _verseQueue.length) {
      _currentVerseIndex = nextIndex;
      _wordStart = 0;
      _wordEnd = 0;
      notifyListeners();
      _tts.speak(_verseQueue[nextIndex]);
    } else {
      _isPlaying = false;
      _currentVerseIndex = -1;
      _startOffset = 0;
      _wordStart = 0;
      _wordEnd = 0;
      _verseModeActive = false;
      _verseQueue = [];
      notifyListeners();
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    _currentVerseIndex = -1;
    _startOffset = 0;
    _wordStart = 0;
    _wordEnd = 0;
    _verseModeActive = false;
    _verseQueue = [];
    notifyListeners();
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[TtsService] ❌ stop 실패: $e');
    }
  }

  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
    try {
      await _tts.pause();
    } catch (e) {
      debugPrint('[TtsService] ❌ pause 실패: $e');
    }
  }

  Future<void> cycleSpeed() async {
    _speedIndex = (_speedIndex + 1) % _speedValues.length;
    _speechRate = _speedValues[_speedIndex];
    try {
      await _tts.setSpeechRate(_speechRate);
      // 재생 중이면 현재 절을 새 배속으로 즉시 재시작
      if (_isPlaying && _verseModeActive && _currentVerseIndex >= 0) {
        _changingSpeed = true;
        await _tts.stop();
        _changingSpeed = false;
        _wordStart = 0;
        _wordEnd = 0;
        await _tts.speak(_verseQueue[_currentVerseIndex]);
      }
    } catch (e) {
      debugPrint('[TtsService] ❌ setSpeechRate 실패: $e');
      _changingSpeed = false;
    }
    notifyListeners();
  }

  Future<void> setRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    try {
      await _tts.setSpeechRate(_speechRate);
    } catch (e) {
      debugPrint('[TtsService] ❌ setRate 실패: $e');
    }
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    try {
      await _tts.setLanguage(lang);
    } catch (e) {
      debugPrint('[TtsService] ❌ setLanguage($lang) 실패: $e');
    }
  }

  Future<void> setKorean() => setLanguage('ko-KR');
  Future<void> setEnglish() => setLanguage('en-US');

  /// TTS 엔진이 설치되어 있지 않을 때 안내 메시지 반환
  String? get unavailableMessage {
    if (_initialized && !_engineAvailable) {
      return '음성 읽기를 사용하려면 기기에 TTS 엔진(예: Google TTS)과 한국어 음성 데이터를 설치해 주세요.';
    }
    return null;
  }
}
