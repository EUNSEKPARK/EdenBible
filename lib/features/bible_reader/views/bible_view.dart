import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../shared/widgets/share_verse_card.dart';
import 'visual_book_grid.dart'; // getBookThumbnail 포함

class BibleView extends StatefulWidget {
  const BibleView({super.key});
  @override
  BibleViewState createState() => BibleViewState();
}

class BibleViewState extends State<BibleView> {
  final _bible = BibleDataService();
  final _settings = SettingsService();
  final _tts = TtsService();
  int _bookId = 1;
  int _chapter = 1;
  String _translation = 'krv';
  List<BibleVerse> _verses = [];
  double _pinchStartFontSize = 20.0;
  bool _cardMode = false;
  int _selectedVerseIndex = -1;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    _tts.addListener(_onTtsChanged);
    _bookId = _settings.lastReadBookId;
    _chapter = _settings.lastReadChapter;
    _translation = _settings.translation;
    _loadVerses();
  }

  void _onSettingsChanged() { if (mounted) setState(() => _translation = _settings.translation); }
  void _onTtsChanged() { if (mounted) setState(() {}); }
  @override
  void dispose() { _settings.removeListener(_onSettingsChanged); _tts.removeListener(_onTtsChanged); super.dispose(); }
  void _loadVerses() { setState(() { _verses = _bible.getVerses(_bookId, _chapter); _selectedVerseIndex = -1; }); }

  void navigateTo(int bookId, int chapter) => _goToChapter(bookId, chapter);

  void _goToChapter(int bookId, int chapter) {
    _tts.stop();
    _bookId = bookId; _chapter = chapter; _loadVerses();
    _settings.setLastRead(bookId, chapter); _settings.markChapterRead(bookId, chapter);
  }

  void _nextChapter() {
    final maxCh = _bible.getChapterCount(_bookId);
    if (_chapter < maxCh) _goToChapter(_bookId, _chapter + 1);
    else if (_bookId < 66) _goToChapter(_bookId + 1, 1);
  }

  void _prevChapter() {
    if (_chapter > 1) _goToChapter(_bookId, _chapter - 1);
    else if (_bookId > 1) _goToChapter(_bookId - 1, _bible.getChapterCount(_bookId - 1));
  }

  void _openVisualBookGrid() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => VisualBookGrid(onSelect: (bookId, chapter) => _goToChapter(bookId, chapter))));
  }

  void _onVerseTap(int index) {
    setState(() => _selectedVerseIndex = _selectedVerseIndex == index ? -1 : index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final book = _bible.books.isNotEmpty ? _bible.books.firstWhere((b) => b.id == _bookId, orElse: () => _bible.books.first) : null;
    final fontSize = _settings.fontSize;
    final activeVerse = _tts.currentVerseIndex;
    final selectedVerse = (_selectedVerseIndex >= 0 && _selectedVerseIndex < _verses.length) ? _verses[_selectedVerseIndex] : null;

    return Stack(children: [
      Column(children: [
        _TopSelector(bible: _bible, bookId: _bookId, chapter: _chapter, isDark: isDark, cardMode: _cardMode,
          onOpenGrid: _openVisualBookGrid, onToggleMode: () => setState(() => _cardMode = !_cardMode),
          onPrev: _prevChapter, onNext: _nextChapter),
        Expanded(
          child: _cardMode
              ? _CardSwipeView(verses: _verses, book: book, chapter: _chapter, translation: _translation,
                  fontSize: fontSize, isDark: isDark, settings: _settings, onNext: _nextChapter, onPrev: _prevChapter, activeVerseIndex: activeVerse, bookId: _bookId, wordStart: _tts.wordStart, wordEnd: _tts.wordEnd)
              : _ListReadView(verses: _verses, book: book, chapter: _chapter, translation: _translation,
                  fontSize: fontSize, isDark: isDark, bible: _bible, bookId: _bookId,
                  settings: _settings, onNext: _nextChapter, onPrev: _prevChapter,
                  activeVerseIndex: activeVerse, selectedVerseIndex: _selectedVerseIndex,
                  wordStart: _tts.wordStart, wordEnd: _tts.wordEnd,
                  onVerseTap: _onVerseTap,
                  onPinchStart: (d) { if (d.pointerCount >= 2) _pinchStartFontSize = _settings.fontSize; },
                  onPinchUpdate: (d) { if (d.pointerCount >= 2) { _settings.setFontSize((_pinchStartFontSize * d.scale).clamp(14.0, 48.0)); } }),
        ),
      ]),
      // ─── 통합 하단 바 ───
      Positioned(left: 16, right: 16, bottom: 16,
        child: _UnifiedBottomBar(
          translation: _translation, isDark: isDark, verses: _verses,
          selectedVerse: selectedVerse, bookId: _bookId, chapter: _chapter, settings: _settings,
          onToggleTranslation: () { setState(() => _translation = _translation == 'krv' ? 'kjv' : 'krv'); _settings.setTranslation(_translation); },
          onCloseSelection: () => setState(() => _selectedVerseIndex = -1),
        )),
    ]);
  }
}

