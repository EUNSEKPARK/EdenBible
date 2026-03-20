import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../shared/widgets/share_verse_card.dart';
import 'visual_book_grid.dart';

class BibleView extends StatefulWidget {
  const BibleView({super.key});
  @override
  BibleViewState createState() => BibleViewState(); // public State
}

class BibleViewState extends State<BibleView> { // public
  final _bible = BibleDataService();
  final _settings = SettingsService();
  int _bookId = 1;
  int _chapter = 1;
  String _translation = 'krv';
  List<BibleVerse> _verses = [];
  double _pinchStartFontSize = 20.0;
  bool _cardMode = false;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    _bookId = _settings.lastReadBookId;
    _chapter = _settings.lastReadChapter;
    _translation = _settings.translation;
    _loadVerses();
  }

  void _onSettingsChanged() { if (mounted) setState(() => _translation = _settings.translation); }
  @override
  void dispose() { _settings.removeListener(_onSettingsChanged); super.dispose(); }
  void _loadVerses() { setState(() => _verses = _bible.getVerses(_bookId, _chapter)); }

  /// 외부에서 특정 책/장으로 이동 (홈 카드, 북마크 탭 등)
  void navigateTo(int bookId, int chapter) {
    _goToChapter(bookId, chapter);
  }

  void _goToChapter(int bookId, int chapter) {
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
      builder: (_) => VisualBookGrid(onSelect: (bookId, chapter) => _goToChapter(bookId, chapter)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final book = _bible.books.isNotEmpty ? _bible.books.firstWhere((b) => b.id == _bookId, orElse: () => _bible.books.first) : null;
    final fontSize = _settings.fontSize;

    return Stack(children: [
      Column(children: [
        _TopSelector(bible: _bible, bookId: _bookId, chapter: _chapter, isDark: isDark, cardMode: _cardMode,
          onOpenGrid: _openVisualBookGrid, onToggleMode: () => setState(() => _cardMode = !_cardMode),
          onPrev: _prevChapter, onNext: _nextChapter),
        Expanded(
          child: _cardMode
              ? _CardSwipeView(verses: _verses, book: book, chapter: _chapter, translation: _translation,
                  fontSize: fontSize, isDark: isDark, settings: _settings, onNext: _nextChapter, onPrev: _prevChapter)
              : _ListReadView(verses: _verses, book: book, chapter: _chapter, translation: _translation,
                  fontSize: fontSize, isDark: isDark, bible: _bible, bookId: _bookId,
                  settings: _settings, onNext: _nextChapter, onPrev: _prevChapter,
                  onPinchStart: (d) { if (d.pointerCount >= 2) _pinchStartFontSize = _settings.fontSize; },
                  onPinchUpdate: (d) { if (d.pointerCount >= 2) { _settings.setFontSize((_pinchStartFontSize * d.scale).clamp(14.0, 32.0)); } }),
        ),
      ]),
      Positioned(left: 20, right: 20, bottom: 16,
        child: _FloatingBar(translation: _translation, isDark: isDark, verses: _verses, onToggleTranslation: () {
          setState(() => _translation = _translation == 'krv' ? 'kjv' : 'krv'); _settings.setTranslation(_translation);
        })),
    ]);
  }
}

// ─── 상단 선택 바 ───
class _TopSelector extends StatelessWidget {
  final BibleDataService bible; final int bookId; final int chapter; final bool isDark; final bool cardMode;
  final VoidCallback onOpenGrid, onToggleMode, onPrev, onNext;
  const _TopSelector({required this.bible, required this.bookId, required this.chapter, required this.isDark, required this.cardMode, required this.onOpenGrid, required this.onToggleMode, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final book = bible.books.isNotEmpty ? bible.books.firstWhere((b) => b.id == bookId, orElse: () => bible.books.first) : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        GestureDetector(onTap: onOpenGrid, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), borderRadius: BorderRadius.circular(50)),
          child: Row(children: [
            Text(book?.nameKo ?? '창세기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: EdenColors.primary)),
            const SizedBox(width: 4),
            Text('$chapter장', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: EdenColors.primary)),
            const SizedBox(width: 4),
            Icon(Icons.grid_view_rounded, size: 16, color: EdenColors.primary),
          ]),
        )),
        const Spacer(),
        _CircleBtn(icon: Icons.chevron_left_rounded, isDark: isDark, onTap: onPrev),
        const SizedBox(width: 6),
        _CircleBtn(icon: Icons.chevron_right_rounded, isDark: isDark, onTap: onNext),
        const SizedBox(width: 8),
        GestureDetector(onTap: onToggleMode, child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: cardMode ? EdenColors.primary.withValues(alpha: 0.15) : (isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8)), shape: BoxShape.circle),
          child: Icon(cardMode ? Icons.view_carousel_rounded : Icons.view_agenda_rounded, size: 20, color: EdenColors.primary),
        )),
      ]),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon; final bool isDark; final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), shape: BoxShape.circle),
    child: Icon(icon, size: 20, color: EdenColors.primary)));
}

