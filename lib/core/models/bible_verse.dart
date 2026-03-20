/// 성경 구절 데이터 모델
class BibleVerse {
  final int bookId;
  final String bookNameKo;
  final String bookNameEn;
  final String abbrKo;
  final String abbrEn;
  final String testament;
  final String category;
  final int chapter;
  final int verse;
  final String krv;  // 개역한글
  final String kjv;  // King James Version

  const BibleVerse({
    required this.bookId,
    required this.bookNameKo,
    required this.bookNameEn,
    required this.abbrKo,
    required this.abbrEn,
    required this.testament,
    required this.category,
    required this.chapter,
    required this.verse,
    required this.krv,
    required this.kjv,
  });

  /// 한글 참조 문자열 (예: "창세기 1:1")
  String get refKo => '$bookNameKo $chapter:$verse';

  /// 영문 참조 문자열 (예: "Genesis 1:1")
  String get refEn => '$bookNameEn $chapter:$verse';

  /// 약어 참조 (예: "창 1:1")
  String get shortRef => '$abbrKo $chapter:$verse';

  /// 구약 여부
  bool get isOldTestament => testament == 'old';

  /// 신약 여부
  bool get isNewTestament => testament == 'new';

  factory BibleVerse.fromJson(Map<String, dynamic> json, {
    required int bookId,
    required String bookNameKo,
    required String bookNameEn,
    required String abbrKo,
    required String abbrEn,
    required String testament,
    required String category,
    required int chapter,
  }) {
    return BibleVerse(
      bookId: bookId,
      bookNameKo: bookNameKo,
      bookNameEn: bookNameEn,
      abbrKo: abbrKo,
      abbrEn: abbrEn,
      testament: testament,
      category: category,
      chapter: chapter,
      verse: json['verse'] as int,
      krv: json['krv'] as String? ?? '',
      kjv: json['kjv'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'book_id': bookId,
    'book_name_ko': bookNameKo,
    'book_name_en': bookNameEn,
    'abbr_ko': abbrKo,
    'abbr_en': abbrEn,
    'testament': testament,
    'category': category,
    'chapter': chapter,
    'verse': verse,
    'krv': krv,
    'kjv': kjv,
  };

  @override
  String toString() => '$refKo: $krv';
}

/// 성경 책 메타데이터
class BibleBook {
  final int id;
  final String abbrKo;
  final String nameKo;
  final String abbrEn;
  final String nameEn;
  final String testament;
  final String category;
  final int chapterCount;
  final int verseCount;

  const BibleBook({
    required this.id,
    required this.abbrKo,
    required this.nameKo,
    required this.abbrEn,
    required this.nameEn,
    required this.testament,
    required this.category,
    required this.chapterCount,
    required this.verseCount,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: json['id'] as int,
      abbrKo: json['abbr_ko'] as String,
      nameKo: json['name_ko'] as String,
      abbrEn: json['abbr_en'] as String,
      nameEn: json['name_en'] as String,
      testament: json['testament'] as String,
      category: json['category'] as String,
      chapterCount: json['chapter_count'] as int,
      verseCount: json['verse_count'] as int,
    );
  }
}
