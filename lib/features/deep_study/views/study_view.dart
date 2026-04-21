import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';

class StudyView extends StatefulWidget {
  const StudyView({super.key});
  @override
  State<StudyView> createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView> {
  final _bible = BibleDataService();
  int _bookId = 1;
  int _chapter = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final book = _bible.books.isNotEmpty
        ? _bible.books.firstWhere((b) => b.id == _bookId, orElse: () => _bible.books.first)
        : null;
    final verses = _bible.getVerses(_bookId, _chapter);
    final displayVerses = verses.take(15).toList();

    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      appBar: AppBar(title: const Text('성경 연구'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('심층 연구 모드', style: TextStyle(fontSize: 13, color: EdenColors.secondary, letterSpacing: 3, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            // 책/장 선택
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showBookPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Text(book?.nameKo ?? '창세기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: EdenColors.primary)),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more, size: 20, color: EdenColors.primary),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showChapterPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Text('$_chapter장', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: EdenColors.primary)),
                    const SizedBox(width: 4),
                    Icon(Icons.expand_more, size: 20, color: EdenColors.primary),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            Row(children: [
              _TranslationChip(label: '주 번역:', value: '개역한글', isDark: isDark),
              const SizedBox(width: 8),
              _TranslationChip(label: '대조 번역:', value: 'KJV', isDark: isDark),
            ]),
            const SizedBox(height: 24),

            // 대조 보기
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
              child: Column(children: [
                // 개역한글
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('개역한글', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: EdenColors.secondary.withValues(alpha: 0.6), letterSpacing: 2)),
                    const SizedBox(height: 16),
                    if (displayVerses.isEmpty)
                      Text('구절을 불러올 수 없습니다.', style: TextStyle(fontSize: 16, color: EdenColors.textTertiaryLight))
                    else
                      ...displayVerses.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RichText(text: TextSpan(
                          style: TextStyle(fontSize: 19, height: 1.8, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight),
                          children: [
                            TextSpan(text: '${v.verse} ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EdenColors.secondary)),
                            TextSpan(text: v.krv),
                          ],
                        )),
                      )),
                  ]),
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                // KJV
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('KJV', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: EdenColors.secondary.withValues(alpha: 0.6), letterSpacing: 2)),
                      Icon(Icons.compare_arrows, size: 18, color: EdenColors.secondary.withValues(alpha: 0.4)),
                    ]),
                    const SizedBox(height: 16),
                    if (displayVerses.isEmpty)
                      Text('No verses loaded.', style: TextStyle(fontSize: 16, color: EdenColors.textTertiaryLight))
                    else
                      ...displayVerses.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RichText(text: TextSpan(
                          style: TextStyle(fontSize: 19, height: 1.8, color: (isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight).withValues(alpha: 0.7), fontStyle: FontStyle.italic),
                          children: [
                            TextSpan(text: '${v.verse} ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EdenColors.secondary.withValues(alpha: 0.5), fontStyle: FontStyle.normal)),
                            TextSpan(text: v.kjv),
                          ],
                        )),
                      )),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 32),

            // 주석 영역
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFEAE8E2), borderRadius: BorderRadius.circular(32)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: EdenColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.auto_stories, size: 22, color: EdenColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text('주석 및 통찰', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFFD9E7CB).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: EdenColors.primary.withValues(alpha: 0.1))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.auto_awesome, size: 14, color: EdenColors.primary),
                      const SizedBox(width: 6),
                      Text('AI 강해', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: EdenColors.primaryDark, letterSpacing: 2)),
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      '${book?.nameKo ?? ""} $_chapter장의 대조 보기입니다. 개역한글과 KJV를 비교하며 원문의 뉘앙스를 살펴보세요. 향후 업데이트에서 원어 해석, 교차 참조, AI 강해가 추가될 예정입니다.',
                      style: TextStyle(fontSize: 16, height: 1.7, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight),
                    ),
                  ]),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookPicker(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.6, maxChildSize: 0.9,
        builder: (_, sc) => Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('성경 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Expanded(child: ListView.builder(
            controller: sc, itemCount: _bible.books.length,
            itemBuilder: (_, i) {
              final b = _bible.books[i];
              final sel = b.id == _bookId;
              return ListTile(
                leading: Text('${b.id}', style: TextStyle(fontSize: 14, color: EdenColors.secondary)),
                title: Text(b.nameKo, style: TextStyle(fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? EdenColors.primary : null)),
                subtitle: Text('${b.nameEn} • ${b.chapterCount}장', style: const TextStyle(fontSize: 14)),
                trailing: sel ? Icon(Icons.check_circle, color: EdenColors.primary, size: 20) : null,
                onTap: () { Navigator.pop(ctx); setState(() { _bookId = b.id; _chapter = 1; }); },
              );
            },
          )),
        ]),
      ),
    );
  }

  void _showChapterPicker(BuildContext context) {
    final count = _bible.getChapterCount(_bookId);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20), height: 400,
        child: Column(children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('장 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Expanded(child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemCount: count,
            itemBuilder: (_, i) {
              final ch = i + 1;
              final sel = ch == _chapter;
              return GestureDetector(
                onTap: () { Navigator.pop(ctx); setState(() => _chapter = ch); },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: sel ? EdenColors.primary : EdenColors.surfaceVariantLight, borderRadius: BorderRadius.circular(12)),
                  child: Text('$ch', style: TextStyle(fontWeight: FontWeight.w600, color: sel ? Colors.white : EdenColors.textPrimaryLight)),
                ),
              );
            },
          )),
        ]),
      ),
    );
  }
}

class _TranslationChip extends StatelessWidget {
  final String label; final String value; final bool isDark;
  const _TranslationChip({required this.label, required this.value, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8), borderRadius: BorderRadius.circular(50)),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 14, color: EdenColors.textSecondaryLight)),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: EdenColors.primary)),
      ]),
    );
  }
}
