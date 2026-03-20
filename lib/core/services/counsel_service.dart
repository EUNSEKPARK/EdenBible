import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/counsel_preset.dart';
import 'bible_data_service.dart'; // getVerseTexts()에서 사용

/// AI 상담 매칭 서비스 — 사용자 입력에 최적의 프리셋을 매칭
class CounselService {
  static final CounselService _instance = CounselService._();
  factory CounselService() => _instance;
  CounselService._();

  List<CounselPreset> _presets = [];
  bool _loaded = false;

  List<CounselPreset> get presets => _presets;
  List<String> get categories =>
      _presets.map((p) => p.category).toSet().toList()..sort();

  /// 프리셋 데이터 로드
  Future<void> loadPresets() async {
    if (_loaded) return;

    final jsonStr = await rootBundle.loadString('assets/data/counsel_presets.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    _presets = (data['presets'] as List)
        .map((p) => CounselPreset.fromJson(p as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }

  /// 사용자 입력에 가장 적합한 프리셋 매칭
  CounselResponse? findBestMatch(String userInput) {
    if (_presets.isEmpty || userInput.trim().isEmpty) return null;

    CounselPreset? bestMatch;
    double bestScore = 0;

    for (final preset in _presets) {
      final score = _calculateMatchScore(userInput, preset);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = preset;
      }
    }

    // 최소 매칭 임계값
    if (bestMatch == null || bestScore < 0.1) {
      return _getDefaultResponse();
    }

    return CounselResponse(
      message: bestMatch.warmMessage,
      verses: bestMatch.recommendVerses,
      prayerGuide: bestMatch.prayerGuide,
      source: ResponseSource.preset,
      tone: bestMatch.tone,
    );
  }

  /// 매칭 점수 계산 (0.0 ~ 1.0)
  double _calculateMatchScore(String input, CounselPreset preset) {
    final normalizedInput = input.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    double score = 0;
    int matchedKeywords = 0;

    for (final keyword in preset.triggerKeywords) {
      if (normalizedInput.contains(keyword.toLowerCase())) {
        matchedKeywords++;
      }
    }

    if (preset.triggerKeywords.isNotEmpty) {
      score = matchedKeywords / preset.triggerKeywords.length;
    }

    // 서브 카테고리 이름과의 유사도 보너스
    if (normalizedInput.contains(preset.subCategory.replaceAll('_', ' ').toLowerCase())) {
      score += 0.3;
    }

    // 카테고리 이름과의 유사도 보너스
    if (normalizedInput.contains(preset.category.toLowerCase())) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  /// 매칭 실패 시 기본 응답
  CounselResponse _getDefaultResponse() {
    return CounselResponse(
      message: '마음을 나눠주셔서 감사해요. 조금 더 자세히 이야기해 주시면 당신의 상황에 맞는 말씀을 찾아드릴게요. 지금 어떤 마음이 드시나요?',
      verses: [],
      prayerGuide: null,
      source: ResponseSource.preset,
      tone: '위로',
    );
  }

  /// 카테고리별 추천 질문 목록
  List<String> getSuggestionQuestions() {
    return [
      '오늘 위로가 필요해요',
      '감사 기도를 하고 싶어요',
      '마음이 불안해요',
      '취업이 안 돼서 힘들어요',
      '가족과 갈등이 있어요',
      '외로워요',
      '용서하기 어려워요',
      '새로운 시작이 두려워요',
    ];
  }

  /// 프리셋에서 추천 구절의 실제 텍스트를 가져오기
  List<Map<String, String>> getVerseTexts(List<VerseReference> refs) {
    final bible = BibleDataService();
    final results = <Map<String, String>>[];

    for (final ref in refs) {
      final texts = <String>[];
      for (int v = ref.verseStart; v <= ref.verseEnd; v++) {
        final verse = bible.getVerse(ref.bookId, ref.chapter, v);
        if (verse != null && verse.krv.isNotEmpty) {
          texts.add(verse.krv);
        }
      }
      if (texts.isNotEmpty) {
        results.add({
          'ref': ref.ref,
          'text': texts.join(' '),
        });
      }
    }
    return results;
  }
}