// ═══════════════════════════════════════════════════
//  통합 하단 바 (번역 토글 + TTS + 절 액션 통합)
// ═══════════════════════════════════════════════════
class _UnifiedBottomBar extends StatelessWidget {
  final String translation; final bool isDark; final List<BibleVerse> verses;
  final BibleVerse? selectedVerse; final int bookId, chapter;
  final SettingsService settings; final VoidCallback onToggleTranslation, onCloseSelection;

  const _UnifiedBottomBar({
    required this.translation, required this.isDark, required this.verses,
    required this.selectedVerse, required this.bookId, required this.chapter,
    required this.settings, required this.onToggleTranslation, required this.onCloseSelection,
  });

  @override
  Widget build(BuildContext context) {
    final tts = TtsService();
    final hasSelection = selectedVerse != null;
    String text = '';
    if (hasSelection) {
      if (translation == 'krv') {
        text = selectedVerse!.krv.isNotEmpty ? selectedVerse!.krv : selectedVerse!.kjv;
      } else {
        text = selectedVerse!.kjv;
      }
    }
    final ref = hasSelection ? selectedVerse!.refKo : '';
    final isBookmarked = hasSelection ? settings.isBookmarked(bookId, chapter, selectedVerse!.verse) : false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: hasSelection ? 10 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? EdenColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 6))],
        border: Border.all(color: hasSelection ? EdenColors.primary.withValues(alpha: 0.2) : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
      ),
      child: Row(children: [
        // ─── 절 선택 시: 절 번호 + 복사/공유/저장 ───
        if (hasSelection) ...[
          GestureDetector(
            onTap: onCloseSelection,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: EdenColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${selectedVerse!.verse}절', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: EdenColors.primary)),
                const SizedBox(width: 4),
                Icon(Icons.close_rounded, size: 12, color: EdenColors.primary),
              ])),
          ),
          const SizedBox(width: 4),
          _BarIcon(icon: Icons.copy_rounded, onTap: () {
            Clipboard.setData(ClipboardData(text: '$text\n- $ref'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('구절을 복사했습니다'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)));
          }),
          _BarIcon(icon: Icons.share_outlined, onTap: () => showShareCardSheet(context, verseText: text, verseRef: ref)),
          _BarIcon(icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            color: isBookmarked ? EdenColors.accent : null,
            onTap: () { final was = isBookmarked; settings.toggleBookmark(bookId, chapter, selectedVerse!.verse);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(was ? '북마크 해제' : '북마크 저장'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)));
            }),
          Container(width: 1, height: 20, margin: const EdgeInsets.symmetric(horizontal: 4),
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
        ],

        // ─── 절 미선택 시: 번역 토글 ───
        if (!hasSelection)
          GestureDetector(onTap: onToggleTranslation, child: Container(padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(50)),
            child: Row(children: [_Pill(label: '개역한글', isActive: translation == 'krv'), _Pill(label: 'KJV', isActive: translation == 'kjv')]))),

        const Spacer(),

        // ─── 공통: 배속 + 재생 ───
        if (!hasSelection)
          GestureDetector(onTap: () {
            if (verses.isNotEmpty) {
              final firstVerseText = verses.first.krv.isNotEmpty ? verses.first.krv : verses.first.kjv;
              showShareCardSheet(context, verseText: firstVerseText, verseRef: verses.first.refKo);
            }
          }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.share_outlined, size: 20, color: EdenColors.textSecondaryLight))),

        ListenableBuilder(listenable: tts, builder: (_, __) => GestureDetector(onTap: () => tts.cycleSpeed(),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(color: EdenColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(tts.speedLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: EdenColors.primary))))),

        ListenableBuilder(listenable: tts, builder: (_, __) {
          final playing = tts.isPlaying;
          return GestureDetector(onTap: () {
            if (playing) { tts.stop(); return; }
            if (hasSelection) {
              // 선택된 절부터 끝까지 읽기 (하이라이트도 정확한 위치에 표시)
              final startIdx = verses.indexOf(selectedVerse!);
              final offset = startIdx >= 0 ? startIdx : 0;
              final texts = verses.skip(offset).map((v) {
                if (translation == 'krv') {
                  return v.krv.isNotEmpty ? v.krv : v.kjv;
                } else {
                  return v.kjv;
                }
              }).toList();
              if (texts.isEmpty) return;
              translation == 'kjv' ? tts.setEnglish() : tts.setKorean(); tts.speakVerses(texts, startOffset: offset);
            } else {
              final texts = verses.map((v) {
                if (translation == 'krv') {
                  return v.krv.isNotEmpty ? v.krv : v.kjv;
                } else {
                  return v.kjv;
                }
              }).toList();
              if (texts.isEmpty) return;
              translation == 'kjv' ? tts.setEnglish() : tts.setKorean(); tts.speakVerses(texts);
            }
          }, child: Container(width: 42, height: 42, margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(color: playing ? EdenColors.primary.withValues(alpha: 0.2) : EdenColors.primaryLight.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(playing ? Icons.stop_rounded : Icons.play_arrow_rounded, color: EdenColors.primary, size: 22)));
        }),
      ]),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final Color? color;
  const _BarIcon({required this.icon, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    width: 44, height: 44, alignment: Alignment.center,
    child: Icon(icon, size: 22, color: color ?? EdenColors.primary)));
}

