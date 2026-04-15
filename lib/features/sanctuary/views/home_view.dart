import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/models/emotion_models.dart';
import '../../../core/services/emotion_match_service.dart';
import '../../../core/services/youtube_curation_service.dart';
import '../../../shared/widgets/youtube_card.dart';
import '../../sleep/views/sleep_mode_view.dart';
import '../../reading_plan/views/reading_plan_view.dart';

class HomeView extends StatelessWidget {
  final VoidCallback? onNavigateToBible;
  final VoidCallback? onNavigateToCounsel;
  final void Function(int bookId, int chapter)? onNavigateToVerse;

  const HomeView({super.key, this.onNavigateToBible, this.onNavigateToCounsel, this.onNavigateToVerse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bible = BibleDataService();
    final settings = SettingsService();
    final ytService = YoutubeCurationService();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        RepaintBoundary(child: _VerseOfDayCard(isDark: isDark, bible: bible, onTap: onNavigateToVerse)),
        ListenableBuilder(
          listenable: settings,
          builder: (_, __) {
            if (settings.streakDays <= 0) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: EdenColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: EdenColors.accent.withValues(alpha: 0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.local_fire_department_rounded, size: 20, color: EdenColors.accent),
                  const SizedBox(width: 8),
                  Text('연속 ${settings.streakDays}일 읽기 중', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? EdenColors.accentLight : EdenColors.primaryDark)),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        _HealingQuickEntry(isDark: isDark, onTap: onNavigateToCounsel),
        const SizedBox(height: 14),
        _SleepModeEntry(isDark: isDark),
        const SizedBox(height: 24),
        _IconMenuGrid(isDark: isDark, onBible: onNavigateToBible, onCounsel: onNavigateToCounsel),
        const SizedBox(height: 28),
        RepaintBoundary(child: YouTubeCarousel(videos: ytService.getDailyRecommendations(), title: '오늘의 추천')),
        const SizedBox(height: 16),
        RepaintBoundary(child: _YouTubeSections(sections: ytService.getSections(), isDark: isDark)),
        const SizedBox(height: 20),
        RepaintBoundary(child: _ProgressSection(isDark: isDark, theme: theme, settings: settings, bible: bible, onNavigateToVerse: onNavigateToVerse)),
        const SizedBox(height: 32),
      ]),
    );
  }
}

// ─── 넷플릭스 스타일 유튜브 섹션 ───
class _YouTubeSections extends StatelessWidget {
  final List<YouTubeSection> sections; final bool isDark;
  const _YouTubeSections({required this.sections, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Column(children: sections.map((section) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(section.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
            const SizedBox(height: 2),
            Text(section.subtitle, style: TextStyle(fontSize: 11, color: EdenColors.textTertiaryLight)),
          ])),
          Text('${section.videos.length}편', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: EdenColors.secondary)),
        ]),
        const SizedBox(height: 12),
        SizedBox(height: 168, child: ListView.builder(scrollDirection: Axis.horizontal, clipBehavior: Clip.none, itemCount: section.videos.length,
          itemBuilder: (context, index) => YouTubeCard(video: section.videos[index]))),
      ]),
    )).toList());
  }
}

// ─── 힐링 빠른 진입 ───
class _HealingQuickEntry extends StatelessWidget {
  final bool isDark; final VoidCallback? onTap;
  const _HealingQuickEntry({required this.isDark, this.onTap});

  /// 날짜 기반 고정 미리보기 (빌드마다 shuffle 방지)
  static List<EmotionCategory>? _cachedPreview;
  static int _cachedDay = -1;
  static List<EmotionCategory> _getPreview(List<EmotionCategory> emotions) {
    final today = DateTime.now().day;
    if (_cachedPreview != null && _cachedDay == today) return _cachedPreview!;
    final list = emotions.toList()..shuffle();
    _cachedPreview = list.take(3).toList();
    _cachedDay = today;
    return _cachedPreview!;
  }

