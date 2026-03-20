import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 설정 관리 서비스
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._();
  factory SettingsService() => _instance;
  SettingsService._();

  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 20.0;
  String _translation = 'krv';
  String _dailyVerseTime = '07:30';
  List<String> _bookmarks = [];

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  String get translation => _translation;
  String get dailyVerseTime => _dailyVerseTime;
  List<String> get bookmarks => List.unmodifiable(_bookmarks);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    final themeModeStr = _prefs?.getString('themeMode') ?? 'system';
    _themeMode = {'light': ThemeMode.light, 'dark': ThemeMode.dark, 'system': ThemeMode.system}[themeModeStr] ?? ThemeMode.system;
    _fontSize = _prefs?.getDouble('fontSize') ?? 20.0;
    _translation = _prefs?.getString('translation') ?? 'krv';
    _dailyVerseTime = _prefs?.getString('dailyVerseTime') ?? '07:30';
    _bookmarks = _prefs?.getStringList('bookmarks') ?? [];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final str = mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system';
    await _prefs?.setString('themeMode', str);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(14.0, 32.0);
    await _prefs?.setDouble('fontSize', _fontSize);
    notifyListeners();
  }

  Future<void> setTranslation(String t) async {
    _translation = t;
    await _prefs?.setString('translation', t);
    notifyListeners();
  }

  Future<void> setDailyVerseTime(String time) async {
    _dailyVerseTime = time;
    await _prefs?.setString('dailyVerseTime', time);
    notifyListeners();
  }

  // ─── 북마크 관리 ───
  String _bookmarkKey(int bookId, int chapter, int verse) => '$bookId:$chapter:$verse';
  bool isBookmarked(int bookId, int chapter, int verse) => _bookmarks.contains(_bookmarkKey(bookId, chapter, verse));

  Future<void> toggleBookmark(int bookId, int chapter, int verse) async {
    final key = _bookmarkKey(bookId, chapter, verse);
    _bookmarks.contains(key) ? _bookmarks.remove(key) : _bookmarks.add(key);
    await _prefs?.setStringList('bookmarks', _bookmarks);
    notifyListeners();
  }

  List<List<int>> get parsedBookmarks {
    return _bookmarks.map((key) => key.split(':').map(int.parse).toList()).toList();
  }

  // ─── 읽기 기록 ───
  Future<void> setLastRead(int bookId, int chapter) async {
    await _prefs?.setInt('lastReadBookId', bookId);
    await _prefs?.setInt('lastReadChapter', chapter);
    await _updateStreak();
  }

  int get lastReadBookId => _prefs?.getInt('lastReadBookId') ?? 1;
  int get lastReadChapter => _prefs?.getInt('lastReadChapter') ?? 1;

  Future<void> markChapterRead(int bookId, int chapter) async {
    await _prefs?.setBool('read_${bookId}_$chapter', true);
    notifyListeners();
  }

  bool isChapterRead(int bookId, int chapter) => _prefs?.getBool('read_${bookId}_$chapter') ?? false;

  double get readingProgress {
    int totalChapters = 0, readChapters = 0;
    final cc = [50,40,27,36,34,24,21,4,31,24,22,25,29,36,10,13,10,42,150,31,12,8,66,52,5,48,12,14,3,9,1,4,7,3,3,3,2,14,4,28,16,24,21,28,16,16,13,6,6,4,4,5,3,6,4,3,1,13,5,5,3,5,1,1,1,22];
    for (int i = 0; i < cc.length; i++) {
      for (int ch = 1; ch <= cc[i]; ch++) {
        totalChapters++;
        if (isChapterRead(i + 1, ch)) readChapters++;
      }
    }
    return totalChapters > 0 ? readChapters / totalChapters : 0.0;
  }

  // ─── 연속 읽기 Streak ───
  int get streakDays => _prefs?.getInt('streakDays') ?? 0;
  String get _lastReadDate => _prefs?.getString('lastReadDate') ?? '';

  Future<void> _updateStreak() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastDate = _lastReadDate;
    if (lastDate == todayStr) return;
    if (lastDate.isNotEmpty) {
      final last = DateTime.tryParse(lastDate);
      if (last != null) {
        final diff = today.difference(last).inDays;
        await _prefs?.setInt('streakDays', diff == 1 ? streakDays + 1 : 1);
      } else {
        await _prefs?.setInt('streakDays', 1);
      }
    } else {
      await _prefs?.setInt('streakDays', 1);
    }
    await _prefs?.setString('lastReadDate', todayStr);
    notifyListeners();
  }

  // ─── P3-02: 감정 사용 히스토리 (패턴 학습) ───

  /// 감정 카테고리 선택 기록 (최근 30개)
  Future<void> recordEmotionTap(String categoryId) async {
    final history = _prefs?.getStringList('emotionHistory') ?? [];
    history.insert(0, categoryId);
    if (history.length > 30) history.removeRange(30, history.length);
    await _prefs?.setStringList('emotionHistory', history);
    notifyListeners();
  }

  /// 가장 많이 선택한 감정 TOP 3
  List<String> get topEmotions {
    final history = _prefs?.getStringList('emotionHistory') ?? [];
    if (history.isEmpty) return [];
    final counts = <String, int>{};
    for (final id in history) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// 감정 히스토리 전체
  List<String> get emotionHistory => _prefs?.getStringList('emotionHistory') ?? [];

  // ─── P3-01: 수면 모드 설정 ───

  /// 수면 타이머 (분)
  int get sleepTimerMinutes => _prefs?.getInt('sleepTimerMinutes') ?? 30;

  Future<void> setSleepTimerMinutes(int minutes) async {
    await _prefs?.setInt('sleepTimerMinutes', minutes);
    notifyListeners();
  }

  /// 앱 데이터 초기화
  Future<void> resetAllData() async {
    await _prefs?.clear();
    _loadSettings();
    notifyListeners();
  }
}
