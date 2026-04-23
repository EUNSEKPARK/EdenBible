import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/theme/eden_theme.dart';
import 'app/theme/colors.dart';
import 'shared/widgets/eden_top_app_bar.dart';
import 'shared/widgets/eden_bottom_nav.dart';
import 'features/sanctuary/views/home_view.dart';
import 'features/bible_reader/views/bible_view.dart';
import 'features/healing/views/emotion_category_view.dart';
import 'features/divine_counsel/views/counsel_view.dart';
import 'features/sleep/views/sleep_mode_view.dart';
import 'features/settings/views/settings_view.dart';
import 'features/tutorial/views/tutorial_view.dart';
import 'core/services/bible_data_service.dart';
import 'core/services/counsel_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/emotion_match_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );
  final settings = SettingsService();
  await settings.init();
  runApp(ProjectEdenApp(settings: settings));
}

class ProjectEdenApp extends StatefulWidget {
  final SettingsService settings;
  const ProjectEdenApp({super.key, required this.settings});
  @override
  State<ProjectEdenApp> createState() => _ProjectEdenAppState();
}

class _ProjectEdenAppState extends State<ProjectEdenApp> {
  @override
  void initState() { super.initState(); widget.settings.addListener(_rebuild); }
  void _rebuild() => setState(() {});
  @override
  void dispose() { widget.settings.removeListener(_rebuild); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '에덴 성경책',
      debugShowCheckedModeBanner: false,
      theme: EdenTheme.light(),
      darkTheme: EdenTheme.dark(),
      themeMode: widget.settings.themeMode,
      builder: (context, child) {
        // 기기 접근성 폰트 배율을 1.0~1.3 범위로 제한
        // (앱 자체에서 글자 크기 조절이 가능하므로 과도한 배율로 레이아웃 붕괴 방지)
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child!,
        );
      },
      home: const EdenSplash(),
    );
  }
}

// ───────── 스플래시 ─────────
class EdenSplash extends StatefulWidget {
  const EdenSplash({super.key});
  @override
  State<EdenSplash> createState() => _EdenSplashState();
}

class _EdenSplashState extends State<EdenSplash> with SingleTickerProviderStateMixin {
  bool _loading = true;
  String _loadingText = '성경 데이터를 준비하고 있어요...';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _initServices();
  }

  @override
  void dispose() { _fadeController.dispose(); super.dispose(); }

  Future<void> _initServices() async {
    try {
      setState(() => _loadingText = '성경 66권을 불러오는 중...');
      await BibleDataService().loadBibleData();
      setState(() => _loadingText = '말씀 상담 데이터를 준비하는 중...');
      await CounselService().loadPresets();
      setState(() => _loadingText = '감정 매칭 데이터를 준비하는 중...');
      await EmotionMatchService().load();
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loadingText = '데이터 로드 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading) {
      final settings = SettingsService();
      if (!settings.hasSeenTutorial) {
        return TutorialView(onComplete: () { if (mounted) setState(() {}); });
      }
      return const EdenShell();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFDF7),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(flex: 3),
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: EdenColors.primary.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 16))]),
            child: ClipOval(child: Image.asset('assets/images/icon.jpg', fit: BoxFit.cover)),
          ),
          const SizedBox(height: 32),
          Text('에덴', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: EdenColors.primary, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('당신을 천국으로 이끄는 성경책', style: TextStyle(fontSize: 16, color: isDark ? EdenColors.secondaryLight : EdenColors.secondary, letterSpacing: 1.5)),
          const Spacer(flex: 2),
          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(EdenColors.primaryLight))),
          const SizedBox(height: 14),
          Text(_loadingText, style: TextStyle(fontSize: 14, color: isDark ? EdenColors.textTertiaryDark : EdenColors.textTertiaryLight)),
          const Spacer(flex: 1),
        ])),
      ),
    );
  }
}

// ───────── 메인 셸 ─────────
class EdenShell extends StatefulWidget {
  const EdenShell({super.key});
  @override
  State<EdenShell> createState() => _EdenShellState();
}