  @override
  Widget build(BuildContext context) {
    final emotions = EmotionMatchService().categories;
    final preview = _getPreview(emotions);
    return GestureDetector(onTap: onTap, child: Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [EdenColors.accent.withValues(alpha: isDark ? 0.2 : 0.1), EdenColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22), border: Border.all(color: EdenColors.accent.withValues(alpha: 0.15))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('지금 마음이 어떠세요?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
          const SizedBox(height: 6),
          Text('탭 한 번이면 당신을 위한 말씀을 찾아드려요', style: TextStyle(fontSize: 12, color: EdenColors.textTertiaryLight, height: 1.4)),
          const SizedBox(height: 12),
          Row(children: preview.map((cat) => Container(
            margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06), borderRadius: BorderRadius.circular(20)),
            child: Text('${cat.emoji} ${cat.label}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? EdenColors.textSecondaryDark : EdenColors.textSecondaryLight)),
          )).toList()),
        ])),
        const SizedBox(width: 12),
        Container(width: 44, height: 44, decoration: BoxDecoration(color: EdenColors.accent.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(Icons.favorite_rounded, size: 22, color: EdenColors.accent)),
      ]),
    ));
  }
}

// ─── 수면 묵상 진입 ───
class _SleepModeEntry extends StatelessWidget {
  final bool isDark;
  const _SleepModeEntry({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepModeView())),
      child: Container(width: double.infinity, padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color(0xFF1A1A2E).withValues(alpha: 0.9), const Color(0xFF16213E).withValues(alpha: 0.85)]),
          borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.nightlight_round, size: 20, color: Colors.amber.withValues(alpha: 0.8))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('수면 묵상', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9))),
            const SizedBox(height: 2),
            Text('잔잔한 말씀과 함께 잠들기', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withValues(alpha: 0.3)),
        ])));
  }
}

// ─── 오늘의 말씀 ───
class _VerseOfDayCard extends StatelessWidget {
  final bool isDark; final BibleDataService bible;
  final void Function(int bookId, int chapter)? onTap;
  const _VerseOfDayCard({required this.isDark, required this.bible, this.onTap});
  @override
  Widget build(BuildContext context) {
    final verse = bible.getDailyVerse();
    String verseText;
    if (verse != null) {
      verseText = verse.krv.isNotEmpty ? verse.krv : verse.kjv;
    } else {
      verseText = '여호와는 나의 목자시니 내게 부족함이 없으리로다';
    }
    final verseRef = verse?.refKo ?? '시편 23:1';
    return GestureDetector(
      onTap: () { if (verse != null) onTap?.call(verse.bookId, verse.chapter); },
      child: Container(width: double.infinity, height: 360, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset('assets/images/home/verse_card.jpg', fit: BoxFit.cover, cacheWidth: 720),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [EdenColors.primary.withValues(alpha: 0.2), EdenColors.primary.withValues(alpha: 0.85)]))),
          Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
            Row(children: [Container(width: 32, height: 1, color: Colors.white.withValues(alpha: 0.6)), const SizedBox(width: 12),
              Text('오늘의 말씀', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 3))]),
            const SizedBox(height: 16),
            Text('"$verseText"', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, height: 1.5, letterSpacing: -0.5), maxLines: 5, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(children: [
              Text('$verseRef • 개역한글', style: TextStyle(fontSize: 13, color: EdenColors.accentLight, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('읽으러 가기', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4), Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                ])),
            ]),
          ])),
        ])));
  }
}

// ─── 메뉴 그리드 ───
class _IconMenuGrid extends StatelessWidget {
  final bool isDark; final VoidCallback? onBible, onCounsel;
  const _IconMenuGrid({required this.isDark, this.onBible, this.onCounsel});
  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6, children: [
      _MenuCard(image: 'assets/images/home/menu_bible.jpg', icon: Icons.menu_book_rounded, label: '성경 읽기', color: EdenColors.primary, isDark: isDark, onTap: onBible),
      _MenuCard(image: 'assets/images/home/menu_counsel.jpg', icon: Icons.favorite_rounded, label: '마음 힐링', color: EdenColors.accent, isDark: isDark, onTap: onCounsel),
    ]);
  }
}

