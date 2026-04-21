import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';
import 'chapter_card_view.dart';

/// 66권 book_id → 썸네일 이미지 경로 매핑
String getBookThumbnail(int bookId) {
  const map = {
    1: '01_genesis', 2: '02_exodus', 3: '03_Leviticus', 4: '04_numbers',
    5: '05_deuteronomy', 6: '06_joshua', 7: '07_judges', 8: '08_ruth',
    9: '09_1samuel', 10: '10_2samuel', 11: '11_1kings', 12: '12_2kings',
    13: '13_Chronicles', 14: '14_2chronicles', 15: '15_ezra', 16: '16_nehemiah',
    17: '17_esther', 18: '18_job', 19: '19_psalms', 20: '20_proverbs',
    21: '21_ecclesiastes', 22: '22_song_of_solomon', 23: '23_isaiah', 24: '24_jeremiah',
    25: '25_lamentations', 26: '26_ezekiel', 27: '27_daniel', 28: '28_hosea',
    29: '29_joel', 30: '30_amos', 31: '31_obadiah', 32: '32_jonah',
    33: '33_micah', 34: '34_nahum', 35: '35_habakkuk', 36: '36_zephaniah',
    37: '37_haggai', 38: '38_zechariah', 39: '39_malachi', 40: '40_matthew',
    41: '41_mark', 42: '42_luke', 43: '43_john', 44: '44_acts',
    45: '45_romans', 46: '46_1corinthians', 47: '47_2corinthians', 48: '48_galatians',
    49: '49_ephesians', 50: '50_philippians', 51: '51_colossians', 52: '52_1thessalonians',
    53: '53_2thessalonians', 54: '54_1timothy', 55: '55_2timothy', 56: '56_titus',
    57: '57_philemon', 58: '58_hebrews', 59: '59_james', 60: '60_1peter',
    61: '61_2peter', 62: '62_1john', 63: '63_2john', 64: '64_3john',
    65: '65_jude', 66: '66_revelation',
  };
  return 'assets/images/books/${map[bookId] ?? '01_genesis'}.jpg';
}

/// P1-02: 비주얼 책 선택기 — 66권 Midjourney 썸네일 그리드
class VisualBookGrid extends StatefulWidget {
  final void Function(int bookId, int chapter) onSelect;
  const VisualBookGrid({super.key, required this.onSelect});
  @override
  State<VisualBookGrid> createState() => _VisualBookGridState();
}

class _VisualBookGridState extends State<VisualBookGrid> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bible = BibleDataService();

  @override
  void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('성경 선택'), centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EdenColors.primary, indicatorWeight: 2.5,
          labelColor: EdenColors.primary, unselectedLabelColor: EdenColors.textTertiaryLight,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          tabs: [Tab(text: '구약 (${_bible.oldTestamentBooks.length}권)'), Tab(text: '신약 (${_bible.newTestamentBooks.length}권)')],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        _BookGrid(books: _bible.oldTestamentBooks, isDark: isDark, onSelect: widget.onSelect),
        _BookGrid(books: _bible.newTestamentBooks, isDark: isDark, onSelect: widget.onSelect),
      ]),
    );
  }
}

class _BookGrid extends StatelessWidget {
  final List<BibleBook> books; final bool isDark;
  final void Function(int bookId, int chapter) onSelect;
  const _BookGrid({required this.books, required this.isDark, required this.onSelect});

  static const _categoryColors = {
    '모세오경': Color(0xFF7B6B4A), '역사서': Color(0xFF5B7553), '시가서': Color(0xFFC9A96E),
    '대선지서': Color(0xFF6B8FA1), '소선지서': Color(0xFF8B7B6B), '복음서': Color(0xFF5B7553),
    '역사': Color(0xFF6B8FA1), '바울서신': Color(0xFF7B6B8B), '일반서신': Color(0xFF5B8B7B),
    '예언서': Color(0xFFA67B5B),
  };

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<BibleBook>>{};
    for (final book in books) { grouped.putIfAbsent(book.category, () => []).add(book); }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final category = grouped.keys.elementAt(index);
        final categoryBooks = grouped[category]!;
        final color = _categoryColors[category] ?? EdenColors.primary;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (index > 0) const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Row(children: [
            Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(category, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color, letterSpacing: 2)),
            const SizedBox(width: 8),
            Text('${categoryBooks.length}권', style: TextStyle(fontSize: 13, color: EdenColors.textTertiaryLight)),
          ])),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.72),
            itemCount: categoryBooks.length,
            itemBuilder: (_, i) => _BookCard(
              book: categoryBooks[i], color: color, isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterCardView(
                book: categoryBooks[i], color: color,
                onSelect: (chapter) { Navigator.pop(context); Navigator.pop(context); onSelect(categoryBooks[i].id, chapter); },
              ))),
            ),
          ),
        ]);
      },
    );
  }
}

/// 썸네일 적용된 책 카드
class _BookCard extends StatelessWidget {
  final BibleBook book; final Color color; final bool isDark; final VoidCallback onTap;
  const _BookCard({required this.book, required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumbPath = getBookThumbnail(book.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 썸네일 이미지
            Image.asset(thumbPath, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: color.withValues(alpha: 0.15))),
            // 하단 그라디언트 오버레이
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  stops: const [0.3, 1.0],
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                ),
              ),
            ),
            // 상단 약어 뱃지
            Positioned(
              top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(6)),
                child: Text(book.abbrKo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
            // 하단 텍스트
            Positioned(
              bottom: 10, left: 10, right: 10,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(book.nameKo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${book.chapterCount}장', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