// ─── 상단 선택 바 ───
class _TopSelector extends StatelessWidget {
  final BibleDataService bible; final int bookId; final int chapter; final bool isDark; final bool cardMode;
  final VoidCallback onOpenGrid, onToggleMode, onPrev, onNext;
  const _TopSelector({required this.bible, required this.bookId, required this.chapter, required this.isDark, required this.cardMode, required this.onOpenGrid, required this.onToggleMode, required this.onPrev, required this.onNext});
  @override
  Widget build(BuildContext context) {
    final book = bible.books.isNotEmpty ? bible.books.firstWhere((b) => b.id == bookId, orElse: () => bible.books.first) : null;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
      GestureDetector(onTap: onOpenGrid, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), borderRadius: BorderRadius.circular(50)),
        child: Row(children: [
          Text(book?.nameKo ?? '창세기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: EdenColors.primary)),
          const SizedBox(width: 4), Text('$chapter장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: EdenColors.primary)),
          const SizedBox(width: 4), Icon(Icons.grid_view_rounded, size: 16, color: EdenColors.primary),
        ]))),
      const Spacer(),
      _CircleBtn(icon: Icons.chevron_left_rounded, isDark: isDark, onTap: onPrev),
      const SizedBox(width: 6), _CircleBtn(icon: Icons.chevron_right_rounded, isDark: isDark, onTap: onNext),
      const SizedBox(width: 8),
      GestureDetector(onTap: onToggleMode, child: Container(padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: cardMode ? EdenColors.primary.withValues(alpha: 0.15) : (isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8)), shape: BoxShape.circle),
        child: Icon(cardMode ? Icons.view_carousel_rounded : Icons.view_agenda_rounded, size: 20, color: EdenColors.primary))),
    ]));
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon; final bool isDark; final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    width: 44, height: 44, alignment: Alignment.center,
    decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), shape: BoxShape.circle),
    child: Icon(icon, size: 22, color: EdenColors.primary)));
}

