import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';
import 'visual_book_grid.dart' show getBookThumbnail;

/// P1-03: 장 카드 선택기 — 책 썸네일 헤더 + 첫 절 미리보기
class ChapterCardView extends StatelessWidget {
  final BibleBook book;
  final Color color;
  final void Function(int chapter) onSelect;

  const ChapterCardView({super.key, required this.book, required this.color, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bible = BibleDataService();
    final thumbPath = getBookThumbnail(book.id);

    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ─── 썸네일 헤더 (SliverAppBar) ───
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(book.nameKo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(thumbPath, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: color.withValues(alpha: 0.3))),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        stops: const [0.2, 1.0],
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                  // 책 정보 오버레이
                  Positioned(
                    bottom: 56, left: 20, right: 20,
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text(book.abbrKo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      Text('${book.chapterCount}장 • ${book.testament == "old" ? "구약" : "신약"} • ${book.category}',
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // ─── 장 리스트 ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chapter = index + 1;
                  final firstVerse = bible.getVerse(book.id, chapter, 1);
                  final preview = (firstVerse?.krv.isNotEmpty == true)
                      ? firstVerse!.krv
                      : (firstVerse?.kjv.isNotEmpty == true
                          ? '${firstVerse!.kjv} (한글 구절 준비 중)'
                          : '');
                  final verseCount = bible.getVerseCount(book.id, chapter);

                  return GestureDetector(
                    onTap: () => onSelect(chapter),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? EdenColors.surfaceVariantDark : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // 장 번호
                        Container(
                          width: 44, height: 44, alignment: Alignment.center,
                          decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(14)),
                          child: Text('$chapter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text('$chapter장', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
                            const Spacer(),
                            Text('$verseCount절', style: TextStyle(fontSize: 13, color: EdenColors.textTertiaryLight)),
                          ]),
                          if (preview.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(preview, style: TextStyle(fontSize: 15, color: (isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight).withValues(alpha: 0.6), height: 1.5),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ])),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: EdenColors.textTertiaryLight),
                      ]),
                    ),
                  );
                },
                childCount: book.chapterCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