// ─── 카드 스와이프 읽기 ───
class _CardSwipeView extends StatefulWidget {
  final List<BibleVerse> verses; final BibleBook? book; final int chapter; final String translation;
  final double fontSize; final bool isDark; final SettingsService settings; final VoidCallback onNext, onPrev;
  const _CardSwipeView({required this.verses, required this.book, required this.chapter, required this.translation, required this.fontSize, required this.isDark, required this.settings, required this.onNext, required this.onPrev});
  @override
  State<_CardSwipeView> createState() => _CardSwipeViewState();
}

class _CardSwipeViewState extends State<_CardSwipeView> {
  late PageController _pageController;
  int _currentPage = 0;
  @override
  void initState() { super.initState(); _pageController = PageController(); }
  @override
  void didUpdateWidget(covariant _CardSwipeView old) {
    super.didUpdateWidget(old);
    if (old.chapter != widget.chapter || old.book?.id != widget.book?.id) { _pageController.jumpToPage(0); _currentPage = 0; }
  }
  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.verses.isEmpty) return const Center(child: CircularProgressIndicator());
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), child: Row(children: [
        Text('${_currentPage + 1} / ${widget.verses.length}절', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: EdenColors.secondary)),
        const Spacer(),
        Text('← 스와이프 →', style: TextStyle(fontSize: 10, color: EdenColors.textTertiaryLight)),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(value: (_currentPage + 1) / widget.verses.length, minHeight: 3,
          backgroundColor: widget.isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), valueColor: AlwaysStoppedAnimation(EdenColors.primary)),
      )),
      const SizedBox(height: 8),
      Expanded(child: PageView.builder(
        controller: _pageController, itemCount: widget.verses.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, index) {
          final verse = widget.verses[index];
          final text = widget.translation == 'krv' ? verse.krv : verse.kjv;
          final isBookmarked = widget.settings.isBookmarked(verse.bookId, widget.chapter, verse.verse);
          return Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 80), child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: widget.isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
              border: isBookmarked ? Border.all(color: EdenColors.accent.withValues(alpha: 0.4), width: 2) : Border.all(color: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.05))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: EdenColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text('${verse.verse}절', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: EdenColors.primary))),
                const SizedBox(width: 10),
                Text(verse.shortRef, style: TextStyle(fontSize: 12, color: EdenColors.textTertiaryLight, fontWeight: FontWeight.w500)),
                const Spacer(),
                if (isBookmarked) Icon(Icons.bookmark_rounded, size: 18, color: EdenColors.accent),
              ]),
              const SizedBox(height: 24),
              Expanded(child: Center(child: SingleChildScrollView(child: Text(text,
                style: TextStyle(fontSize: widget.fontSize + 2, fontWeight: FontWeight.w400, color: widget.isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight, height: 2.0, letterSpacing: 0.3),
                textAlign: TextAlign.center)))),
              const SizedBox(height: 16),
              Center(child: Text('${widget.book?.nameKo ?? ""} ${widget.chapter}장', style: TextStyle(fontSize: 11, color: EdenColors.textTertiaryLight, letterSpacing: 2))),
            ]),
          ));
        },
      )),
    ]);
  }
}

// ─── 리스트 읽기 ───
class _ListReadView extends StatelessWidget {
  final List<BibleVerse> verses; final BibleBook? book; final int chapter; final String translation;
  final double fontSize; final bool isDark; final BibleDataService bible; final int bookId;
  final SettingsService settings; final VoidCallback onNext, onPrev;
  final void Function(ScaleStartDetails) onPinchStart; final void Function(ScaleUpdateDetails) onPinchUpdate;
  const _ListReadView({required this.verses, required this.book, required this.chapter, required this.translation,
    required this.fontSize, required this.isDark, required this.bible, required this.bookId,
    required this.settings, required this.onNext, required this.onPrev, required this.onPinchStart, required this.onPinchUpdate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onScaleStart: onPinchStart, onScaleUpdate: onPinchUpdate,
      child: verses.isEmpty ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120), itemCount: verses.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) return Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(book?.category ?? '', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EdenColors.secondary, letterSpacing: 3)),
                  const SizedBox(height: 8),
                  Text('${book?.nameKo ?? ''} $chapter장', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.5)),
                  const SizedBox(height: 12),
                  Container(width: 48, height: 2, color: EdenColors.primaryLight.withValues(alpha: 0.4)),
                ]));
                if (index == verses.length + 1) return _ChapterNav(bible: bible, bookId: bookId, chapter: chapter, isDark: isDark, onPrev: onPrev, onNext: onNext);
                final verse = verses[index - 1];
                final text = translation == 'krv' ? verse.krv : verse.kjv;
                final isBookmarked = settings.isBookmarked(bookId, chapter, verse.verse);
                return GestureDetector(
                  onLongPress: () {
                    final was = isBookmarked; settings.toggleBookmark(bookId, chapter, verse.verse);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(was ? '북마크를 해제했습니다' : '북마크에 저장했습니다'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
                  },
                  child: Padding(padding: const EdgeInsets.only(bottom: 20, left: 32), child: Stack(clipBehavior: Clip.none, children: [
                    Positioned(left: -28, top: 4, child: Text(verse.verse.toString(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: EdenColors.secondary.withValues(alpha: 0.5)))),
                    if (isBookmarked) Positioned(left: -32, top: 0, child: Container(width: 3, height: fontSize * 1.5, decoration: BoxDecoration(color: EdenColors.accent, borderRadius: BorderRadius.circular(2)))),
                    Text(text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight, height: 1.8)),
                  ])),
                );
              }));
  }
}

