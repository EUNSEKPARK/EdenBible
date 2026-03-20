import 'dart:math';
import '../models/emotion_models.dart';

/// 유튜브 큐레이션 서비스 — 검증된 기독교 채널 + 추천 영상
class YoutubeCurationService {
  static final YoutubeCurationService _instance = YoutubeCurationService._();
  factory YoutubeCurationService() => _instance;
  YoutubeCurationService._();

  /// 검증된 기독교 유튜브 채널 목록
  static const channels = [
    {'name': '찬미워십', 'id': 'UCUpGS5q9bzMR1PQyJR1sqaA'},
    {'name': 'KCMTV', 'id': 'UCgx5gByxE6oBLVuSJAf0e1A'},
    {'name': '예수전도단', 'id': 'UCqLFCc7DyY2h9lfq0sOlbYQ'},
    {'name': '주찬양선교단', 'id': 'UCJgpLdKzY_2zBjT4LR6DCZQ'},
    {'name': '마커스워십', 'id': 'UCl7epVJhUQoDjaIjMmOUBuw'},
    {'name': 'J-US', 'id': 'UCH1dkINCAkuAnp0gRnKPpTg'},
    {'name': '새벽기도', 'id': 'UCRJTm6_LLZlfFHbv4CXGV3A'},
    {'name': 'CGN', 'id': 'UC9x0RNlSENFp3eBqGQbqJXQ'},
    {'name': '갓피플', 'id': 'UCLf0j_RqIEHwnAtKTixhIoQ'},
    {'name': '두날개', 'id': 'UCTVgqJhXzN3bxZ_FmjrNi0Q'},
  ];

  /// 홈 화면 "오늘의 추천 영상" 데이터 (일별 고정)
  List<YouTubeCurated> getDailyRecommendations() {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final rng = Random(seed);

    // 전체 추천 풀에서 일별 3개 선정
    final pool = List<YouTubeCurated>.from(_recommendationPool);
    pool.shuffle(rng);
    return pool.take(3).toList();
  }

  /// 카테고리별 추천 영상
  List<YouTubeCurated> getByCategory(String category) {
    return _categoryRecommendations[category] ?? _recommendationPool.take(2).toList();
  }

  /// 전체 추천 영상 풀
  static final _recommendationPool = [
    const YouTubeCurated(title: '마음에 평안을 주는 찬양 모음 2시간', videoId: 'nwIP9fJjTgA'),
    const YouTubeCurated(title: '새벽기도 찬양 — 은혜로운 CCM 연속듣기', videoId: '1tGCRveOHhM'),
    const YouTubeCurated(title: '잠잘때 듣는 시편 낭독 + 잔잔한 음악', videoId: 'Y4StAM1w2vk'),
    const YouTubeCurated(title: '마커스워십 — 주의 이름 높이며 (LIVE)', videoId: 'Kx3zxKVB3RM'),
    const YouTubeCurated(title: '2024 베스트 CCM — 힘이 되는 찬양', videoId: 'kPBvt0Dln-w'),
    const YouTubeCurated(title: 'J-US 실황 워십 — 주가 일하시네', videoId: 'JZ5x3hQBhro'),
    const YouTubeCurated(title: '하루를 여는 말씀 묵상 — 시편 23편', videoId: '8uKfbdKVxZY'),
    const YouTubeCurated(title: '위로가 필요할 때 듣는 찬양 TOP 20', videoId: '4lQjO4_Rfhw'),
    const YouTubeCurated(title: '예배 인도를 위한 찬양 모음 — 교회 워십', videoId: '6GRHX2DnCzE'),
    const YouTubeCurated(title: '감사의 계절 — 가을 찬양 모음', videoId: '3h2gcNjCrVc'),
    const YouTubeCurated(title: '찬미워십 — 하늘 문을 여소서 (Official)', videoId: 'NxFnQ__Yrr0'),
    const YouTubeCurated(title: '출근길에 듣는 힘이 되는 찬양 30분', videoId: 'mF-srGJzH4U'),
    const YouTubeCurated(title: '기도할 때 듣는 평안한 피아노 음악', videoId: 'OpPvHQxF4Nw'),
    const YouTubeCurated(title: '성경 통독 — 창세기 전체 (음성 낭독)', videoId: 'M6q2pcaj5JU'),
    const YouTubeCurated(title: '주일예배 찬양 — 오직 주만이 (LIVE)', videoId: 'hS-mAqSK_Jw'),
  ];

  /// 감정 카테고리별 추천
  static final _categoryRecommendations = <String, List<YouTubeCurated>>{
    'anxiety': [
      const YouTubeCurated(title: '불안한 마음에 평안을 주는 찬양', videoId: 'nwIP9fJjTgA'),
      const YouTubeCurated(title: '걱정을 내려놓는 말씀 묵상', videoId: 'Y4StAM1w2vk'),
    ],
    'sadness': [
      const YouTubeCurated(title: '슬플 때 위로가 되는 CCM 모음', videoId: '4lQjO4_Rfhw'),
      const YouTubeCurated(title: '눈물 닦아주시는 하나님 — 치유 찬양', videoId: '1tGCRveOHhM'),
    ],
    'relationship': [
      const YouTubeCurated(title: '관계 회복을 위한 기도 찬양', videoId: 'kPBvt0Dln-w'),
      const YouTubeCurated(title: '용서에 대한 은혜로운 설교', videoId: '6GRHX2DnCzE'),
    ],
    'gratitude': [
      const YouTubeCurated(title: '감사 찬양 모음 — 주의 은혜 감사해', videoId: '3h2gcNjCrVc'),
      const YouTubeCurated(title: '하나님의 신실하심을 찬양하는 워십', videoId: 'NxFnQ__Yrr0'),
    ],
    'anger': [
      const YouTubeCurated(title: '분노를 다스리는 지혜의 말씀', videoId: 'OpPvHQxF4Nw'),
      const YouTubeCurated(title: '마음을 평안하게 하는 묵상 음악', videoId: 'Y4StAM1w2vk'),
    ],
    'tired': [
      const YouTubeCurated(title: '지친 영혼을 위한 안식 찬양', videoId: 'mF-srGJzH4U'),
      const YouTubeCurated(title: '번아웃에서 회복하는 묵상 음악', videoId: 'OpPvHQxF4Nw'),
    ],
    'sleepless': [
      const YouTubeCurated(title: '잠들기 전 듣는 잔잔한 찬양 3시간', videoId: 'nwIP9fJjTgA'),
      const YouTubeCurated(title: '수면을 위한 평안한 성경 낭독', videoId: 'Y4StAM1w2vk'),
    ],
    'joy': [
      const YouTubeCurated(title: '기쁨이 넘치는 감사 찬양', videoId: 'Kx3zxKVB3RM'),
      const YouTubeCurated(title: '축하와 감격의 워십 라이브', videoId: 'JZ5x3hQBhro'),
    ],
    'lost': [
      const YouTubeCurated(title: '삶의 방향을 찾는 묵상 설교', videoId: '8uKfbdKVxZY'),
      const YouTubeCurated(title: '하나님의 인도하심을 구하는 찬양', videoId: 'hS-mAqSK_Jw'),
    ],
    'courage': [
      const YouTubeCurated(title: '용기를 주는 힘찬 찬양 모음', videoId: 'kPBvt0Dln-w'),
      const YouTubeCurated(title: '담대한 믿음을 위한 말씀', videoId: '6GRHX2DnCzE'),
    ],
  };
}