// ─── 카드 스와이프 ───
class _CardSwipeView extends StatefulWidget {
  final List<BibleVerse> verses; final BibleBook? book; final int chapter; final String translation;
  final double fontSize; final bool isDark; final SettingsService settings; final VoidCallback onNext, onPrev; final int activeVerseIndex; final int bookId; final int wordStart; final int wordEnd;
  const _CardSwipeView({required this.verses, required this.book, required this.chapter, required this.translation,
    required this.fontSize, required this.isDark, required this.settings, required this.onNext, required this.onPrev, required this.activeVerseIndex, required this.bookId, required this.wordStart, required this.wordEnd});
  @override
  State<_CardSwipeView> createState() => _CardSwipeViewState();
}

class _CardSwipeViewState extends State<_CardSwipeView> {
  late PageController _pageController; int _currentPage = 0;
  @override
  void initState() { super.initState(); _pageController = PageController(); }
  @override
  void didUpdateWidget(covariant _CardSwipeView old) {
    super.didUpdateWidget(old);
    if (old.chapter != widget.chapter || old.book?.id != widget.book?.id) { _pageController.jumpToPage(0); _currentPage = 0; }
    if (widget.activeVerseIndex >= 0 && widget.activeVerseIndex != old.activeVerseIndex && widget.activeVerseIndex < widget.verses.length) {
      _pageController.animateToPage(widget.activeVerseIndex, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }
  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  TextSpan _buildCardHighlightedText(String text, int start, int end, TextStyle baseStyle, bool isDark) {
    final safeStart = start.clamp(0, text.length);
    final safeEnd = end.clamp(safeStart, text.length);
    return TextSpan(children: [
      if (safeStart > 0) TextSpan(text: text.substring(0, safeStart), style: baseStyle),
      TextSpan(text: text.substring(safeStart, safeEnd), style: baseStyle.copyWith(
        backgroundColor: isDark ? const Color(0xFF64B5F6).withValues(alpha: 0.35) : const Color(0xFF42A5F5).withValues(alpha: 0.3),
        color: isDark ? Colors.white : const Color(0xFF0D47A1), fontWeight: FontWeight.w700)),
      if (safeEnd < text.length) TextSpan(text: text.substring(safeEnd), style: baseStyle),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.verses.isEmpty) return const Center(child: CircularProgressIndicator());
    final thumbPath = getBookThumbnail(widget.bookId);
    return Stack(children: [
      // 배경 썸네일 (opacity 높여서 잘 보이게)
      Positioned.fill(child: Opacity(opacity: widget.isDark ? 0.25 : 0.18,
        child: Image.asset(thumbPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()))),
      // 배경 위 그라데이션 오버레이
      Positioned.fill(child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              (widget.isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight).withValues(alpha: 0.5),
              (widget.isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight).withValues(alpha: 0.85),
            ])))),
      // 본문 콘텐츠
      Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), child: Row(children: [
          Text('${_currentPage + 1} / ${widget.verses.length}절', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: EdenColors.secondary)),
          const Spacer(),
          if (widget.activeVerseIndex >= 0)
            Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: const Color(0xFF42A5F5), shape: BoxShape.circle)), const SizedBox(width: 4),
              Text('읽는 중', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF42A5F5)))])
          else Text('← 스와이프 →', style: TextStyle(fontSize: 12, color: EdenColors.textTertiaryLight)),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: ClipRRect(borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: (_currentPage + 1) / widget.verses.length, minHeight: 3,
            backgroundColor: widget.isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), valueColor: AlwaysStoppedAnimation(EdenColors.primary)))),
        const SizedBox(height: 8),
        Expanded(child: PageView.builder(
          controller: _pageController, itemCount: widget.verses.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (context, index) {
            final verse = widget.verses[index];
            String text;
            if (widget.translation == 'krv') {
              text = verse.krv.isNotEmpty ? verse.krv : '${verse.kjv}\n(한글 구절 준비 중)';
            } else {
              text = verse.kjv;
            }
            final isBookmarked = widget.settings.isBookmarked(verse.bookId, widget.chapter, verse.verse);
            final isActive = widget.activeVerseIndex == index;
            return Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 80), child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
                border: isActive ? Border.all(color: const Color(0xFF64B5F6), width: 2.5) : isBookmarked ? Border.all(color: EdenColors.accent.withValues(alpha: 0.4), width: 2) : Border.all(color: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.05))),
              child: ClipRRect(borderRadius: BorderRadius.circular(28),
              child: Stack(children: [
                // ── 카드 전체 배경: 썸네일 이미지 ──
                Positioned.fill(child: Image.asset(thumbPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: widget.isDark ? EdenColors.surfaceDark : Colors.white))),
                // ── 하단 그라데이션 오버레이 (텍스트 가독성) ──
                Positioned.fill(child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      stops: const [0.0, 0.35, 1.0],
                      colors: [
                        (widget.isDark ? const Color(0xFF1A1A2E) : Colors.white).withValues(alpha: 0.3),
                        (widget.isDark ? const Color(0xFF1A1A2E) : Colors.white).withValues(alpha: 0.75),
                        (widget.isDark ? const Color(0xFF1A1A2E) : Colors.white).withValues(alpha: 0.92),
                      ])))),
                // ── 카드 콘텐츠 ──
                Padding(padding: const EdgeInsets.all(28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: (isActive ? const Color(0xFF42A5F5) : EdenColors.primary).withValues(alpha: widget.isDark ? 0.3 : 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text('${verse.verse}절', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isActive ? const Color(0xFF1565C0) : EdenColors.primary))),
                    const SizedBox(width: 10), Text(verse.shortRef, style: TextStyle(fontSize: 14, color: widget.isDark ? Colors.white70 : EdenColors.textTertiaryLight, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    if (isActive) Icon(Icons.volume_up_rounded, size: 16, color: const Color(0xFF42A5F5)),
                    if (isBookmarked) ...[const SizedBox(width: 4), Icon(Icons.bookmark_rounded, size: 18, color: EdenColors.accent)],
                  ]),
                  const SizedBox(height: 24),
                  Expanded(child: Center(child: SingleChildScrollView(
                    child: RichText(textAlign: TextAlign.center, text: isActive && widget.wordEnd > widget.wordStart
                      ? _buildCardHighlightedText(
                          text, widget.wordStart, widget.wordEnd,
                          TextStyle(fontSize: widget.fontSize + 2, fontWeight: FontWeight.w500,
                            color: widget.isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight,
                            height: widget.settings.lineHeight, letterSpacing: 0.3),
                          widget.isDark)
                      : TextSpan(text: text, style: TextStyle(fontSize: widget.fontSize + 2,
                          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                          color: widget.isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight,
                          height: widget.settings.lineHeight, letterSpacing: 0.3)))))),
                  const SizedBox(height: 16),
                  Center(child: Text('${widget.book?.nameKo ?? ""} ${widget.chapter}장', style: TextStyle(fontSize: 13, color: widget.isDark ? Colors.white54 : EdenColors.textTertiaryLight, letterSpacing: 2))),
                ])),
              ]))));  // Stack, ClipRRect, Container, Padding
          })),
      ]),
    ]);
  }
}

