import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/emotion_models.dart';
import '../../../core/services/emotion_match_service.dart';
import '../../../core/services/youtube_curation_service.dart';
import '../../../shared/widgets/youtube_card.dart';

/// 3단계: 힐링 패키지 — AI 위로 + 말씀 + 유튜브 + 기도 한 화면
class HealingPackageView extends StatefulWidget {
  final Situation situation;
  final String categoryId;
  final String categoryEmoji;
  final String categoryLabel;

  const HealingPackageView({
    super.key,
    required this.situation,
    required this.categoryId,
    required this.categoryEmoji,
    required this.categoryLabel,
  });

  @override
  State<HealingPackageView> createState() => _HealingPackageViewState();
}

class _HealingPackageViewState extends State<HealingPackageView> {
  late HealingResponse _response;
  final _service = EmotionMatchService();
  final _ytService = YoutubeCurationService();

  @override
  void initState() {
    super.initState();
    _response = widget.situation.response;
  }

  void _loadAlternative() {
    final alt = _service.getAlternative(widget.categoryId, widget.situation.id);
    if (alt != null) {
      setState(() => _response = alt);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다른 말씀을 준비했어요'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)),
      );
    }
  }

  /// 유튜브 영상 목록 — placeholder면 카테고리별 실제 영상으로 대체
  List<YouTubeCurated> get _youtubeVideos {
    final original = _response.youtubeCurated;
    // placeholder ID가 있으면 실제 영상으로 교체
    final hasPlaceholder = original.isEmpty || original.any((v) => v.videoId.startsWith('placeholder'));
    if (hasPlaceholder) {
      return _ytService.getByCategory(widget.categoryId);
    }
    return original;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('${widget.categoryEmoji} ${widget.situation.label}', style: const TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ComfortCard(message: _response.aiMessage, isDark: isDark),
            const SizedBox(height: 24),

            _SectionLabel(icon: Icons.menu_book_rounded, label: '오늘의 말씀', color: EdenColors.primary, isDark: isDark),
            const SizedBox(height: 12),
            ..._response.verses.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VerseCard(verse: v, isDark: isDark),
            )),
            const SizedBox(height: 20),

            // 유튜브 — placeholder 자동 대체
            YouTubeCarousel(videos: _youtubeVideos, title: '추천 찬양'),
            const SizedBox(height: 24),

            _PrayerCard(prayer: _response.prayerGuide, isDark: isDark),
            const SizedBox(height: 28),

            Center(child: OutlinedButton.icon(
              onPressed: _loadAlternative,
              icon: const Icon(Icons.shuffle_rounded, size: 18),
              label: const Text('다른 말씀 보기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: EdenColors.primary,
                side: BorderSide(color: EdenColors.primary.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ComfortCard extends StatelessWidget {
  final String message; final bool isDark;
  const _ComfortCard({required this.message, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [EdenColors.primary.withValues(alpha: isDark ? 0.25 : 0.08), EdenColors.accent.withValues(alpha: isDark ? 0.15 : 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24), border: Border.all(color: EdenColors.primary.withValues(alpha: 0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: EdenColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.auto_awesome, size: 16, color: EdenColors.primary)),
          const SizedBox(width: 10),
          Text('에덴이 드리는 위로', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EdenColors.primary, letterSpacing: 1)),
        ]),
        const SizedBox(height: 18),
        Text(message, style: TextStyle(fontSize: 16, height: 1.7, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
      ]),
    );
  }
}

class _VerseCard extends StatelessWidget {
  final EmotionVerse verse; final bool isDark;
  const _VerseCard({required this.verse, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final verseText = EmotionMatchService().getVerseText(verse);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: EdenColors.primary.withValues(alpha: 0.12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.menu_book_rounded, size: 14, color: EdenColors.primary), const SizedBox(width: 6),
          Text(verse.ref, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EdenColors.primary)),
        ]),
        const SizedBox(height: 12),
        Text(verseText.isNotEmpty ? '"$verseText"' : '"말씀을 불러오는 중..."',
          style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic, height: 1.7, color: (isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight).withValues(alpha: 0.85))),
        const SizedBox(height: 14),
        Row(children: [
          _ActionChip(icon: Icons.copy_rounded, label: '복사', onTap: () {
            Clipboard.setData(ClipboardData(text: '$verseText\n- ${verse.ref}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('구절을 복사했습니다'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)));
          }),
          const SizedBox(width: 8),
          _ActionChip(icon: Icons.share_outlined, label: '공유', onTap: () => Share.share('"$verseText"\n\n${verse.ref}\n\n- 에덴 성경책')),
        ]),
      ]),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String prayer; final bool isDark;
  const _PrayerCard({required this.prayer, required this.isDark});
  @override
  Widget build(BuildContext context) {
    if (prayer.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: EdenColors.accent.withValues(alpha: isDark ? 0.12 : 0.06), borderRadius: BorderRadius.circular(20), border: Border.all(color: EdenColors.accent.withValues(alpha: 0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionLabel(icon: Icons.favorite_rounded, label: '함께 기도해요', color: EdenColors.accent, isDark: isDark),
        const SizedBox(height: 14),
        Text(prayer, style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, height: 1.7, color: isDark ? EdenColors.textSecondaryDark : EdenColors.textSecondaryLight)),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon; final String label; final Color color; final bool isDark;
  const _SectionLabel({required this.icon, required this.label, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: color), const SizedBox(width: 8),
    Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 2)),
  ]);
}

class _ActionChip extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: EdenColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: EdenColors.primary), const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: EdenColors.primary)),
    ]),
  ));
}
