import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/services/settings_service.dart';

/// 앱 사용 설명 튜토리얼 — 스와이프 온보딩 페이지
class TutorialView extends StatefulWidget {
  final VoidCallback onComplete;
  const TutorialView({super.key, required this.onComplete});
  @override
  State<TutorialView> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_TutorialPageData>[
    _TutorialPageData(
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFF5B7553),
      bgGradient: [Color(0xFFE8F5E9), Color(0xFFFFFDF7)],
      title: '성경 읽기',
      subtitle: '66권 전체 성경을 아름답게',
      features: [
        _FeatureItem(Icons.swipe_rounded, '카드 모드', '스와이프로 한 절씩 묵상하세요'),
        _FeatureItem(Icons.list_rounded, '리스트 모드', '전체 장을 한눈에 읽으세요'),
        _FeatureItem(Icons.pinch_rounded, '핀치 줌', '두 손가락으로 글자 크기를 조절하세요'),
        _FeatureItem(Icons.translate_rounded, '개역한글 / KJV', '하단 바에서 번역을 전환하세요'),
      ],
    ),
    _TutorialPageData(
      icon: Icons.play_arrow_rounded,
      iconColor: Color(0xFFC9A96E),
      bgGradient: [Color(0xFFFFF8E1), Color(0xFFFFFDF7)],
      title: '음성 읽기 (TTS)',
      subtitle: '성경을 귀로 들으며 묵상하세요',
      features: [
        _FeatureItem(Icons.play_circle_outline_rounded, '재생', '하단 바의 ▶ 버튼을 누르세요'),
        _FeatureItem(Icons.speed_rounded, '배속 조절', '배속 버튼(1.0x)을 탭해 속도를 바꿔보세요'),
        _FeatureItem(Icons.highlight_rounded, '단어 하이라이트', '읽고 있는 단어가 실시간으로 강조됩니다'),
        _FeatureItem(Icons.touch_app_rounded, '절 선택 후 재생', '절을 탭한 뒤 재생하면 그 절부터 시작됩니다'),
      ],
    ),
    _TutorialPageData(
      icon: Icons.favorite_rounded,
      iconColor: Color(0xFFE57373),
      bgGradient: [Color(0xFFFFEBEE), Color(0xFFFFFDF7)],
      title: '마음 힐링',
      subtitle: '감정에 맞는 말씀으로 위로받으세요',
      features: [
        _FeatureItem(Icons.grid_view_rounded, '10가지 감정', '불안, 슬픔, 외로움 등 감정을 선택하세요'),
        _FeatureItem(Icons.auto_awesome_rounded, '힐링 패키지', '위로 메시지 + 말씀 + 기도문이 한 세트로'),
        _FeatureItem(Icons.chat_bubble_outline_rounded, '채팅 상담', '대화형으로 말씀 상담을 받을 수 있어요'),
      ],
    ),
    _TutorialPageData(
      icon: Icons.nightlight_round,
      iconColor: Color(0xFF7986CB),
      bgGradient: [Color(0xFFE8EAF6), Color(0xFFFFFDF7)],
      title: '수면 묵상',
      subtitle: '잔잔한 말씀과 함께 잠들기',
      features: [
        _FeatureItem(Icons.play_arrow_rounded, '자동 재생', '재생 버튼을 누르면 8초마다 자동 전환'),
        _FeatureItem(Icons.timer_outlined, '수면 타이머', '15분 / 30분 / 60분 후 자동 종료'),
        _FeatureItem(Icons.volume_up_rounded, '음성 읽기', '평안한 말씀을 음성으로 들으세요'),
        _FeatureItem(Icons.dark_mode_rounded, '몰입 모드', '어두운 화면에서 편안하게 잠들 수 있어요'),
      ],
    ),
    _TutorialPageData(
      icon: Icons.bookmark_rounded,
      iconColor: Color(0xFFC9A96E),
      bgGradient: [Color(0xFFFFF3E0), Color(0xFFFFFDF7)],
      title: '북마크 & 공유',
      subtitle: '소중한 말씀을 저장하고 나누세요',
      features: [
        _FeatureItem(Icons.touch_app_rounded, '절 선택', '리스트에서 말씀을 탭하면 선택됩니다'),
        _FeatureItem(Icons.bookmark_add_rounded, '북마크 저장', '말씀을 길게 누르면 북마크에 저장됩니다'),
        _FeatureItem(Icons.copy_rounded, '복사', '선택 후 하단 바에서 복사하세요'),
        _FeatureItem(Icons.share_rounded, '카드 공유', '아름다운 말씀 카드로 공유할 수 있어요'),
      ],
    ),
    _TutorialPageData(
      icon: Icons.auto_graph_rounded,
      iconColor: Color(0xFF5B7553),
      bgGradient: [Color(0xFFE8F5E9), Color(0xFFFFFDF7)],
      title: '더 많은 기능',
      subtitle: '에덴과 함께 매일 말씀 안에서',
      features: [
        _FeatureItem(Icons.calendar_month_rounded, '통독 플랜', '3개월/6개월/1년 성경 통독 계획표'),
        _FeatureItem(Icons.search_rounded, '성경 검색', '키워드로 원하는 말씀을 빠르게 찾기'),
        _FeatureItem(Icons.compare_rounded, '깊이 읽기', '한글/영어 대조로 더 깊이 읽기'),
        _FeatureItem(Icons.local_fire_department_rounded, '연속 읽기', '매일 읽으면 연속 기록이 쌓여요'),
      ],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() async {
    await SettingsService().completeTutorial();
    widget.onComplete();
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      body: SafeArea(
        child: Column(children: [
          // 상단 건너뛰기
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(children: [
              const Spacer(),
              if (!isLast)
                GestureDetector(
                  onTap: _finish,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('건너뛰기', style: TextStyle(fontSize: 13, color: EdenColors.textTertiaryLight, fontWeight: FontWeight.w500)),
                  ),
                ),
            ]),
          ),

          // 페이지
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, index) => _TutorialPage(data: _pages[index], isDark: isDark),
            ),
          ),