// ─── 장 네비게이션 ───
class _ChapterNav extends StatelessWidget {
  final BibleDataService bible; final int bookId, chapter; final bool isDark; final VoidCallback onPrev, onNext;
  const _ChapterNav({required this.bible, required this.bookId, required this.chapter, required this.isDark, required this.onPrev, required this.onNext});
  @override
  Widget build(BuildContext context) {
    final maxCh = bible.getChapterCount(bookId);
    final book = bible.books.firstWhere((b) => b.id == bookId);
    final prev = chapter > 1 ? '${book.nameKo} ${chapter - 1}장' : (bookId > 1 ? bible.books[bookId - 2].nameKo : '');
    final next = chapter < maxCh ? '${book.nameKo} ${chapter + 1}장' : (bookId < 66 ? '${bible.books[bookId].nameKo} 1장' : '');
    return Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      if (prev.isNotEmpty) GestureDetector(onTap: onPrev, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('이전', style: TextStyle(fontSize: 10, color: EdenColors.secondary.withValues(alpha: 0.6), letterSpacing: 2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4), Text(prev, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: EdenColors.primary)),
      ])) else const SizedBox(),
      if (next.isNotEmpty) GestureDetector(onTap: onNext, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('다음', style: TextStyle(fontSize: 10, color: EdenColors.secondary.withValues(alpha: 0.6), letterSpacing: 2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4), Text(next, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: EdenColors.primary)),
      ])) else const SizedBox(),
    ]));
  }
}

// ─── 하단 플로팅 바 (배속 버튼 추가) ───
class _FloatingBar extends StatelessWidget {
  final String translation; final bool isDark; final VoidCallback onToggleTranslation; final List<BibleVerse> verses;
  const _FloatingBar({required this.translation, required this.isDark, required this.onToggleTranslation, required this.verses});
  @override
  Widget build(BuildContext context) {
    final tts = TtsService();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08))),
      child: Row(children: [
        // 번역 토글
        GestureDetector(onTap: onToggleTranslation, child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(50)),
          child: Row(children: [_Pill(label: '개역한글', isActive: translation == 'krv'), _Pill(label: 'KJV', isActive: translation == 'kjv')]),
        )),
        const Spacer(),
        // 공유
        GestureDetector(onTap: () { if (verses.isNotEmpty) showShareCardSheet(context, verseText: verses.first.krv, verseRef: verses.first.refKo); },
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.share_outlined, size: 20, color: EdenColors.textSecondaryLight))),
        // 배속 버튼
        ListenableBuilder(listenable: tts, builder: (_, __) {
          return GestureDetector(
            onTap: () => tts.cycleSpeed(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(color: EdenColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(tts.speedLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: EdenColors.primary)),
            ),
          );
        }),
        // 재생/정지
        ListenableBuilder(listenable: tts, builder: (_, __) {
          final playing = tts.isPlaying;
          return GestureDetector(onTap: () {
            if (playing) { tts.stop(); return; }
            final texts = verses.map((v) => translation == 'krv' ? v.krv : v.kjv).toList();
            if (texts.isEmpty) return;
            translation == 'kjv' ? tts.setEnglish() : tts.setKorean(); tts.speakVerses(texts);
          }, child: Container(width: 36, height: 36, margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(color: playing ? EdenColors.primary.withValues(alpha: 0.2) : EdenColors.primaryLight.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(playing ? Icons.stop_rounded : Icons.play_arrow_rounded, color: EdenColors.primary, size: 20)));
        }),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label; final bool isActive;
  const _Pill({required this.label, required this.isActive});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: isActive ? EdenColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(50)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isActive ? Colors.white : EdenColors.textSecondaryLight)));
}