class _MenuCard extends StatelessWidget {
  final String image; final IconData icon; final String label; final Color color; final bool isDark; final VoidCallback? onTap;
  const _MenuCard({required this.image, required this.icon, required this.label, required this.color, required this.isDark, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Stack(fit: StackFit.expand, children: [
        Image.asset(image, fit: BoxFit.cover, cacheWidth: 400),
        Container(color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.6 : 0.75)),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: (isDark ? EdenColors.surfaceDark : Colors.white).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 26, color: color)),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? EdenColors.textSecondaryDark : EdenColors.textSecondaryLight)),
        ]),
      ])));
  }
}

// ─── 읽기 여정 + 읽기 플랜 + 최근 읽은 말씀 ───
class _ProgressSection extends StatelessWidget {
  final bool isDark; final ThemeData theme; final SettingsService settings; final BibleDataService bible;
  final void Function(int bookId, int chapter)? onNavigateToVerse;
  const _ProgressSection({required this.isDark, required this.theme, required this.settings, required this.bible, this.onNavigateToVerse});
  @override
  Widget build(BuildContext context) {
    final progress = settings.readingProgress;
    final progressPercent = (progress * 100).toInt();
    final lastBookId = settings.lastReadBookId;
    final lastChapter = settings.lastReadChapter;
    final lastBook = bible.books.isNotEmpty ? bible.books.firstWhere((b) => b.id == lastBookId, orElse: () => bible.books.first) : null;
    final lastVerse = bible.isLoaded ? bible.getVerse(lastBookId, lastChapter, 1) : null;

    return Column(children: [
      // ─── 읽기 여정 카드 ───
      Container(width: double.infinity, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Stack(children: [
          Positioned.fill(child: Image.asset('assets/images/home/progress_card.jpg', fit: BoxFit.cover, cacheWidth: 720)),
          Positioned.fill(child: Container(color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.7 : 0.88))),
          Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('읽기 여정', style: theme.textTheme.headlineSmall), const SizedBox(height: 4),
                Text(settings.hasReadingPlan ? settings.planLabel : '통독 플랜',
                  style: TextStyle(fontSize: 11, color: EdenColors.textTertiaryLight, letterSpacing: 2, fontWeight: FontWeight.w600)),
              ]),
              Text('$progressPercent%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, color: EdenColors.primary)),
            ]),
            const SizedBox(height: 20),
            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), valueColor: AlwaysStoppedAnimation(EdenColors.primary))),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: ElevatedButton.icon(
                onPressed: () => onNavigateToVerse?.call(lastBookId, lastChapter),
                icon: const Text('이어서 읽기'), label: const Icon(Icons.arrow_forward, size: 18),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)))),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingPlanView(onNavigateToVerse: onNavigateToVerse))),
                style: OutlinedButton.styleFrom(foregroundColor: EdenColors.primary, side: BorderSide(color: EdenColors.primary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.checklist_rounded, size: 18, color: EdenColors.primary), const SizedBox(width: 6),
                  Text('통독표', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: EdenColors.primary)),
                ]),
              ),
            ]),
          ])),
        ])),
      const SizedBox(height: 12),

      // ─── 최근 읽은 말씀 ───
      GestureDetector(
        onTap: () => onNavigateToVerse?.call(lastBookId, lastChapter),
        child: Container(width: double.infinity, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: Stack(children: [
            Positioned.fill(child: Image.asset('assets/images/home/recent_verse_card.jpg', fit: BoxFit.cover, cacheWidth: 720)),
            Positioned.fill(child: Container(color: const Color(0xFFD9E7CB).withValues(alpha: 0.85))),
            Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.history_rounded, size: 16, color: EdenColors.primaryDark), const SizedBox(width: 8),
                Text('최근 읽은 말씀', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EdenColors.primaryDark, letterSpacing: 2)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: EdenColors.primaryDark.withValues(alpha: 0.4)),
              ]),
              const SizedBox(height: 14),
              Text(lastBook != null ? '${lastBook.nameKo} $lastChapter장' : '창세기 1장', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: EdenColors.primaryDark)),
              const SizedBox(height: 8),
              Text(lastVerse != null ? '"${lastVerse.krv}"' : '"태초에 하나님이 천지를 창조하시니라"', style: TextStyle(fontSize: 14, color: EdenColors.primaryDark.withValues(alpha: 0.7), height: 1.6), maxLines: 2, overflow: TextOverflow.ellipsis),
            ])),
          ])),
      ),
    ]);
  }
}