// ─── 리스트 읽기 ───
class _ListReadView extends StatefulWidget {
  final List<BibleVerse> verses; final BibleBook? book; final int chapter; final String translation;
  final double fontSize; final bool isDark; final BibleDataService bible; final int bookId;
  final SettingsService settings; final VoidCallback onNext, onPrev;
  final int activeVerseIndex; final int selectedVerseIndex; final int wordStart; final int wordEnd;
  final void Function(int) onVerseTap;
  final void Function(ScaleStartDetails) onPinchStart; final void Function(ScaleUpdateDetails) onPinchUpdate;
  const _ListReadView({required this.verses, required this.book, required this.chapter, required this.translation,
    required this.fontSize, required this.isDark, required this.bible, required this.bookId,
    required this.settings, required this.onNext, required this.onPrev, required this.activeVerseIndex,
    required this.selectedVerseIndex, required this.wordStart, required this.wordEnd,
    required this.onVerseTap, required this.onPinchStart, required this.onPinchUpdate});
  @override
  State<_ListReadView> createState() => _ListReadViewState();
}

class _ListReadViewState extends State<_ListReadView> {
  final _scrollController = ScrollController();
  final _itemKeys = <int, GlobalKey>{};
  bool _isPinching = false;
  int _pointerCount = 0;

  @override
  void didUpdateWidget(covariant _ListReadView old) {
    super.didUpdateWidget(old);
    if (widget.activeVerseIndex >= 0 && widget.activeVerseIndex != old.activeVerseIndex) _scrollToVerse(widget.activeVerseIndex);
  }

