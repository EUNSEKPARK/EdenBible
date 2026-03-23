import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
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
  static const MethodChannel _kakaoChannel = MethodChannel('com.edenbible.app/kakao_share');

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

  /// 카카오톡으로 이미지 공유. Android는 카카오톡 앱으로 직접 전달, 미설치 시 시스템 공유로 폴백.
  /// iOS는 앱 지정 공유가 불가하여 시스템 공유 시트를 사용합니다.
  static Future<void> shareCardToKakao(
    GlobalKey key, {
    required String caption,
  }) async {
    final imageBytes = await captureCard(key);
    if (imageBytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/eden_verse_kakao_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);
    final xFile = XFile(file.path);

    if (Platform.isAndroid) {
      try {
        final opened = await _kakaoChannel.invokeMethod<bool>('shareImageToKakao', {
          'path': file.path,
          'text': caption,
        });
        if (opened == true) return;
      } on PlatformException catch (e) {
        debugPrint('카카오톡 공유 채널 오류: $e');
      }
    }

    await Share.shareXFiles([xFile], text: caption);
  }
}

/// 시스템 공유 시트 상단 앱 아이콘 줄과 비슷한 터치 타일
class _ShareIconTile extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  const _ShareIconTile({
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 76,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
            const SizedBox(height: 20),

            // OS 공유 시트에는 앱에서 아이콘을 끼워 넣을 수 없어, 같은 패턴의 아이콘 줄을 바텀시트에 둡니다.
            Text(
              '이미지 공유',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ShareIconTile(
                  label: '카카오톡',
                  backgroundColor: const Color(0xFFFEE500),
                  iconColor: const Color(0xFF191919),
                  icon: Icons.chat_bubble_rounded,
                  onTap: () async {
                    await ShareCardHelper.shareCardToKakao(
                      cardKey,
                      caption: '$verseRef - 에덴 AI 성경책',
                    );
                  },
                ),
                const SizedBox(width: 28),
                _ShareIconTile(
                  label: '다른 앱',
                  backgroundColor: EdenColors.primary.withValues(alpha: 0.18),
                  iconColor: EdenColors.primary,
                  icon: Icons.share_rounded,
                  onTap: () async {
                    await ShareCardHelper.shareCard(cardKey, text: '$verseRef - 에덴 AI 성경책');
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '「다른 앱」에서 인스타그램·메시지 등 시스템 공유 목록이 열립니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 16),

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
