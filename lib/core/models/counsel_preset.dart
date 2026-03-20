/// AI 상담 프리셋 데이터 모델
class CounselPreset {
  final int id;
  final String category;
  final String subCategory;
  final List<String> triggerKeywords;
  final List<VerseReference> recommendVerses;
  final String warmMessage;
  final String prayerGuide;
  final String tone;

  const CounselPreset({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.triggerKeywords,
    required this.recommendVerses,
    required this.warmMessage,
    required this.prayerGuide,
    required this.tone,
  });

  factory CounselPreset.fromJson(Map<String, dynamic> json) {
    return CounselPreset(
      id: json['id'] as int,
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      triggerKeywords: List<String>.from(json['trigger_keywords'] as List),
      recommendVerses: (json['recommend_verses'] as List)
          .map((v) => VerseReference.fromJson(v as Map<String, dynamic>))
          .toList(),
      warmMessage: json['warm_message'] as String,
      prayerGuide: json['prayer_guide'] as String,
      tone: json['tone'] as String,
    );
  }

  /// 사용자 입력에 대한 키워드 매칭 점수 (0.0 ~ 1.0)
  double matchScore(String userInput) {
    final input = userInput.toLowerCase();
    int matched = 0;
    for (final keyword in triggerKeywords) {
      if (input.contains(keyword.toLowerCase())) {
        matched++;
      }
    }
    return triggerKeywords.isEmpty ? 0.0 : matched / triggerKeywords.length;
  }
}

/// 성경 구절 참조
class VerseReference {
  final String ref;       // "시편 23:1-4"
  final int bookId;
  final int chapter;
  final int verseStart;
  final int verseEnd;

  const VerseReference({
    required this.ref,
    required this.bookId,
    required this.chapter,
    required this.verseStart,
    required this.verseEnd,
  });

  factory VerseReference.fromJson(Map<String, dynamic> json) {
    return VerseReference(
      ref: json['ref'] as String,
      bookId: json['book_id'] as int,
      chapter: json['chapter'] as int,
      verseStart: json['verse_start'] as int,
      verseEnd: json['verse_end'] as int,
    );
  }
}

/// AI 상담 응답
class CounselResponse {
  final String message;
  final List<VerseReference> verses;
  final String? prayerGuide;
  final ResponseSource source;
  final String tone;

  const CounselResponse({
    required this.message,
    required this.verses,
    this.prayerGuide,
    required this.source,
    required this.tone,
  });
}

/// 응답 소스 구분
enum ResponseSource {
  preset,   // 프리셋 데이터에서 매칭
  localLLM, // 로컬 LLM 실시간 생성
}
