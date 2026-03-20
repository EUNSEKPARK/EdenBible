import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme/colors.dart';
import '../../core/models/emotion_models.dart';

/// 유튜브 추천 영상 카드 — 가로 스크롤 캐러셀용
class YouTubeCard extends StatelessWidget {
  final YouTubeCurated video;

  const YouTubeCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaceholder = video.videoId.startsWith('placeholder');

    return GestureDetector(
      onTap: () => _openYouTube(context),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? EdenColors.surfaceVariantDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 124,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: isDark ? EdenColors.surfaceDark : const Color(0xFFF0EEE8),
              ),
              child: Stack(fit: StackFit.expand, children: [
                if (!isPlaceholder)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      'https://img.youtube.com/vi/${video.videoId}/mqdefault.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _PlaceholderThumb(isDark: isDark),
                    ),
                  )
                else
                  _PlaceholderThumb(isDark: isDark),
                Center(child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                )),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(video.title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight, height: 1.4),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openYouTube(BuildContext context) async {
    if (video.videoId.startsWith('placeholder')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유튜브 영상이 준비 중입니다'), behavior: SnackBarBehavior.floating));
      return;
    }
    // 유튜브 앱 → 브라우저 순서로 시도
    final appUri = Uri.parse('youtube://www.youtube.com/watch?v=${video.videoId}');
    final webUri = Uri.parse('https://www.youtube.com/watch?v=${video.videoId}');
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유튜브를 열 수 없습니다'), behavior: SnackBarBehavior.floating));
      }
    }
  }
}

class _PlaceholderThumb extends StatelessWidget {
  final bool isDark;
  const _PlaceholderThumb({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(colors: [EdenColors.primary.withValues(alpha: 0.3), EdenColors.accent.withValues(alpha: 0.2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(child: Icon(Icons.music_note_rounded, size: 36, color: Colors.white.withValues(alpha: 0.6))),
    );
  }
}

/// 유튜브 추천 가로 스크롤 섹션
class YouTubeCarousel extends StatelessWidget {
  final List<YouTubeCurated> videos;
  final String title;

  const YouTubeCarousel({super.key, required this.videos, this.title = '추천 영상'});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.play_circle_outline_rounded, size: 18, color: EdenColors.accent),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? EdenColors.accentLight : EdenColors.accent, letterSpacing: 2)),
      ]),
      const SizedBox(height: 14),
      SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: videos.length,
          itemBuilder: (_, i) => YouTubeCard(video: videos[i]),
        ),
      ),
    ]);
  }
}
