import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/emotion_models.dart';
import 'healing_package_view.dart';

/// 2단계: 세부 상황 선택 — 카테고리 내 3~5개 상황 리스트
class SituationView extends StatelessWidget {
  final EmotionCategory category;

  const SituationView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(category.label),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 문구
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: isDark ? 0.15 : 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '조금 더 알려주세요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '어떤 상황인지 선택하면\n당신에게 딱 맞는 말씀을 찾아드릴게요',
                    style: TextStyle(fontSize: 14, color: EdenColors.textTertiaryLight, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 상황 리스트
            ...category.situations.map((situation) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SituationTile(
                situation: situation,
                categoryId: category.id,
                cardColor: cardColor,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealingPackageView(
                      situation: situation,
                      categoryId: category.id,
                      categoryEmoji: category.emoji,
                      categoryLabel: category.label,
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _SituationTile extends StatelessWidget {
  final Situation situation;
  final String categoryId;
  final Color cardColor;
  final bool isDark;
  final VoidCallback onTap;

  const _SituationTile({
    required this.situation,
    required this.categoryId,
    required this.cardColor,
    required this.isDark,
    required this.onTap,
  });

  IconData _getIcon(String iconName) {
    const map = {
      'hourglass_empty': Icons.hourglass_empty_rounded,
      'account_balance_wallet': Icons.account_balance_wallet_outlined,
      'health_and_safety': Icons.health_and_safety_outlined,
      'school': Icons.school_outlined,
      'favorite_border': Icons.favorite_border_rounded,
      'person_outline': Icons.person_outline_rounded,
      'trending_down': Icons.trending_down_rounded,
      'cloud': Icons.cloud_outlined,
      'family_restroom': Icons.family_restroom_outlined,
      'people_outline': Icons.people_outline_rounded,
      'handshake': Icons.handshake_outlined,
      'heart_broken': Icons.heart_broken_outlined,
      'wb_sunny': Icons.wb_sunny_outlined,
      'celebration': Icons.celebration_outlined,
      'diamond': Icons.diamond_outlined,
      'gavel': Icons.gavel_rounded,
      'flash_on': Icons.flash_on_outlined,
      'person_off': Icons.person_off_outlined,
      'battery_alert': Icons.battery_alert_outlined,
      'water_drop': Icons.water_drop_outlined,
      'work_outline': Icons.work_outline_rounded,
      'psychology': Icons.psychology_outlined,
      'lightbulb': Icons.lightbulb_outline_rounded,
      'nights_stay': Icons.nights_stay_outlined,
      'emoji_events': Icons.emoji_events_outlined,
      'music_note': Icons.music_note_outlined,
      'record_voice_over': Icons.record_voice_over_outlined,
      'explore': Icons.explore_outlined,
      'question_mark': Icons.question_mark_rounded,
      'flag': Icons.flag_outlined,
      'alt_route': Icons.alt_route_rounded,
      'campaign': Icons.campaign_outlined,
    };
    return map[iconName] ?? Icons.circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? EdenColors.surfaceVariantDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getIcon(situation.icon), size: 22, color: cardColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                situation.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: EdenColors.textTertiaryLight),
          ],
        ),
      ),
    );
  }
}
