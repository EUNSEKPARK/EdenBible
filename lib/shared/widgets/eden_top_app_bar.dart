import 'dart:io';
import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../core/services/settings_service.dart';
import '../../features/bible_reader/views/search_view.dart';
import '../../features/deep_study/views/study_view.dart';
import '../../features/sleep/views/sleep_mode_view.dart';
import '../../features/reading_plan/views/reading_plan_view.dart';
import '../../features/tutorial/views/tutorial_view.dart';

class EdenTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNavigateToBible;
  final VoidCallback? onNavigateToCounsel;
  final VoidCallback? onNavigateToSettings;
  final void Function(int bookId, int chapter)? onNavigateToVerse;

  const EdenTopAppBar({super.key, this.onNavigateToBible, this.onNavigateToCounsel, this.onNavigateToSettings, this.onNavigateToVerse});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
        border: Border(bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)))),
      child: SafeArea(bottom: false, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        IconButton(onPressed: () => _showMenuSheet(context), icon: Icon(Icons.menu_rounded, color: EdenColors.primary)),
        const SizedBox(width: 4),
        Expanded(child: Text('에덴 성경책', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: EdenColors.primary, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
        IconButton(onPressed: () => _openSearch(context), icon: Icon(Icons.search_rounded, color: EdenColors.primary)),
        const SizedBox(width: 4),
        GestureDetector(onTap: () => _showProfileSheet(context), child: _ProfileAvatar(size: 34, iconSize: 20, isDark: isDark)),
      ]))),
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final result = await Navigator.push<Map<String, int>>(context, MaterialPageRoute(builder: (_) => const SearchView()));
    if (result != null && result.containsKey('bookId')) {
      onNavigateToVerse?.call(result['bookId']!, result['chapter']!);
    }
  }

  void _showMenuSheet(BuildContext context) {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(child: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('메뉴', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: EdenColors.primary)),
            const SizedBox(height: 20),
            ListTile(leading: Icon(Icons.menu_book_rounded, color: EdenColors.primary), title: const Text('성경 읽기'),
              onTap: () { Navigator.pop(ctx); onNavigateToBible?.call(); }),
            ListTile(leading: Icon(Icons.checklist_rounded, color: EdenColors.primary), title: const Text('읽기 플랜'),
              subtitle: const Text('3개월 · 6개월 · 1년 통독표', style: TextStyle(fontSize: 14)),
              onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingPlanView(onNavigateToVerse: onNavigateToVerse))); }),
            ListTile(leading: Icon(Icons.favorite_rounded, color: EdenColors.accent), title: const Text('마음 힐링'),
              subtitle: const Text('감정별 맞춤 말씀 · 찬양 · 기도', style: TextStyle(fontSize: 14)),
              onTap: () { Navigator.pop(ctx); onNavigateToCounsel?.call(); }),
            ListTile(leading: Icon(Icons.nightlight_round, color: Colors.amber), title: const Text('수면 묵상'),
              subtitle: const Text('잔잔한 말씀과 함께 잠들기', style: TextStyle(fontSize: 14)),
              onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepModeView())); }),
            ListTile(leading: Icon(Icons.settings_rounded, color: EdenColors.secondary), title: const Text('설정'),
              onTap: () { Navigator.pop(ctx); onNavigateToSettings?.call(); }),
            const Divider(height: 1),
            ListTile(leading: Icon(Icons.help_outline_rounded, color: EdenColors.secondary), title: const Text('사용법 튜토리얼'),
              subtitle: const Text('앱 기능 안내 보기', style: TextStyle(fontSize: 14)),
              onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (c) => TutorialView(onComplete: () => Navigator.pop(c)))); }),
          ])))),
    );
  }

  void _showProfileSheet(BuildContext context) {
    final settings = SettingsService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => ListenableBuilder(
        listenable: settings,
        builder: (_, __) {
          final nickname = settings.nickname.isNotEmpty ? settings.nickname : '사용자';
          final imagePath = settings.profileImagePath;
          final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();
          return SafeArea(child: Padding(padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EdenColors.primary.withValues(alpha: 0.15),
                  image: hasImage ? DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover) : null,
                ),
                child: hasImage ? null : Icon(Icons.person_rounded, size: 36, color: EdenColors.primary)),
              const SizedBox(height: 16),
              Text(nickname, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('에덴 성경책과 함께하는 중', style: TextStyle(fontSize: 15, color: EdenColors.textTertiaryLight)),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기'))),
            ])));
        },
      ),
    );
  }
}

/// 프로필 아바타 위젯 (SettingsService에서 사진을 읽어 표시)
class _ProfileAvatar extends StatelessWidget {
  final double size;
  final double iconSize;
  final bool isDark;
  const _ProfileAvatar({required this.size, required this.iconSize, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    return ListenableBuilder(
      listenable: settings,
      builder: (_, __) {
        final imagePath = settings.profileImagePath;
        final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();
        return Container(width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? EdenColors.surfaceVariantDark : EdenColors.surfaceVariantLight,
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)),
            image: hasImage ? DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover) : null,
          ),
          child: hasImage ? null : Icon(Icons.person_rounded, size: iconSize, color: EdenColors.secondary));
      },
    );
  }
}
