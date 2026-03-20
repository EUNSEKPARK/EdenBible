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

    // 자주 찾는 위로 (패턴 학습)
    final topIds = settings.topEmotions;
    final topCategories = topIds.map((id) => categories.where((c) => c.id == id).firstOrNull).where((c) => c != null).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('지금 마음이\n어떠세요?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight, height: 1.4, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('감정을 선택하면 당신을 위한 말씀을 준비해 드릴게요', style: TextStyle(fontSize: 14, color: EdenColors.textTertiaryLight, height: 1.5)),

          // ─── 자주 찾는 위로 (사용 이력 3개 이상일 때 표시) ───
          if (topCategories.length >= 2) ...[
            const SizedBox(height: 24),
            Row(children: [
              Icon(Icons.history_rounded, size: 14, color: EdenColors.accent),
              const SizedBox(width: 6),
              Text('자주 찾는 위로', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EdenColors.accent, letterSpacing: 2)),
            ]),
            const SizedBox(height: 10),
            Row(children: topCategories.map((cat) => Expanded(
              child: GestureDetector(
                onTap: () {
                  settings.recordEmotionTap(cat!.id);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SituationView(category: cat)));
                },
                child: Container(
                  margin: const EdgeInsets.only(right: topCategories.last == cat ? 0 : 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: EdenColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: EdenColors.accent.withValues(alpha: 0.15)),
                  ),
                  child: Column(children: [
                    Text(cat!.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(cat.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
                  ]),
                ),
              ),
            )).toList()),
          ],

          const SizedBox(height: 28),

          // ─── 전체 감정 카드 그리드 (2열) ───
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.7),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _EmotionCard(category: cat, isDark: isDark, onTap: () {
                settings.recordEmotionTap(cat.id);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SituationView(category: cat)));
              });
            },
          ),
        ],
      ),
    );
  }
}

class _EmotionCard extends StatelessWidget {
  final EmotionCategory category; final bool isDark; final VoidCallback onTap;
  const _EmotionCard({required this.category, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cardColor.withValues(alpha: 0.15) : cardColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withValues(alpha: isDark ? 0.3 : 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(category.emoji, style: const TextStyle(fontSize: 28)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
          const SizedBox(height: 2),
          Text('${category.situations.length}개 상황', style: TextStyle(fontSize: 11, color: cardColor.withValues(alpha: 0.8))),
        ]),
      ]),
    ));
  }
}
