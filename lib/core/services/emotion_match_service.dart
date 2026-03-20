import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/emotion_models.dart';
import 'bible_data_service.dart';

/// 버튼형 감정 매칭 서비스 — 서버 통신 없이 온디바이스 즉시 매칭
class EmotionMatchService extends ChangeNotifier {
  static final EmotionMatchService _instance = EmotionMatchService._();
  factory EmotionMatchService() => _instance;
  EmotionMatchService._();

  List<EmotionCategory> _categories = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<EmotionCategory> get categories => _categories;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/emotion_map.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = data['categories'] as List;
      _categories = list.map((c) => EmotionCategory.fromJson(c as Map<String, dynamic>)).toList();
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('EmotionMatchService 로드 오류: $e');
    }
  }

  List<Situation> getSituations(String categoryId) {
    final cat = _categories.where((c) => c.id == categoryId).firstOrNull;
    return cat?.situations ?? [];
  }

  HealingResponse? getResponse(String situationId) {
    for (final cat in _categories) {
      for (final sit in cat.situations) {
        if (sit.id == situationId) return sit.response;
      }
    }
    return null;
  }

  HealingResponse? getAlternative(String categoryId, String excludeSituationId) {
    final cat = _categories.where((c) => c.id == categoryId).firstOrNull;
    if (cat == null) return null;
    final others = cat.situations.where((s) => s.id != excludeSituationId).toList();
    if (others.isEmpty) return null;
    others.shuffle(Random());
    return others.first.response;
  }

  /// 성경 구절 텍스트 가져오기 — 단일 절 + 범위 절 모두 지원
  String getVerseText(EmotionVerse ev) {
    final bible = BibleDataService();
    if (!bible.isLoaded) return '';

    // 단일 절 조회
    final verse = bible.getVerse(ev.bookId, ev.chapter, ev.verse);
    if (verse != null && verse.krv.isNotEmpty) {
      return verse.krv;
    }

    // 인근 절 시도 (절 번호 오프셋 ±1)
    for (final offset in [1, -1, 2, -2]) {
      final nearby = bible.getVerse(ev.bookId, ev.chapter, ev.verse + offset);
      if (nearby != null && nearby.krv.isNotEmpty) {
        debugPrint('⚠️ ${ev.ref}: verse ${ev.verse} 없음 → ${ev.verse + offset} 대체');
        return nearby.krv;
      }
    }

    debugPrint('❌ 구절 로드 실패: ${ev.ref} (bookId=${ev.bookId}, ch=${ev.chapter}, v=${ev.verse})');
    return '';
  }
}
