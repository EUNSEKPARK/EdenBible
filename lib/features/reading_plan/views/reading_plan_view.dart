import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/services/bible_data_service.dart';
import '../../../core/services/settings_service.dart';

/// 읽기 플랜 (통독표) 화면
class ReadingPlanView extends StatefulWidget {
  final void Function(int bookId, int chapter)? onNavigateToVerse;
  const ReadingPlanView({super.key, this.onNavigateToVerse});

  @override
  State<ReadingPlanView> createState() => _ReadingPlanViewState();
}

class _ReadingPlanViewState extends State<ReadingPlanView> {
  final _settings = SettingsService();
  final _bible = BibleDataService();

  @override
  void initState() { super.initState(); _settings.addListener(_refresh); }
  void _refresh() { if (mounted) setState(() {}); }
  @override
  void dispose() { _settings.removeListener(_refresh); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
        elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('읽기 플랜', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        actions: _settings.hasReadingPlan ? [
          IconButton(icon: Icon(Icons.restart_alt_rounded, size: 22, color: EdenColors.textTertiaryLight), onPressed: _showCancelDialog, tooltip: '플랜 변경'),
        ] : null,
      ),
      body: _settings.hasReadingPlan
          ? _PlanDashboard(settings: _settings, bible: _bible, isDark: isDark, onNavigateToVerse: widget.onNavigateToVerse)
          : _PlanSelector(onSelect: _startPlan, isDark: isDark),
    );
  }

  void _startPlan(String planType) {
    _settings.startReadingPlan(planType);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_settings.planLabel}을 시작합니다!'), behavior: SnackBarBehavior.floating));
  }

  void _showCancelDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('플랜 변경'),
      content: const Text('현재 플랜을 중단하고 새로운 플랜을 선택하시겠어요?\n읽기 기록은 유지됩니다.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
        TextButton(onPressed: () { Navigator.pop(ctx); _settings.cancelReadingPlan(); }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('변경하기')),
      ],
    ));
  }
}

// ═══ 플랜 선택 ═══
class _PlanSelector extends StatelessWidget {
  final void Function(String planType) onSelect;
  final bool isDark;
  const _PlanSelector({required this.onSelect, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 20),
      Icon(Icons.auto_stories_rounded, size: 64, color: EdenColors.primary.withValues(alpha: 0.3)),
      const SizedBox(height: 20),
      Text('성경 통독 플랜', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
      const SizedBox(height: 8),
      Text('66권 1,189장을 체계적으로 읽어보세요', style: TextStyle(fontSize: 16, color: EdenColors.textTertiaryLight)),
      const SizedBox(height: 36),
      _PlanOptionCard(emoji: '🏃', title: '3개월 통독', subtitle: '하루 약 13장 · 빠르게 한 바퀴', description: '집중적으로 성경 전체를 빠르게 읽고 싶은 분', color: const Color(0xFFE74C3C), isDark: isDark, onTap: () => onSelect('3month')),
      const SizedBox(height: 14),
      _PlanOptionCard(emoji: '🚶', title: '6개월 통독', subtitle: '하루 약 7장 · 꾸준히 균형 있게', description: '적당한 속도로 묵상하며 읽고 싶은 분', color: const Color(0xFFF39C12), isDark: isDark, onTap: () => onSelect('6month')),
      const SizedBox(height: 14),
      _PlanOptionCard(emoji: '🧘', title: '1년 통독', subtitle: '하루 약 3~4장 · 천천히 깊이 있게', description: '하루 조금씩, 오래 함께하고 싶은 분', color: EdenColors.primary, isDark: isDark, onTap: () => onSelect('1year')),
      const SizedBox(height: 40),
    ]));
  }
}

class _PlanOptionCard extends StatelessWidget {
  final String emoji, title, subtitle, description;
  final Color color; final bool isDark; final VoidCallback onTap;
  const _PlanOptionCard({required this.emoji, required this.title, required this.subtitle, required this.description, required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      width: double.infinity, padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 38)), const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
          const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4), Text(description, style: TextStyle(fontSize: 13, color: EdenColors.textTertiaryLight)),
        ])),
        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color.withValues(alpha: 0.5)),
      ]),
    ));
  }
}

// ═══ 플랜 대시보드 ═══
class _PlanDashboard extends StatelessWidget {
  final SettingsService settings; final BibleDataService bible; final bool isDark;
  final void Function(int bookId, int chapter)? onNavigateToVerse;
  const _PlanDashboard({required this.settings, required this.bible, required this.isDark, this.onNavigateToVerse});

