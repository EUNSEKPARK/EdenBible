import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/counsel_preset.dart';
import 'bible_data_service.dart';

/// AI 상담 매칭 서비스 — 중복 방지 + 다양한 응답
class CounselService {
  static final CounselService _instance = CounselService._();
  factory CounselService() => _instance;
  CounselService._();

  List<CounselPreset> _presets = [];
  bool _loaded = false;
  final _rng = Random();

  // 최근 사용된 프리셋 ID 추적 (중복 방지)
  final List<int> _recentlyUsedIds = [];
  static const _maxRecent = 10;

  List<CounselPreset> get presets => _presets;

  Future<void> loadPresets() async {
    if (_loaded) return;
    final jsonStr = await rootBundle.loadString('assets/data/counsel_presets.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    _presets = (data['presets'] as List).map((p) => CounselPreset.fromJson(p as Map<String, dynamic>)).toList();
    _loaded = true;
  }

  /// 사용자 입력에 가장 적합한 프리셋 매칭 (중복 방지)
  CounselResponse? findBestMatch(String userInput) {
    if (_presets.isEmpty || userInput.trim().isEmpty) return null;

    final normalizedInput = userInput.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    // 모든 프리셋에 점수 매기기
    final scored = <_ScoredPreset>[];
    for (final preset in _presets) {
      final score = _calculateMatchScore(normalizedInput, preset);
      if (score >= 0.1) {
        scored.add(_ScoredPreset(preset: preset, score: score));
      }
    }

    if (scored.isEmpty) return _getRandomDefault();

    // 점수 높은 순 정렬
    scored.sort((a, b) => b.score.compareTo(a.score));

    // 상위 5개 후보 중 최근 사용 안 한 것 우선
    final candidates = scored.take(5).toList();
    CounselPreset? chosen;

    for (final c in candidates) {
      if (!_recentlyUsedIds.contains(c.preset.id)) {
        chosen = c.preset;
        break;
      }
    }
    // 모두 최근 사용했으면 랜덤
    chosen ??= candidates[_rng.nextInt(candidates.length)].preset;

    // 사용 이력 기록
    _recentlyUsedIds.add(chosen.id);
    if (_recentlyUsedIds.length > _maxRecent) _recentlyUsedIds.removeAt(0);

    return CounselResponse(
      message: chosen.warmMessage,
      verses: chosen.recommendVerses,
      prayerGuide: chosen.prayerGuide,
      source: ResponseSource.preset,
      tone: chosen.tone,
    );
  }

  double _calculateMatchScore(String input, CounselPreset preset) {
    double score = 0;
    int matched = 0;

    for (final keyword in preset.triggerKeywords) {
      if (input.contains(keyword.toLowerCase())) matched++;
    }

    if (preset.triggerKeywords.isNotEmpty) {
      score = matched / preset.triggerKeywords.length;
    }

    if (input.contains(preset.subCategory.replaceAll('_', ' ').toLowerCase())) score += 0.3;
    if (input.contains(preset.category.toLowerCase())) score += 0.2;

    // 최근 사용한 프리셋은 점수 감소 (다양성 확보)
    if (_recentlyUsedIds.contains(preset.id)) score *= 0.3;

    return score.clamp(0.0, 1.0);
  }

  /// 매칭 실패 시 다양한 기본 응답 (랜덤)
  CounselResponse _getRandomDefault() {
    final defaults = [
      '마음을 나눠주셔서 감사해요. 조금 더 자세히 이야기해 주시면 당신의 상황에 맞는 말씀을 찾아드릴게요.',
      '당신의 이야기를 듣고 있어요. 지금 어떤 감정이 가장 크게 느껴지나요? 슬픔, 불안, 외로움 등 편하게 말씀해 주세요.',
      '함께 나눠주셔서 고마워요. 혹시 "불안해요", "슬퍼요", "감사해요" 같은 마음의 상태를 알려주시면 더 정확한 말씀을 드릴 수 있어요.',
      '당신의 마음을 이해하고 싶어요. 어떤 상황에서 그런 마음이 드셨나요? 조금 더 이야기해 주세요.',
      '하나님은 당신의 마음을 아십니다. 어떤 부분에서 위로가 필요하신지 알려주시면 맞춤 말씀을 찾아드릴게요.',
      '괜찮아요, 천천히 이야기해 주세요. "취업", "관계", "건강", "미래" 등 고민의 주제를 알려주시면 도움이 돼요.',
    ];
    return CounselResponse(
      message: defaults[_rng.nextInt(defaults.length)],
      verses: [],
      prayerGuide: null,
      source: ResponseSource.preset,
      tone: '위로',
    );
  }

  List<String> getSuggestionQuestions() {
    final all = [
      '오늘 위로가 필요해요', '감사 기도를 하고 싶어요', '마음이 불안해요',
      '취업이 안 돼서 힘들어요', '가족과 갈등이 있어요', '외로워요',
      '용서하기 어려워요', '새로운 시작이 두려워요', '건강이 걱정돼요',
      '미래가 불안해요', '직장에서 힘들어요', '인간관계가 어려워요',
    ];
    all.shuffle(_rng);
    return all.take(4).toList();
  }

  List<Map<String, String>> getVerseTexts(List<VerseReference> refs) {
    final bible = BibleDataService();
    final results = <Map<String, String>>[];
    for (final ref in refs) {
      final texts = <String>[];
      for (int v = ref.verseStart; v <= ref.verseEnd; v++) {
        final verse = bible.getVerse(ref.bookId, ref.chapter, v);
        if (verse != null && verse.krv.isNotEmpty) texts.add(verse.krv);
      }
      if (texts.isNotEmpty) results.add({'ref': ref.ref, 'text': texts.join(' ')});
    }
    return results;
  }
}

class _ScoredPreset {
  final CounselPreset preset;
  final double score;
  _ScoredPreset({required this.preset, required this.score});
}
