import 'dart:math';
import '../models/emotion_models.dart';

/// 유튜브 큐레이션 서비스
/// - 은혜의반석(Rock of Grace) 채널 자체 영상 114개 풀
/// - 매일 다른 3개 추천 + 테마별 섹션
/// - 감정 카테고리별 매핑
class YoutubeCurationService {
  static final YoutubeCurationService _instance = YoutubeCurationService._();
  factory YoutubeCurationService() => _instance;
  YoutubeCurationService._();

  /// 홈 "오늘의 추천" — 매일 3개 갱신
  List<YouTubeCurated> getDailyRecommendations() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final rng = Random(seed);
    final pool = List<YouTubeCurated>.from(_allPool);
    pool.shuffle(rng);
    return pool.take(3).toList();
  }

  /// 감정 카테고리별 추천 2개
  List<YouTubeCurated> getByCategory(String category) {
    return _categoryMap[category] ?? _allPool.take(2).toList();
  }

  /// 넷플릭스 스타일 테마별 섹션 리스트
  List<YouTubeSection> getSections() => _sections;

  // ═══════════════════════════════════════════════════════════
  //  테마별 섹션 (넷플릭스 스타일)
  // ═══════════════════════════════════════════════════════════

  static final _sections = <YouTubeSection>[
    YouTubeSection(
      title: '🎵 찬양 & 워십',
      subtitle: '은혜의반석 오리지널 CCM',
      videos: _worship,
    ),
    YouTubeSection(
      title: '😌 마음이 지칠 때',
      subtitle: '위로와 회복이 필요한 당신에게',
      videos: _comfort,
    ),
    YouTubeSection(
      title: '🌙 잠잘 때 / 묵상 BGM',
      subtitle: '잔잔한 음악과 함께하는 말씀',
      videos: _sleep,
    ),
    YouTubeSection(
      title: '📖 성경 이야기',
      subtitle: '역사와 고고학으로 보는 성경',
      videos: _bibleStory,
    ),
    YouTubeSection(
      title: '🎬 성경 애니메이션',
      subtitle: '창세기부터 사도행전까지',
      videos: _animation,
    ),
    YouTubeSection(
      title: '👤 성경 인물',
      subtitle: '하나님이 사용하신 사람들',
      videos: _people,
    ),
    YouTubeSection(
      title: '📜 잠언 묵상 낭독',
      subtitle: '하루 한 장, 지혜의 말씀',
      videos: _proverbs,
    ),
    YouTubeSection(
      title: '🎓 신학 & 교양',
      subtitle: '깊이 있는 신앙의 탐구',
      videos: _theology,
    ),
  ];

  // ─── 찬양 & 워십 (9) ───
  static const _worship = <YouTubeCurated>[
    YouTubeCurated(title: 'CCM 찬양 모음 1시간 24곡', videoId: '6p8EH-zBUIk'),
    YouTubeCurated(title: '성경속나라 CCM 모음 20곡', videoId: 'eFnjsWid9OM'),
    YouTubeCurated(title: '호산나 (Hosanna) EDM', videoId: '4idGCHtaJfA'),
    YouTubeCurated(title: '실로암 (Siloam) 댄스 16분', videoId: '51sJRW_KgbY'),
    YouTubeCurated(title: '실로암 (Siloam) 발라드', videoId: 'Ll8DNHfmClw'),
    YouTubeCurated(title: '찬양의 성전 예루살렘 CCM', videoId: 'Tfa3LICdcQQ'),
    YouTubeCurated(title: '시편 23편 힙합', videoId: 'ULRlwuhbqh0'),
    YouTubeCurated(title: '에덴 (EDEN) 뮤직비디오', videoId: 'kXXkYFVzjV4'),
    YouTubeCurated(title: '시편 1편 힙합 3D', videoId: 'Z2NVlLSH5b4'),
  ];

  // ─── 위로 / 힐링 (12) ───
  static const _comfort = <YouTubeCurated>[
    YouTubeCurated(title: '지친 당신을 위한 기도', videoId: 'PYSEV8wL7pQ'),
    YouTubeCurated(title: '본회퍼의 마지막 편지', videoId: 'fZxMRucMl2E'),
    YouTubeCurated(title: '단편영화 사울 - 무릎 꿇은 날', videoId: 'B9xl7ap5heI'),
    YouTubeCurated(title: '교회에서 일어난 5가지 실화', videoId: 'iCcla2FHigk'),
    YouTubeCurated(title: '나치에 맞선 신앙의 찬송', videoId: 'd4PgtTuigkg'),
    YouTubeCurated(title: '10년 만에 교회를 찾은 청년', videoId: 'ILlDm39FOtE'),
    YouTubeCurated(title: '아빠가 아들에게 EP.01', videoId: '6mpr5ghO3Nk'),
    YouTubeCurated(title: '아빠가 아들에게 EP.02', videoId: 'OwoEjcGVfOI'),
    YouTubeCurated(title: '아빠가 아들에게 EP.03', videoId: 'vcfy0jGz60A'),
    YouTubeCurated(title: '아빠가 아들에게 EP.04', videoId: 'IKhZdwT2LV4'),
    YouTubeCurated(title: '아빠가 아들에게 EP.05', videoId: '39nXM1SCW1Y'),
    YouTubeCurated(title: '미운 동료 때문에 출근이 싫을 때', videoId: 'jm-OQdkKwjg'),
  ];

  // ─── 수면 / 묵상 BGM (6) ───
  static const _sleep = <YouTubeCurated>[
    YouTubeCurated(title: '시편 찬양 Vol.4 (1시간)', videoId: 'pEaGVQH75U4'),
    YouTubeCurated(title: '시편 찬양 Vol.3 (1시간)', videoId: 'EUwWtRJlUII'),
    YouTubeCurated(title: '시편 찬양 Vol.2 (27분)', videoId: 'TKjKBB1FjAA'),
    YouTubeCurated(title: '시편 찬양 Vol.1 (23분)', videoId: 'ptmYVr7yu-M'),
    YouTubeCurated(title: '잠언 재즈 BGM 30분', videoId: '0Xw7GhOiGMc'),
    YouTubeCurated(title: '요한복음 재즈 33분', videoId: '-_hKJ7-3dJg'),
  ];

  // ─── 성경 이야기 / 다큐 (20) ───
  static const _bibleStory = <YouTubeCurated>[
    YouTubeCurated(title: '성경 전체를 5분 만에!', videoId: 'hHLNfr9C__k'),
    YouTubeCurated(title: '성경 전체를 90초에!', videoId: 'hkTPz3teq-0'),
    YouTubeCurated(title: '바벨탑의 진실 - 고고학 증거', videoId: '5hYE1FmYzo8'),
    YouTubeCurated(title: '솔로몬 성전 - 순금 25톤', videoId: 'NjYy8YyETww'),
    YouTubeCurated(title: '예루살렘 3천년 역사', videoId: 'Rq8tAUCm-Lw'),
    YouTubeCurated(title: '갈릴리 바다 사역 무대', videoId: 'MJES4JMkGd8'),
    YouTubeCurated(title: '성경 속 산들', videoId: '8ZdTUvwiXHU'),
    YouTubeCurated(title: '여리고 - 가장 낮은 곳', videoId: 'Y11fY9M5ctY'),
    YouTubeCurated(title: '바울의 1만 6천km 여정', videoId: 'xk8emxFbU8A'),
    YouTubeCurated(title: '홍해가 갈라진 곳', videoId: 'DYzreek9U0g'),
    YouTubeCurated(title: '초대교회의 시작', videoId: 'LYQpfInsnGc'),
    YouTubeCurated(title: '예수님의 기적은 몇 가지?', videoId: '1Cv2GKza4II'),
    YouTubeCurated(title: '예루살렘 3D 복원 - 헤롯 성전', videoId: 'hNGZ5gt899E'),
    YouTubeCurated(title: '소돔과 고모라 왜 멸망했나 #1', videoId: 'rVgVL19mPEI'),
    YouTubeCurated(title: '소돔과 고모라 실존 증거 #2', videoId: 'bP_eGipQvRI'),
    YouTubeCurated(title: '소돔과 고모라 NASA 위성 발견', videoId: 'RF68PiTabE8'),
    YouTubeCurated(title: '다윗 왕 실존 - 텔단 비문', videoId: 'Vi43oMsf-Jk'),
    YouTubeCurated(title: '출애굽은 실화인가?', videoId: 'g-2IT0uvgs4'),
    YouTubeCurated(title: '노아의 홍수 - 270개 전설', videoId: 'NiHubIrxsRU'),
    YouTubeCurated(title: '창세기 창조 순서와 과학', videoId: 'qGe3c3YiGng'),
  ];

  // ─── 성경 애니메이션 (14) ───
  static const _animation = <YouTubeCurated>[
    YouTubeCurated(title: '에덴동산 아담과 이브', videoId: 'rZC3gr7ZwVc'),
    YouTubeCurated(title: '카인과 아벨', videoId: 'luXg3vIQz7Y'),
    YouTubeCurated(title: '노아의 방주', videoId: 'km-cIU18R6Q'),
    YouTubeCurated(title: '노아의 방주 어린이 애니', videoId: 'ZgcBwdDrnCw'),
    YouTubeCurated(title: '바벨탑', videoId: 'VHD8cKPCYYs'),
    YouTubeCurated(title: '다윗과 골리앗', videoId: 'IGXE5pjjd1I'),
    YouTubeCurated(title: '예수님 탄생', videoId: 'X4iLsi8Ev8Y'),
    YouTubeCurated(title: '예수님 탄생 3D - 우주적 선포', videoId: 'XiP0fzeinhE'),
    YouTubeCurated(title: '예수님 탄생 3D - 광야의 대결', videoId: 'NmhtZTT57_g'),
    YouTubeCurated(title: '왜 왕이 마구간에서 태어났을까', videoId: '8fHunedAFIQ'),
    YouTubeCurated(title: '제자들 부르심', videoId: 'HwgDB2QSVwY'),
    YouTubeCurated(title: '동방박사의 경배', videoId: 'eetfCPYnQLw'),
    YouTubeCurated(title: '천지창조 단편영화', videoId: 'XL8Sjm0IR30'),
    YouTubeCurated(title: '광야의 시험 - 사탄의 3가지 제안', videoId: 'peJndlts4Nc'),
  ];

  // ─── 성경 인물 (9) ───
  static const _people = <YouTubeCurated>[
    YouTubeCurated(title: '요셉 - 팔려간 소년의 역전', videoId: 'CaPuh5lxQgg'),
    YouTubeCurated(title: '베드로 - 3번 배신한 남자', videoId: 'B2-tVJLngIg'),
    YouTubeCurated(title: '모세 - 홍해를 가른 기적', videoId: 'ZJGbTTPIR-4'),
    YouTubeCurated(title: '오병이어의 기적', videoId: 'obSO9ddXq7A'),
    YouTubeCurated(title: '야곱 - 이스라엘의 조상', videoId: 'EpuGvv9_oS0'),
    YouTubeCurated(title: '물을 포도주로 - 첫 기적', videoId: 'dJty80-0NLA'),
    YouTubeCurated(title: '베들레헴 탄생', videoId: 'TSqS-cnEEec'),
    YouTubeCurated(title: '수태고지', videoId: 'olKannHzUak'),
    YouTubeCurated(title: '다윗의 위험한 심리 분석', videoId: 'DHDPJs3wBrE'),
  ];

  // ─── 잠언 낭독 (31 - 전 장 완결!) ───
  static const _proverbs = <YouTubeCurated>[
    YouTubeCurated(title: '잠언 1장 - 지혜의 시작', videoId: '02iRccQpQxM'),
    YouTubeCurated(title: '잠언 2장 - 지혜를 구하면', videoId: 'mmdvkcWOtDs'),
    YouTubeCurated(title: '잠언 3장 - 여호와를 신뢰하라', videoId: 'CBoavL7HEAs'),
    YouTubeCurated(title: '잠언 4장 - 마음을 지켜라', videoId: '5Cv4F34sNJk'),
    YouTubeCurated(title: '잠언 5장 - 네 샘이 복되게', videoId: 'ZtgtNntsHLM'),
    YouTubeCurated(title: '잠언 6장 - 개미에게 배우라', videoId: 'yopCPWwhkp4'),
    YouTubeCurated(title: '잠언 7장 - 유혹의 패턴', videoId: 'tH3Kz8WYOv0'),
    YouTubeCurated(title: '잠언 8장 - 진주보다 귀한 지혜', videoId: 'v0x0m7WCxgs'),
    YouTubeCurated(title: '잠언 9장 - 지혜와 미련함', videoId: '0gl3eD59hy0'),
    YouTubeCurated(title: '잠언 10장 - 솔로몬의 잠언', videoId: 'vz6IFQcKPuY'),
    YouTubeCurated(title: '잠언 11장 - 정직과 거짓', videoId: 'GIMk3uupTCw'),
    YouTubeCurated(title: '잠언 12장 - 의인과 악인', videoId: '8OcvGSIRlU0'),
    YouTubeCurated(title: '잠언 13장 - 말의 지혜', videoId: 'u87BgH9RX_U'),
    YouTubeCurated(title: '잠언 14장 - 지혜와 미련', videoId: 'v7PoD1NnNQI'),
    YouTubeCurated(title: '잠언 15장 - 온유한 대답', videoId: 'FSvwvF92UU8'),
    YouTubeCurated(title: '잠언 16장 - 여호와의 주권', videoId: 'QSWhMHSbcu8'),
    YouTubeCurated(title: '잠언 17장 - 화평한 삶', videoId: '4YSapT1SVOc'),
    YouTubeCurated(title: '잠언 18장 - 관계의 지혜', videoId: 'H9uO5QwEIGk'),
    YouTubeCurated(title: '잠언 19장 - 어리석음과 지혜', videoId: 'JRxE3MmlEtM'),
    YouTubeCurated(title: '잠언 20장 - 왕과 의인', videoId: 'TjVo1hVGJZg'),
    YouTubeCurated(title: '잠언 21장 - 왕의 마음', videoId: 'Ht9ehY0aFEg'),
    YouTubeCurated(title: '잠언 22장 - 명예와 겸손', videoId: 'h98EhjOHF7I'),
    YouTubeCurated(title: '잠언 23장 - 술꾼과 탐식가', videoId: '5tSb84D2zEg'),
    YouTubeCurated(title: '잠언 24장 - 원수의 넘어짐', videoId: 'FCqNHTEjdmc'),
    YouTubeCurated(title: '잠언 25장 - 원수에게 먹을 것을', videoId: 'ldS-Dc5NCHU'),
    YouTubeCurated(title: '잠언 26장 - 미련한 자에게', videoId: 'QHfRT851qaM'),
    YouTubeCurated(title: '잠언 27장 - 내일 자랑 말라', videoId: '8PQk_BE9rHI'),
    YouTubeCurated(title: '잠언 28장 - 악인과 의인', videoId: 'vyYYh98YFro'),
    YouTubeCurated(title: '잠언 29장 - 훈계와 징계', videoId: 'gbLugaaHDPs'),
    YouTubeCurated(title: '잠언 30장 - 아굴의 고백', videoId: 'h9kuWr-MlZg'),
    YouTubeCurated(title: '잠언 31장 - 현숙한 여인', videoId: '43OLuyK4O0E'),
  ];

  // ─── 신학 / 교양 (13) ───
  static const _theology = <YouTubeCurated>[
    YouTubeCurated(title: '신은 존재하는가? 5가지 증거', videoId: 'HeUXHLuq7GE'),
    YouTubeCurated(title: '성경은 믿을 수 있는 책인가?', videoId: 'zgPFMfoLA_Q'),
    YouTubeCurated(title: '악이 존재하면 신은 왜?', videoId: 'WSMKF87AHMw'),
    YouTubeCurated(title: '아퀴나스 - 신 존재 5가지 증명', videoId: '3KXV10EK3ac'),
    YouTubeCurated(title: '아우구스티누스 고백록', videoId: 'yan26NLR9Mw'),
    YouTubeCurated(title: '주기도문 해설 완전판', videoId: 'U3LnEV1ZVI0'),
    YouTubeCurated(title: '주기도문 따라하기 1분', videoId: 'jcM3tWWasNA'),
    YouTubeCurated(title: '전도서 - 미니멀리즘 선언문', videoId: 'SPUWo8z99UA'),
    YouTubeCurated(title: '욥기 - 고통의 의미', videoId: '9vYugYMoKeo'),
    YouTubeCurated(title: '요한복음 로고스의 비밀', videoId: 'oZ9OcxtLY-o'),
    YouTubeCurated(title: '시편 1편 해설 - 복 있는 사람', videoId: 'ju53kcIPvl4'),
    YouTubeCurated(title: '일요일만 크리스천인 사람들', videoId: 'uNDXfcCXzf0'),
    YouTubeCurated(title: '20년 교회 다녀도 기도 모르는 이유', videoId: 'sq0Srm3-PWM'),
  ];

  // ─── 전체 풀 (매일 추천용) ───
  static final _allPool = <YouTubeCurated>[
    ..._worship, ..._comfort, ..._sleep, ..._bibleStory,
    ..._animation, ..._people, ..._proverbs, ..._theology,
  ];

  // ─── 감정별 추천 ───
  static final _categoryMap = <String, List<YouTubeCurated>>{
    'anxiety': [
      const YouTubeCurated(title: '지친 당신을 위한 기도', videoId: 'PYSEV8wL7pQ'),
      const YouTubeCurated(title: '잠언 재즈 BGM - 마음의 평안', videoId: '0Xw7GhOiGMc'),
    ],
    'sadness': [
      const YouTubeCurated(title: '본회퍼의 마지막 편지', videoId: 'fZxMRucMl2E'),
      const YouTubeCurated(title: '시편 찬양 - 고난 속 신뢰', videoId: 'TKjKBB1FjAA'),
    ],
    'relationship': [
      const YouTubeCurated(title: '교회에서 일어난 5가지 실화', videoId: 'iCcla2FHigk'),
      const YouTubeCurated(title: '베드로 - 3번 배신한 남자의 회복', videoId: 'B2-tVJLngIg'),
    ],
    'gratitude': [
      const YouTubeCurated(title: '찬양의 성전 예루살렘 CCM', videoId: 'Tfa3LICdcQQ'),
      const YouTubeCurated(title: '시편 찬양 Vol.1', videoId: 'ptmYVr7yu-M'),
    ],
    'anger': [
      const YouTubeCurated(title: '카페 요한복음 재즈', videoId: '-_hKJ7-3dJg'),
      const YouTubeCurated(title: '잠언 15장 - 온유한 대답', videoId: 'FSvwvF92UU8'),
    ],
    'tired': [
      const YouTubeCurated(title: '지친 당신을 위한 기도', videoId: 'PYSEV8wL7pQ'),
      const YouTubeCurated(title: '잠잘 때 시편 찬양 1시간', videoId: 'pEaGVQH75U4'),
    ],
    'sleepless': [
      const YouTubeCurated(title: '시편 찬양 Vol.4 1시간', videoId: 'pEaGVQH75U4'),
      const YouTubeCurated(title: '잠언 재즈 BGM 30분', videoId: '0Xw7GhOiGMc'),
    ],
    'joy': [
      const YouTubeCurated(title: '호산나 EDM 댄스 찬양', videoId: '4idGCHtaJfA'),
      const YouTubeCurated(title: 'CCM 찬양 모음 1시간', videoId: '6p8EH-zBUIk'),
    ],
    'lost': [
      const YouTubeCurated(title: '잠언 3장 - 여호와를 신뢰하라', videoId: 'CBoavL7HEAs'),
      const YouTubeCurated(title: '10년 만에 교회를 찾은 청년', videoId: 'ILlDm39FOtE'),
    ],
    'courage': [
      const YouTubeCurated(title: '시편 23편 힙합', videoId: 'ULRlwuhbqh0'),
      const YouTubeCurated(title: '단편영화 사울', videoId: 'B9xl7ap5heI'),
    ],
  };
}

/// 유튜브 테마별 섹션
class YouTubeSection {
  final String title;
  final String subtitle;
  final List<YouTubeCurated> videos;
  const YouTubeSection({required this.title, required this.subtitle, required this.videos});
}
