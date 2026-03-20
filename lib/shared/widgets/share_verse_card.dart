import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../app/theme/colors.dart';

/// SNS 공유용 성경 구절 카드 위젯
class ShareVerseCard extends StatelessWidget {
  final String verseText;
  final String verseRef;
  final String? message; // AI 상담 메시지 (선택)
  final GlobalKey repaintKey;

  const ShareVerseCard({
    super.key,
    required this.verseText,
    required this.verseRef,
    this.message,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              EdenColors.primary,
              EdenColors.primary.withValues(alpha: 0.85),
              EdenColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 라벨
            Row(
              children: [
                Container(width: 24, height: 1, color: Colors.white.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Text(
                  '에덴',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 성경 구절
            Text(
              '"$verseText"',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.6,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),

            // 참조
            Text(
              verseRef,
              style: TextStyle(
                fontSize: 13,
                color: EdenColors.accentLight,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),

            // AI 메시지 (있을 경우)
            if (message != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  message!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 24),
            // 하단 워터마크
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  '에덴 - AI 성경책',
                  style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 공유 카드를 이미지로 캡처하고 공유하는 유틸리티
class ShareCardHelper {
  /// 카드 위젯을 이미지로 캡처
  static Future<Uint8List?> captureCard(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('카드 캡처 오류: $e');
      return null;
    }
  }

  /// 카드를 이미지로 저장 후 공유
  static Future<void> shareCard(GlobalKey key, {String? text}) async {
    final imageBytes = await captureCard(key);
    if (imageBytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/eden_verse_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: text ?? '에덴 - AI 성경책에서 공유합니다',
    );
  }
}

/// 공유 카드 미리보기 + 공유 버튼이 포함된 BottomSheet
void showShareCardSheet(BuildContext context, {
  required String verseText,
  required String verseRef,
  String? message,
}) {
  final cardKey = GlobalKey();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('공유 카드 미리보기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // 카드 미리보기
            Center(
              child: ShareVerseCard(
                verseText: verseText,
                verseRef: verseRef,
                message: message,
                repaintKey: cardKey,
              ),
            ),
            const SizedBox(height: 24),

            // 공유 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ShareCardHelper.shareCard(cardKey, text: '$verseRef - 에덴 AI 성경책');
                },
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('이미지로 공유하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EdenColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 텍스트 공유
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Share.share('"$verseText"\n\n$verseRef\n\n- 에덴 AI 성경책');
                },
                icon: const Icon(Icons.text_fields_rounded, size: 18),
                label: const Text('텍스트로 공유하기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