  void _scrollToVerse(int index) {
    final key = _itemKeys[index];
    if (key?.currentContext != null) Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut, alignment: 0.3);
  }

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  /// TTS 진행 중 단어 하이라이트 RichText 생성 (하늘색 하이라이트)
  TextSpan _buildHighlightedText(String text, int start, int end, TextStyle baseStyle, bool isDark) {
    final safeStart = start.clamp(0, text.length);
    final safeEnd = end.clamp(safeStart, text.length);
    return TextSpan(children: [
      if (safeStart > 0)
        TextSpan(text: text.substring(0, safeStart), style: baseStyle),
      TextSpan(
        text: text.substring(safeStart, safeEnd),
        style: baseStyle.copyWith(
          backgroundColor: isDark ? const Color(0xFF64B5F6).withValues(alpha: 0.35) : const Color(0xFF42A5F5).withValues(alpha: 0.3),
          color: isDark ? Colors.white : const Color(0xFF0D47A1),
          fontWeight: FontWeight.w700,
        ),
      ),
      if (safeEnd < text.length)
        TextSpan(text: text.substring(safeEnd), style: baseStyle),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final lineH = widget.settings.lineHeight;
    return Listener(
      onPointerDown: (_) { _pointerCount++; if (_pointerCount >= 2) setState(() => _isPinching = true); },
      onPointerUp: (_) { _pointerCount--; if (_pointerCount < 2) { Future.delayed(const Duration(milliseconds: 100), () { if (mounted && _pointerCount < 2) setState(() => _isPinching = false); }); } },
      onPointerCancel: (_) { _pointerCount--; if (_pointerCount < 2) setState(() => _isPinching = false); },
      child: GestureDetector(
        onScaleStart: (d) { if (_pointerCount >= 2) widget.onPinchStart(d); },
        onScaleUpdate: (d) { if (_pointerCount >= 2) widget.onPinchUpdate(d); },
        onScaleEnd: (_) { if (_pointerCount < 2) setState(() => _isPinching = false); },
      child: widget.verses.isEmpty ? const Center(child: CircularProgressIndicator())
          : IgnorePointer(
              ignoring: _isPinching,
              child: ListView.builder(controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120), itemCount: widget.verses.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) return Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.book?.category ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EdenColors.secondary, letterSpacing: 3)),
                  const SizedBox(height: 8),
                  Text('${widget.book?.nameKo ?? ''} ${widget.chapter}장', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -1.5)),
                  const SizedBox(height: 12),
                  Container(width: 48, height: 2, color: EdenColors.primaryLight.withValues(alpha: 0.4)),
                ]));
                if (index == widget.verses.length + 1) return _ChapterNav(bible: widget.bible, bookId: widget.bookId, chapter: widget.chapter, isDark: widget.isDark, onPrev: widget.onPrev, onNext: widget.onNext);

                final vi = index - 1;
                final verse = widget.verses[vi];
                String text;
                if (widget.translation == 'krv') {
                  text = verse.krv.isNotEmpty ? verse.krv : '${verse.kjv} (한글 구절 준비 중)';
                } else {
                  text = verse.kjv;
                }
                final isBookmarked = widget.settings.isBookmarked(widget.bookId, widget.chapter, verse.verse);
                final isActive = widget.activeVerseIndex == vi;
                final isSelected = widget.selectedVerseIndex == vi;
                _itemKeys.putIfAbsent(vi, () => GlobalKey());

                return GestureDetector(key: _itemKeys[vi],
                  onTap: () => widget.onVerseTap(vi),
                  onLongPress: () { final was = isBookmarked; widget.settings.toggleBookmark(widget.bookId, widget.chapter, verse.verse);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(was ? '북마크를 해제했습니다' : '북마크에 저장했습니다'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
                  },
                  child: AnimatedContainer(duration: const Duration(milliseconds: 450), curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: EdgeInsets.fromLTRB(32, isActive || isSelected ? 12 : 8, 12, isActive || isSelected ? 12 : 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFFF8DC).withValues(alpha: widget.isDark ? 0.15 : 1.0)
                          : isSelected ? EdenColors.primary.withValues(alpha: widget.isDark ? 0.12 : 0.06) : Colors.transparent,
                      borderRadius: BorderRadius.circular(isActive || isSelected ? 14 : 0),
                      border: isActive ? Border.all(color: const Color(0xFF64B5F6).withValues(alpha: 0.4))
                          : isSelected ? Border.all(color: EdenColors.primary.withValues(alpha: 0.2)) : null),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(left: -28, top: isActive || isSelected ? 6 : 4, child: Text(verse.verse.toString(),
                        style: TextStyle(fontSize: isActive || isSelected ? 11 : 10, fontWeight: FontWeight.w700,
                          color: isActive ? const Color(0xFF1565C0) : isSelected ? EdenColors.primary : EdenColors.secondary.withValues(alpha: 0.5)))),
                      if (isBookmarked && !isActive && !isSelected)
                        Positioned(left: -32, top: 0, child: Container(width: 3, height: widget.fontSize * 1.5, decoration: BoxDecoration(color: EdenColors.accent, borderRadius: BorderRadius.circular(2)))),
                      if (isActive) Positioned(left: -32, top: 2, child: Icon(Icons.volume_up_rounded, size: 12, color: const Color(0xFF42A5F5))),
                      if (isSelected && !isActive) Positioned(left: -32, top: 2, child: Icon(Icons.check_circle, size: 12, color: EdenColors.primary)),
                      // 활성 절: 단어 단위 하이라이트 (항상 RichText로 위젯 트리 안정화)
                      isActive
                        ? RichText(text: widget.wordEnd > widget.wordStart
                            ? _buildHighlightedText(
                                text, widget.wordStart, widget.wordEnd,
                                TextStyle(fontSize: widget.fontSize + 1.5, fontWeight: FontWeight.w500,
                                  color: widget.isDark ? const Color(0xFFFFF3C4) : const Color(0xFF4A3F1B), height: lineH),
                                widget.isDark)
                            : TextSpan(text: text, style: TextStyle(fontSize: widget.fontSize + 1.5, fontWeight: FontWeight.w500,
                                color: widget.isDark ? const Color(0xFFFFF3C4) : const Color(0xFF4A3F1B), height: lineH)))
                        : Text(text, style: TextStyle(
                          fontSize: isSelected ? widget.fontSize + 0.5 : widget.fontSize,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected ? (widget.isDark ? EdenColors.textPrimaryDark : EdenColors.primary)
                              : (widget.isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight),
                          height: lineH)),
                    ])));
              }))),
    );
  }
}