  @override
  Widget build(BuildContext context) {
    final readCount = settings.readChaptersCount;
    final totalCount = SettingsService.totalBibleChapters;
    final percent = (readCount / totalCount * 100).toInt();

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 0), child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [EdenColors.primary, EdenColors.primary.withValues(alpha: 0.8)]), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Text(settings.planLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
            const Spacer(),
            Text('D+${settings.planElapsedDays}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
          ]),
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$percent', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
            const SizedBox(width: 4),
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7)))),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$readCount / $totalCount장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
              const SizedBox(height: 2),
              Text('남은 일수 ${settings.planRemainingDays}일', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
            ]),
          ]),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: settings.planOverallProgress, minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.15), valueColor: const AlwaysStoppedAnimation(Colors.white))),
        ]),
      ))),

      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [
        _MiniStat(icon: Icons.today_rounded, value: '${settings.planDailyChapters}장', label: '하루 목표', color: EdenColors.accent, isDark: isDark),
        const SizedBox(width: 10),
        _MiniStat(icon: Icons.check_circle_outline, value: '${settings.todayReadChapters}장', label: '오늘 읽음', color: EdenColors.primary, isDark: isDark),
        const SizedBox(width: 10),
        _MiniStat(icon: Icons.trending_up_rounded, value: settings.planScheduleProgress >= 1.0 ? '순조' : '지연', label: '일정 상태',
          color: settings.planScheduleProgress >= 1.0 ? const Color(0xFF27AE60) : const Color(0xFFE74C3C), isDark: isDark),
      ]))),

      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
        child: Text('구약 (39권)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: EdenColors.secondary, letterSpacing: 2)))),

      SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= 39 || index >= bible.books.length) return null;
          final book = bible.books[index];
          return _BookCheckRow(book: book, settings: settings, isDark: isDark, onNavigateToVerse: onNavigateToVerse);
        }, childCount: 39))),

      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
        child: Text('신약 (27권)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: EdenColors.accent, letterSpacing: 2)))),

      SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
          final bookIndex = 39 + index;
          if (bookIndex >= bible.books.length) return null;
          return _BookCheckRow(book: bible.books[bookIndex], settings: settings, isDark: isDark, onNavigateToVerse: onNavigateToVerse);
        }, childCount: 27))),

      const SliverToBoxAdapter(child: SizedBox(height: 60)),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon; final String value, label; final Color color; final bool isDark;
  const _MiniStat({required this.icon, required this.value, required this.label, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, size: 20, color: color), const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: EdenColors.textTertiaryLight, letterSpacing: 0.5)),
      ])));
  }
}

// ═══ 책별 체크리스트 ═══
class _BookCheckRow extends StatefulWidget {
  final dynamic book;
  final SettingsService settings; final bool isDark;
  final void Function(int bookId, int chapter)? onNavigateToVerse;
  const _BookCheckRow({required this.book, required this.settings, required this.isDark, this.onNavigateToVerse});
  @override
  State<_BookCheckRow> createState() => _BookCheckRowState();
}

class _BookCheckRowState extends State<_BookCheckRow> {
  bool _expanded = false;

  int get _readCount {
    int c = 0;
    for (int ch = 1; ch <= widget.book.chapterCount; ch++) { if (widget.settings.isChapterRead(widget.book.id, ch)) c++; }
    return c;
  }

  bool get _allRead => _readCount == widget.book.chapterCount;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final readCount = _readCount;
    final progress = book.chapterCount > 0 ? readCount / book.chapterCount : 0.0;
    final isOT = book.testament == 'old';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: widget.isDark ? EdenColors.surfaceVariantDark : Colors.white, borderRadius: BorderRadius.circular(14),
        border: _allRead ? Border.all(color: EdenColors.primary.withValues(alpha: 0.3)) : null),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [
            Container(width: 28, height: 28,
              decoration: BoxDecoration(color: _allRead ? EdenColors.primary : (widget.isDark ? EdenColors.surfaceDark : const Color(0xFFF0EEE8)), borderRadius: BorderRadius.circular(8)),
              child: _allRead ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(book.nameKo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: _allRead ? EdenColors.primary : (widget.isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight))),
              const SizedBox(height: 2),
              Text('$readCount / ${book.chapterCount}장', style: TextStyle(fontSize: 13, color: EdenColors.textTertiaryLight)),
            ])),
            SizedBox(width: 60, child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: progress, minHeight: 5,
              backgroundColor: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(isOT ? EdenColors.primary : EdenColors.accent)))),
            const SizedBox(width: 8),
            Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 20, color: EdenColors.textTertiaryLight),
          ])),
        ),

        if (_expanded) Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Wrap(spacing: 6, runSpacing: 6, children: List.generate(book.chapterCount, (i) {
            final ch = i + 1;
            final isRead = widget.settings.isChapterRead(book.id, ch);
            return GestureDetector(
              onTap: () {
                if (!isRead) widget.settings.markChapterRead(book.id, ch);
                Navigator.pop(context);
                widget.onNavigateToVerse?.call(book.id, ch);
              },
              onLongPress: () {
                // 길게 누르면 읽음 ↔ 읽지않음 토글
                if (isRead) {
                  widget.settings.unmarkChapterRead(book.id, ch);
                } else {
                  widget.settings.markChapterRead(book.id, ch);
                }
              },
              child: Container(width: 40, height: 36,
                decoration: BoxDecoration(
                  color: isRead ? EdenColors.primary.withValues(alpha: 0.15) : (widget.isDark ? EdenColors.surfaceDark : const Color(0xFFF5F3EE)),
                  borderRadius: BorderRadius.circular(8),
                  border: isRead ? Border.all(color: EdenColors.primary.withValues(alpha: 0.3)) : null),
                child: Center(child: Text('$ch', style: TextStyle(fontSize: 14,
                  fontWeight: isRead ? FontWeight.w700 : FontWeight.w400,
                  color: isRead ? EdenColors.primary : EdenColors.textTertiaryLight)))),
            );
          })),
        ),
      ]),
    );
  }
}
