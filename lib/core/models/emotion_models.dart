/// 감정 대분류 카테고리 모델
class EmotionCategory {
  final String id;
  final String emoji;
  final String label;
  final String color;
  final String icon;
  final List<Situation> situations;

  const EmotionCategory({
    required this.id,
    required this.emoji,
    required this.label,
    required this.color,
    required this.icon,
    required this.situations,
  });

  factory EmotionCategory.fromJson(Map<String, dynamic> json) {
    return EmotionCategory(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      label: json['label'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      situations: (json['situations'] as List)
          .map((s) => Situation.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 세부 상황 모델
class Situation {
  final String id;
  final String label;
  final String icon;
  final HealingResponse response;

  const Situation({
    required this.id,
    required this.label,
    required this.icon,
    required this.response,
  });

  factory Situation.fromJson(Map<String, dynamic> json) {
    return Situation(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      response: HealingResponse.fromJson(json['response'] as Map<String, dynamic>),
    );
  }
}

/// 힐링 패키지 응답 모델
class HealingResponse {
  final String aiMessage;
  final List<EmotionVerse> verses;
  final String prayerGuide;
  final List<YouTubeCurated> youtubeCurated;

  const HealingResponse({
    required this.aiMessage,
    required this.verses,
    required this.prayerGuide,
    required this.youtubeCurated,
  });

  factory HealingResponse.fromJson(Map<String, dynamic> json) {
    return HealingResponse(
      aiMessage: json['ai_message'] as String? ?? '',
      verses: (json['verses'] as List?)
              ?.map((v) => EmotionVerse.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      prayerGuide: json['prayer_guide'] as String? ?? '',
      youtubeCurated: (json['youtube_curated'] as List?)
              ?.map((y) => YouTubeCurated.fromJson(y as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 감정 매칭용 성경 구절
class EmotionVerse {
  final String ref;
  final int bookId;
  final int chapter;
  final int verse;

  const EmotionVerse({
    required this.ref,
    required this.bookId,
    required this.chapter,
    required this.verse,
  });

  factory EmotionVerse.fromJson(Map<String, dynamic> json) {
    return EmotionVerse(
      ref: json['ref'] as String,
      bookId: json['book_id'] as int,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
    );
  }
}

/// 유튜브 큐레이션 영상
class YouTubeCurated {
  final String title;
  final String videoId;

  const YouTubeCurated({
    required this.title,
    required this.videoId,
  });

  factory YouTubeCurated.fromJson(Map<String, dynamic> json) {
    return YouTubeCurated(
      title: json['title'] as String,
      videoId: json['video_id'] as String,
    );
  }
}