// ─── 장 네비게이션 ───
class _ChapterNav extends StatelessWidget {
  final BibleDataService bible; final int bookId, chapter; final bool isDark; final VoidCallback onPrev, onNext;
  const _ChapterNav({required this.bible, required this.bookId, required this.chapter, required this.isDark, required this.onPrev, required this.onNext});
  @override
  Widget build(BuildContext context) {
    final maxCh = bible.getChapterCount(bookId); final book = bible.books.firstWhere((b) => b.id == bookId);
    final prev = chapter > 1 ? '${book.nameKo} ${chapter - 1}장' : (bookId > 1 ? bible.books[bookId - 2].nameKo : '');
    final next = chapter < maxCh ? '${book.nameKo} ${chapter + 1}장' : (bookId < 66 ? '${bible.books[bookId].nameKo} 1장' : '');
    return Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      if (prev.isNotEmpty) GestureDetector(onTap: onPrev, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('이전', style: TextStyle(fontSize: 12, color: EdenColors.secondary.withValues(alpha: 0.6), letterSpacing: 2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4), Text(prev, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: EdenColors.primary)),
      ])) else const SizedBox(),
      if (next.isNotEmpty) GestureDetector(onTap: onNext, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('다음', style: TextStyle(fontSize: 12, color: EdenColors.secondary.withValues(alpha: 0.6), letterSpacing: 2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4), Text(next, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: EdenColors.primary)),
      ])) else const SizedBox(),
    ]));
  }
}

class _Pill extends StatelessWidget {
  final String label; final bool isActive;
  const _Pill({required this.label, required this.isActive});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: isActive ? EdenColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(50)),
    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isActive ? Colors.white : EdenColors.textSecondaryLight)));
}
