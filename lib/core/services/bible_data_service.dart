import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bible_verse.dart';

/// 성경 데이터 로드 및 검색 서비스
class BibleDataService {
  static final BibleDataService _instance = BibleDataService._();
  factory BibleDataService() => _instance;
  BibleDataService._();

  List<BibleBook> _books = [];
  Map<int, List<List<Map<String, dynamic>>>> _chapters = {};
  bool _loaded = false;

  List<BibleBook> get books => _books;
  bool get isLoaded => _loaded;

  Future<void> loadBibleData() async {
    if (_loaded) return;

    try {
      final indexJson = await rootBundle.loadString('assets/data/books_index.json');
      final indexData = json.decode(indexJson) as Map<String, dynamic>;
      _books = (indexData['books'] as List)
          .map((b) => BibleBook.fromJson(b as Map<String, dynamic>))
          .toList();

      final bibleJson = await rootBundle.loadString('assets/data/bible_full.json');
      final bibleData = json.decode(bibleJson) as Map<String, dynamic>;
      final booksData = bibleData['books'] as List;

      for (final book in booksData) {
        final bookId = book['id'] as int;
        final chapters = <List<Map<String, dynamic>>>[];

        for (final chapter in (book['chapters'] as List)) {
          final verses = <Map<String, dynamic>>[];
          for (final verse in (chapter['verses'] as List)) {
            final v = Map<String, dynamic>.from(verse as Map);
            if (v['krv'] is String) v['krv'] = _cleanText(v['krv'] as String);
            if (v['kjv'] is String) v['kjv'] = _cleanText(v['kjv'] as String);
            verses.add(v);
          }
          chapters.add(verses);
        }
        _chapters[bookId] = chapters;
      }

      _loaded = true;
    } catch (e, stack) {
      debugPrint('성경 데이터 로드 실패: $e\n$stack');
      _books = [];
      _chapters = {};
      _loaded = false;
      rethrow;
    }
  }

  String _cleanText(String text) {
    return text
        .replaceAll('&#x27;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&#x22;', '"')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'&#x[0-9a-fA-F]+;'), '')
        .replaceAll(RegExp(r'&#\d+;'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<BibleVerse> getVerses(int bookId, int chapter) {
    final book = _books.where((b) => b.id == bookId).firstOrNull;
    if (book == null) return [];
    final chaptersData = _chapters[bookId];
    if (chaptersData == null || chapter < 1 || chapter > chaptersData.length) {
      return [];
    }

    final versesData = chaptersData[chapter - 1];
    return versesData.map((v) => BibleVerse(
      bookId: bookId,
      bookNameKo: book.nameKo,
      bookNameEn: book.nameEn,
      abbrKo: book.abbrKo,
      abbrEn: book.abbrEn,
      testament: book.testament,
      category: book.category,
      chapter: chapter,
      verse: v['verse'] as int,
      krv: v['krv'] as String? ?? '',
      kjv: v['kjv'] as String? ?? '',
    )).toList();
  }

  /// 특정 구절 1개 가져오기 — 절 번호 기반 검색 (인덱스가 아닌 실제 verse 번호로)
  BibleVerse? getVerse(int bookId, int chapter, int verse) {
    final verses = getVerses(bookId, chapter);
    if (verses.isEmpty) return null;

    // 방법 1: 정확한 절 번호 매칭
    for (final v in verses) {
      if (v.verse == verse) return v;
    }

    // 방법 2: 인덱스 폴백 (절 번호가 연속인 경우)
    if (verse >= 1 && verse <= verses.length) {
      return verses[verse - 1];
    }

    return null;
  }

  /// 특정 범위 구절 가져오기 (예: 4:6-7)
  List<BibleVerse> getVerseRange(int bookId, int chapter, int verseStart, int verseEnd) {
    final verses = getVerses(bookId, chapter);
    return verses.where((v) => v.verse >= verseStart && v.verse <= verseEnd).toList();
  }

  int getChapterCount(int bookId) {
    return _chapters[bookId]?.length ?? 0;
  }

  int getVerseCount(int bookId, int chapter) {
    final chaptersData = _chapters[bookId];
    if (chaptersData == null || chapter < 1 || chapter > chaptersData.length) return 0;
    return chaptersData[chapter - 1].length;
  }

  List<BibleVerse> search(String query, {int limit = 50}) {
    if (query.trim().isEmpty) return [];
    final results = <BibleVerse>[];
    final q = query.trim().toLowerCase();

    for (final book in _books) {
      final chapters = _chapters[book.id];
      if (chapters == null) continue;

      for (int ch = 0; ch < chapters.length; ch++) {
        for (final v in chapters[ch]) {
          final krv = (v['krv'] as String? ?? '').toLowerCase();
          if (krv.contains(q)) {
            results.add(BibleVerse(
              bookId: book.id, bookNameKo: book.nameKo, bookNameEn: book.nameEn,
              abbrKo: book.abbrKo, abbrEn: book.abbrEn,
              testament: book.testament, category: book.category,
              chapter: ch + 1, verse: v['verse'] as int,
              krv: v['krv'] as String? ?? '', kjv: v['kjv'] as String? ?? '',
            ));
            if (results.length >= limit) return results;
          }
        }
      }
    }
    return results;
  }

  List<BibleBook> get oldTestamentBooks => _books.where((b) => b.testament == 'old').toList();
  List<BibleBook> get newTestamentBooks => _books.where((b) => b.testament == 'new').toList();

  BibleVerse? getDailyVerse() {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final favorites = [
      [19, 23, 1], [43, 3, 16], [23, 41, 10], [50, 4, 13], [24, 29, 11],
      [45, 8, 28], [20, 3, 5], [19, 46, 1], [40, 11, 28], [23, 40, 31],
      [19, 27, 1], [48, 2, 20], [6, 1, 9], [19, 119, 105], [55, 1, 7],
      [5, 31, 8], [43, 14, 27], [19, 37, 4], [45, 15, 13], [50, 4, 6],
      [62, 4, 18], [19, 34, 18], [47, 5, 17], [40, 6, 34], [58, 13, 5],
      [19, 139, 14], [23, 43, 19], [46, 10, 13], [59, 1, 5], [19, 55, 22],
    ];
    final index = seed % favorites.length;
    final ref = favorites[index];
    return getVerse(ref[0], ref[1], ref[2]);
  }
}
