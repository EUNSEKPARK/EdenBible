import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 설정 관리 서비스
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._();
  factory SettingsService() => _instance;
  SettingsService._();

  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 22.0;
  double _lineHeight = 1.8;
  String _translation = 'krv';
  String _dailyVerseTime = '07:30';
  List<String> _bookmarks = [];

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;
  String get translation => _translation;
  String get dailyVerseTime => _dailyVerseTime;
  List<String> get bookmarks => List.unmodifiable(_bookmarks);

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadSettings();
    } catch (e, stack) {
      // SharedPreferences 초기화 실패 시 기본값으로 동작 (앱 크래시 방지)
      debugPrint('SettingsService 초기화 실패: $e\n$stack');
      _prefs = null;
    }
  }

  void _loadSettings() {
    final themeModeStr = _prefs?.getString('themeMode') ?? 'system';
    _themeMode = {'light': ThemeMode.light, 'dark': ThemeMode.dark, 'system': ThemeMode.system}[themeModeStr] ?? ThemeMode.system;
    _fontSize = _prefs?.getDouble('fontSize') ?? 22.0;
    _lineHeight = _prefs?.getDouble('lineHeight') ?? 1.8;
    _translation = _prefs?.getString('translation') ?? 'krv';
    _dailyVerseTime = _prefs?.getString('dailyVerseTime') ?? '07:30';
    _bookmarks = _prefs?.getStringList('bookmarks') ?? [];
  }

  // ─── 프로필 ───
  String get nickname => _prefs?.getString('nickname') ?? '';
  String get profileImagePath => _prefs?.getString('profileImagePath') ?? '';
  Future<void> setNickname(String name) async { await _prefs?.setString('nickname', name.trim()); notifyListeners(); }
  Future<void> setProfileImagePath(String path) async { await _prefs?.setString('profileImagePath', path); notifyListeners(); }

  // ─── 테마 ───
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final str = mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system';
    await _prefs?.setString('themeMode', str); notifyListeners();
  }

  Future<void> setFontSize(double size) async { _fontSize = size.clamp(14.0, 48.0); await _prefs?.setDouble('fontSize', _fontSize); notifyListeners(); }
  Future<void> setLineHeight(double h) async { _lineHeight = h.clamp(1.4, 2.6); await _prefs?.setDouble('lineHeight', _lineHeight); notifyListeners(); }
  Future<void> setTranslation(String t) async { _translation = t; await _prefs?.setString('translation', t); notifyListeners(); }
  Future<void> setDailyVerseTime(String time) async { _dailyVerseTime = time; await _prefs?.setString('dailyVerseTime', time); notifyListeners(); }

  // ─── 읽기 목표 ───
  int get dailyGoalChapters => _prefs?.getInt('dailyGoalChapters') ?? 3;
  Future<void> setDailyGoalChapters(int n) async { await _prefs?.setInt('dailyGoalChapters', n.clamp(1, 20)); notifyListeners(); }

  int get todayReadChapters { final today = _todayStr; return _prefs?.getInt('todayRead_$today') ?? 0; }

  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ─── 북마크 ───
  String _bookmarkKey(int bookId, int chapter, int verse) => '$bookId:$chapter:$verse';
  bool isBookmarked(int bookId, int chapter, int verse) => _bookmarks.contains(_bookmarkKey(bookId, chapter, verse));

  Future<void> toggleBookmark(int bookId, int chapter, int verse) async {
    final key = _bookmarkKey(bookId, chapter, verse);
    _bookmarks.contains(key) ? _bookmarks.remove(key) : _bookmarks.add(key);
    await _prefs?.setStringList('bookmarks', _bookmarks); notifyListeners();
  }

  List<List<int>> get parsedBookmarks => _bookmarks.map((key) => key.split(':').map(int.parse).toList()).toList();

  // ─── 읽기 기록 ───
  Future<void> setLastRead(int bookId, int chapter) async {
    await _prefs?.setInt('lastReadBookId', bookId);
    await _prefs?.setInt('lastReadChapter', chapter);
    await _updateStreak();
  }

  int get lastReadBookId => _prefs?.getInt('lastReadBookId') ?? 1;
  int get lastReadChapter => _prefs?.getInt('lastReadChapter') ?? 1;

  Future<void> markChapterRead(int bookId, int chapter) async {
    final key = 'read_${bookId}_$chapter';
    final alreadyRead = _prefs?.getBool(key) ?? false;
    await _prefs?.setBool(key, true);
    if (!alreadyRead) {
      final todayKey = 'todayRead_${_todayStr}';
      final current = _prefs?.getInt(todayKey) ?? 0;
      await _prefs?.setInt(todayKey, current + 1);
      final total = _prefs?.getInt('totalChaptersRead') ?? 0;
      await _prefs?.setInt('totalChaptersRead', total + 1);
    }
    notifyListeners();
  }

  /// 장 읽음 취소 (통독표에서 길게 눌러서 되돌리기)
  Future<void> unmarkChapterRead(int bookId, int chapter) async {
    final key = 'read_${bookId}_$chapter';
    final wasRead = _prefs?.getBool(key) ?? false;
    if (wasRead) {
      await _prefs?.remove(key);
      final total = _prefs?.getInt('totalChaptersRead') ?? 0;
      if (total > 0) await _prefs?.setInt('totalChaptersRead', total - 1);
    }
    notifyListeners();
  }

  bool isChapterRead(int bookId, int chapter) => _prefs?.getBool('read_${bookId}_$chapter') ?? false;
  int get totalChaptersRead => _prefs?.getInt('totalChaptersRead') ?? 0;

  /// 성경 66권 각 장 수
  static const chapterCounts = [50,40,27,36,34,24,21,4,31,24,22,25,29,36,10,13,10,42,150,31,12,8,66,52,5,48,12,14,3,9,1,4,7,3,3,3,2,14,4,28,16,24,21,28,16,16,13,6,6,4,4,5,3,6,4,3,1,13,5,5,3,5,1,1,1,22];
  static const totalBibleChapters = 1189;

  double get readingProgress {
    int read = 0;
    for (int i = 0; i < chapterCounts.length; i++) {
      for (int ch = 1; ch <= chapterCounts[i]; ch++) { if (isChapterRead(i + 1, ch)) read++; }
    }
    return read / totalBibleChapters;
  }

  int get readChaptersCount {
    int count = 0;
    for (int i = 0; i < chapterCounts.length; i++) {
      for (int ch = 1; ch <= chapterCounts[i]; ch++) { if (isChapterRead(i + 1, ch)) count++; }
    }
    return count;
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
      if (last != null) { await _prefs?.setInt('streakDays', today.difference(last).inDays == 1 ? streakDays + 1 : 1); }
      else { await _prefs?.setInt('streakDays', 1); }
    } else { await _prefs?.setInt('streakDays', 1); }
    await _prefs?.setString('lastReadDate', todayStr); notifyListeners();
  }

  // ─── 감정 사용 히스토리 ───
  Future<void> recordEmotionTap(String categoryId) async {
    final history = _prefs?.getStringList('emotionHistory') ?? [];
    history.insert(0, categoryId);
    if (history.length > 30) history.removeRange(30, history.length);
    await _prefs?.setStringList('emotionHistory', history); notifyListeners();
  }

  List<String> get topEmotions {
    final history = _prefs?.getStringList('emotionHistory') ?? [];
    if (history.isEmpty) return [];
    final counts = <String, int>{};
    for (final id in history) { counts[id] = (counts[id] ?? 0) + 1; }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  List<String> get emotionHistory => _prefs?.getStringList('emotionHistory') ?? [];

  // ─── 튜토리얼 ───
  bool get hasSeenTutorial => _prefs?.getBool('hasSeenTutorial') ?? false;
  Future<void> completeTutorial() async { await _prefs?.setBool('hasSeenTutorial', true); notifyListeners(); }
  Future<void> resetTutorial() async { await _prefs?.setBool('hasSeenTutorial', false); notifyListeners(); }

  // ─── 수면 모드 ───
  int get sleepTimerMinutes => _prefs?.getInt('sleepTimerMinutes') ?? 30;
  Future<void> setSleepTimerMinutes(int minutes) async { await _prefs?.setInt('sleepTimerMinutes', minutes); notifyListeners(); }

  // ═══════════════════════════════════════════════════
  //  읽기 플랜 (통독표)
  // ═══════════════════════════════════════════════════

  String get readingPlanType => _prefs?.getString('readingPlanType') ?? 'none';
  String get readingPlanStartDate => _prefs?.getString('readingPlanStartDate') ?? '';
  bool get hasReadingPlan => readingPlanType != 'none' && readingPlanStartDate.isNotEmpty;

  Future<void> startReadingPlan(String planType) async {
    await _prefs?.setString('readingPlanType', planType);
    await _prefs?.setString('readingPlanStartDate', DateTime.now().toIso8601String());
    notifyListeners();
  }

  Future<void> cancelReadingPlan() async {
    await _prefs?.setString('readingPlanType', 'none');
    await _prefs?.setString('readingPlanStartDate', '');
    notifyListeners();
  }

  int get planTotalDays {
    switch (readingPlanType) {
      case '1year': return 365; case '6month': return 180; case '3month': return 90; default: return 365;
    }
  }

  int get planElapsedDays {
    if (!hasReadingPlan) return 0;
    final start = DateTime.tryParse(readingPlanStartDate);
    if (start == null) return 0;
    return DateTime.now().difference(start).inDays + 1;
  }

  int get planDailyChapters => (totalBibleChapters / planTotalDays).ceil();

  int get planExpectedChapters {
    final expected = planElapsedDays * planDailyChapters;
    return expected > totalBibleChapters ? totalBibleChapters : expected;
  }

  double get planScheduleProgress {
    if (!hasReadingPlan || planExpectedChapters == 0) return 0.0;
    return (readChaptersCount / planExpectedChapters).clamp(0.0, 1.5);
  }

  double get planOverallProgress => readChaptersCount / totalBibleChapters;
  int get planRemainingDays { final r = planTotalDays - planElapsedDays; return r > 0 ? r : 0; }
  int get planRemainingChapters { final r = totalBibleChapters - readChaptersCount; return r > 0 ? r : 0; }

  String get planLabel {
    switch (readingPlanType) {
      case '1year': return '1년 통독'; case '6month': return '6개월 통독'; case '3month': return '3개월 통독'; default: return '자유 읽기';
    }
  }

  // ─── 데이터 초기화 ───
  Future<void> resetAllData() async {
    final name = nickname; final img = profileImagePath;
    await _prefs?.clear();
    if (name.isNotEmpty) await _prefs?.setString('nickname', name);
    if (img.isNotEmpty) await _prefs?.setString('profileImagePath', img);
    _loadSettings(); notifyListeners();
  }
}