class _EdenShellState extends State<EdenShell> {
  int _currentIndex = 0;
  final _bibleViewKey = GlobalKey<BibleViewState>();
  bool _sleepBarsHidden = true;  // 수면 모드 진입 시 바 숨김

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 4) _sleepBarsHidden = true;  // 수면 모드 진입 시 자동 전체화면
    });
  }

  void _navigateToBibleChapter(int bookId, int chapter) {
    setState(() => _currentIndex = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bibleViewKey.currentState?.navigateTo(bookId, chapter);
    });
  }

  void _toggleSleepBars() => setState(() => _sleepBarsHidden = !_sleepBarsHidden);

  void _exitSleepMode() {
    setState(() { _sleepBarsHidden = false; _currentIndex = 0; });
  }

  @override
  Widget build(BuildContext context) {
    final bool isHealingView = _currentIndex == 2;
    final bool isSleepView = _currentIndex == 4;
    final bool hideBars = isSleepView && _sleepBarsHidden;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 수면 모드 전체화면: AppBar와 BottomNav 숨김
    PreferredSizeWidget? appBar;
    if (hideBars) {
      appBar = null;
    } else if (isHealingView || isSleepView) {
      appBar = AppBar(
        backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
        elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => _navigateTo(0)),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(isHealingView ? Icons.favorite_rounded : Icons.nightlight_round, size: 18, color: isHealingView ? EdenColors.accent : Colors.amber),
          const SizedBox(width: 8),
          Text(isHealingView ? '마음 힐링' : '수면 묵상'),
        ]),
        actions: isHealingView ? [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline_rounded, size: 20, color: EdenColors.secondary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('채팅 상담'), centerTitle: true),
              body: const CounselView(),
            ))),
            tooltip: '채팅 상담',
          ),
        ] : null,
      );
    } else {
      appBar = EdenTopAppBar(
        onNavigateToBible: () => _navigateTo(1),
        onNavigateToCounsel: () => _navigateTo(2),
        onNavigateToSettings: () => _navigateTo(5),
        onNavigateToVerse: _navigateToBibleChapter,
      );
    }

    return Scaffold(
      extendBody: hideBars,
      extendBodyBehindAppBar: hideBars,
      appBar: appBar,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(
            onNavigateToBible: () => _navigateTo(1),
            onNavigateToCounsel: () => _navigateTo(2),
            onNavigateToVerse: _navigateToBibleChapter,
          ),
          BibleView(key: _bibleViewKey),
          const EmotionCategoryView(),
          _BookmarksView(onNavigateToVerse: _navigateToBibleChapter),
          SleepModeView(
            onToggleFullscreen: _toggleSleepBars,
            onClose: _exitSleepMode,
          ),
          const SettingsView(),
        ],
      ),
      bottomNavigationBar: hideBars ? null : EdenBottomNav(currentIndex: _currentIndex, onTap: _navigateTo),
    );
  }
}

// ───────── 북마크 ─────────
class _BookmarksView extends StatelessWidget {
  final void Function(int bookId, int chapter)? onNavigateToVerse;
  const _BookmarksView({this.onNavigateToVerse});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final bible = BibleDataService();
    final bookmarks = settings.parsedBookmarks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (bookmarks.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/images/shared/empty_bookmark.jpg', width: 120, height: 120, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.bookmark_outline_rounded, size: 80, color: EdenColors.textTertiaryLight)),
        const SizedBox(height: 16),
        Text('북마크가 비어 있습니다', style: TextStyle(fontSize: 16, color: EdenColors.textTertiaryLight, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('성경 읽기에서 구절을 길게 누르면 저장됩니다', style: TextStyle(fontSize: 14, color: EdenColors.textTertiaryLight)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bm = bookmarks[index];
        final verse = bible.getVerse(bm[0], bm[1], bm[2]);
        if (verse == null) return const SizedBox();
        final verseText = verse.krv.isNotEmpty ? verse.krv : verse.kjv;
        return GestureDetector(
          onTap: () => onNavigateToVerse?.call(bm[0], bm[1]),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.bookmark_rounded, size: 16, color: EdenColors.accent),
                const SizedBox(width: 8),
                Text(verse.refKo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: EdenColors.primary)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: EdenColors.textTertiaryLight),
              ]),
              const SizedBox(height: 8),
              Text(verseText, style: const TextStyle(fontSize: 17, height: 1.6), maxLines: 3, overflow: TextOverflow.ellipsis),
            ]),
          ),
        );
      },
    );
  }
}
