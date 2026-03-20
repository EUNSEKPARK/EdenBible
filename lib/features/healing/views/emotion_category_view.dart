import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/services/emotion_match_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/models/emotion_models.dart';
import 'situation_view.dart';

/// 1단계: 감정 대분류 선택 — 10개 이모지 카드 그리드
class EmotionCategoryView extends StatelessWidget {
  const EmotionCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = EmotionMatchService();
    final settings = SettingsService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = service.categories;

    final topIds = settings.topEmotions;
    final topCategories = topIds
        .map((id) => categories.where((c) => c.id == id).firstOrNull)
        .where((c) => c != null)
        .toList();

    // 카드 리스트를 Column으로 직접 구성 (GridView 대신)
    final List<Widget> cardRows = [];
    for (int i = 0; i < categories.length; i += 2) {
      final cat1 = categories[i];
      final cat2 = i + 1 < categories.length ? categories[i + 1] : null;
      cardRows.add(Padding(
        padding: EdgeInsets.only(bottom: i + 2 < categories.length ? 14 : 0),
        child: Row(children: [
          Expanded(child: _EmotionCard(category: cat1, isDark: isDark, onTap: () {
            settings.recordEmotionTap(cat1.id);
            Navigator.push(context, MaterialPageRoute(builder: (_) => SituationView(category: cat1)));
          })),
          const SizedBox(width: 14),
          if (cat2 != null)
            Expanded(child: _EmotionCard(category: cat2, isDark: isDark, onTap: () {
              settings.recordEmotionTap(cat2.id);
              Navigator.push(context, MaterialPageRoute(builder: (_) => SituationView(category: cat2)));
            }))
          else
            const Expanded(child: SizedBox()),
        ]),
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Text('지금 마음이\n어떠세요?',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
            color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight,
            height: 1.4, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('감정을 선택하면 당신을 위한 말씀을 준비해 드릴게요',
          style: TextStyle(fontSize: 14, color: EdenColors.textTertiaryLight, height: 1.5)),

        // 자주 찾는 위로
        if (topCategories.length >= 2) ...[
          const SizedBox(height: 24),
          Row(children: [
            Icon(Icons.history_rounded, size: 14, color: EdenColors.accent),
            const SizedBox(width: 6),
            Text('자주 찾는 위로', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EdenColors.accent, letterSpacing: 2)),
          ]),
          const SizedBox(height: 10),
          Row(children: topCategories.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value!;
            return Expanded(child: GestureDetector(
              onTap: () {
                settings.recordEmotionTap(cat.id);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SituationView(category: cat)));
              },
              child: Container(
                margin: EdgeInsets.only(right: i < topCategories.length - 1 ? 10 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: EdenColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EdenColors.accent.withValues(alpha: 0.15)),
                ),
                child: Column(children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(cat.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight),
                    overflow: TextOverflow.ellipsis),
                ]),
              ),
            ));
          }).toList()),
        ],

        const SizedBox(height: 28),

        // 감정 카드 2열 (GridView 대신 Row로 직접 구성)
        ...cardRows,
      ],
    );
  }
}

class _EmotionCard extends StatelessWidget {
  final EmotionCategory category;
  final bool isDark;
  final VoidCallback onTap;
  const _EmotionCard({required this.category, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? cardColor.withValues(alpha: 0.15) : cardColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardColor.withValues(alpha: isDark ? 0.3 : 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 10),
            Text(category.label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight),
              overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${category.situations.length}개 상황',
              style: TextStyle(fontSize: 11, color: cardColor.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}