          // 하단: 인디케이터 + 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(children: [
              // 인디케이터
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentPage == i ? EdenColors.primary : EdenColors.secondary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // 다음 / 시작하기 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EdenColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(isLast ? '시작하기' : '다음',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    if (!isLast) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                    if (isLast) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.church_rounded, size: 20),
                    ],
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── 튜토리얼 페이지 데이터 ───
class _TutorialPageData {
  final IconData icon;
  final Color iconColor;
  final List<Color> bgGradient;
  final String title;
  final String subtitle;
  final List<_FeatureItem> features;

  const _TutorialPageData({
    required this.icon, required this.iconColor, required this.bgGradient,
    required this.title, required this.subtitle, required this.features,
  });
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final String description;
  const _FeatureItem(this.icon, this.label, this.description);
}

// ─── 개별 튜토리얼 페이지 위젯 ───
class _TutorialPage extends StatelessWidget {
  final _TutorialPageData data;
  final bool isDark;
  const _TutorialPage({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
      child: Column(children: [
        // 아이콘 원형
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: isDark
                ? [data.iconColor.withValues(alpha: 0.3), data.iconColor.withValues(alpha: 0.1)]
                : data.bgGradient,
            ),
            boxShadow: [BoxShadow(color: data.iconColor.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Icon(data.icon, size: 40, color: data.iconColor),
        ),
        const SizedBox(height: 24),

        // 타이틀
        Text(data.title, style: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text(data.subtitle, style: TextStyle(
          fontSize: 15, color: isDark ? EdenColors.textSecondaryDark : EdenColors.textSecondaryLight, letterSpacing: 0.5)),
        const SizedBox(height: 32),

        // 기능 목록 카드
        ...data.features.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? EdenColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: data.iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(f.icon, size: 20, color: data.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.label, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
              const SizedBox(height: 3),
              Text(f.description, style: TextStyle(
                fontSize: 12, color: isDark ? EdenColors.textSecondaryDark : EdenColors.textSecondaryLight, height: 1.4)),
            ])),
          ]),
        )),
      ]),
    );
  }
}
