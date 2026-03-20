import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/services/settings_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _settings = SettingsService();

  @override
  void initState() { super.initState(); _settings.addListener(_refresh); }
  void _refresh() { if (mounted) setState(() {}); }
  @override
  void dispose() { _settings.removeListener(_refresh); super.dispose(); }

  void _showResetDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('데이터 초기화'),
      content: const Text('읽기 기록, 북마크, 감정 히스토리 등 모든 데이터가 삭제됩니다.\n\n정말 초기화하시겠어요?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
        TextButton(onPressed: () { Navigator.pop(ctx); _settings.resetAllData();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('데이터가 초기화되었습니다'), behavior: SnackBarBehavior.floating));
        }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('초기화')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ─── 프로필 + 통계 ───
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Row(children: [
              Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: EdenColors.primary.withValues(alpha: 0.15), border: Border.all(color: Colors.white, width: 3)), child: Icon(Icons.person_rounded, size: 36, color: EdenColors.primary)),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('사용자', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('에덴 성경책과 함께하는 중', style: TextStyle(fontSize: 12, color: EdenColors.textTertiaryLight)),
              ])),
            ]),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('읽기 플랜 진행률', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: EdenColors.primary, letterSpacing: 2)),
                  Text('${(_settings.readingProgress * 100).toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, color: EdenColors.secondary)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _settings.readingProgress, minHeight: 6, backgroundColor: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFE4E2DD), valueColor: AlwaysStoppedAnimation(EdenColors.primary))),
              ])),
            const SizedBox(height: 10),
            Row(children: [
              _StatBadge(icon: Icons.local_fire_department_rounded, value: '${_settings.streakDays}일', label: '연속 읽기', color: EdenColors.accent, isDark: isDark),
              const SizedBox(width: 10),
              _StatBadge(icon: Icons.bookmark_rounded, value: '${_settings.bookmarks.length}개', label: '북마크', color: EdenColors.primary, isDark: isDark),
              const SizedBox(width: 10),
              _StatBadge(icon: Icons.favorite_rounded, value: '${_settings.emotionHistory.length}회', label: '힐링 사용', color: const Color(0xFFC97B5B), isDark: isDark),
            ]),
          ]),
        ),
        const SizedBox(height: 20),

        // ─── 프리미엄 배너 ───
        Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Stack(children: [
            Positioned.fill(child: Image.asset('assets/images/shared/premium_banner.png', fit: BoxFit.cover)),
            Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [EdenColors.primary.withValues(alpha: 0.85), EdenColors.secondary.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight)))),
            Padding(padding: const EdgeInsets.all(20), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.auto_awesome, size: 18, color: Colors.white), const SizedBox(width: 8), const Text('에덴 프리미엄', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))]),
                const SizedBox(height: 4),
                Text('준비 중입니다. 곧 더 많은 기능을 만나보세요.', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
              ])),
              GestureDetector(onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('준비 중입니다'), behavior: SnackBarBehavior.floating)),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                  child: Text('업그레이드', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: EdenColors.primary)))),
            ])),
          ])),
        const SizedBox(height: 28),

        // ─── 읽기 설정 ───
        Text('읽기 설정', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: EdenColors.secondary, letterSpacing: 3)),
        const SizedBox(height: 16),

        _tile(isDark: isDark, icon: Icons.dark_mode_outlined, label: '다크 모드', trailing: Switch.adaptive(value: _settings.themeMode == ThemeMode.dark, onChanged: (v) => _settings.setThemeMode(v ? ThemeMode.dark : ThemeMode.light), activeColor: EdenColors.primary)),
        const SizedBox(height: 10),

        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.format_size, color: EdenColors.secondary), const SizedBox(width: 14), const Text('글자 크기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)), const Spacer(), Text('${_settings.fontSize.toInt()}pt', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: EdenColors.primary))]),
            const SizedBox(height: 14),
            Slider(value: _settings.fontSize, min: 14, max: 32, divisions: 18, activeColor: EdenColors.primary, inactiveColor: EdenColors.secondary.withValues(alpha: 0.2), onChanged: (v) => _settings.setFontSize(v)),
            Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text('여호와는 나의 목자시니 내가 부족함이 없으리로다', style: TextStyle(fontSize: _settings.fontSize, height: 1.8), textAlign: TextAlign.center)),
          ])),
        const SizedBox(height: 10),

        GestureDetector(onTap: () => _settings.setTranslation(_settings.translation == 'krv' ? 'kjv' : 'krv'),
          child: _tile(isDark: isDark, icon: Icons.translate, label: '기본 번역본', subtitle: _settings.translation == 'krv' ? '개역한글' : 'KJV', trailing: Icon(Icons.swap_horiz, color: EdenColors.primary))),
        const SizedBox(height: 10),

        // 알림 — 향후 업데이트 예정
        _tile(isDark: isDark, icon: Icons.notifications_outlined, label: '오늘의 말씀 알림', subtitle: '향후 업데이트에서 추가 예정', trailing: Icon(Icons.lock_outline_rounded, size: 18, color: EdenColors.textTertiaryLight)),
        const SizedBox(height: 28),

        // ─── 데이터 관리 ───
        Text('데이터 관리', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: EdenColors.secondary, letterSpacing: 3)),
        const SizedBox(height: 16),

        _tile(isDark: isDark, icon: Icons.bookmark_outline, label: '저장된 북마크', subtitle: '${_settings.bookmarks.length}개', trailing: Icon(Icons.chevron_right, color: EdenColors.textTertiaryLight)),
        const SizedBox(height: 10),

        GestureDetector(onTap: _showResetDialog,
          child: _tile(isDark: isDark, icon: Icons.delete_outline, label: '데이터 초기화', subtitle: '읽기 기록, 북마크, 감정 히스토리 삭제', trailing: Icon(Icons.chevron_right, color: Colors.red.withValues(alpha: 0.5)))),
        const SizedBox(height: 28),

        // ─── 앱 정보 ───
        Text('앱 정보', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: EdenColors.secondary, letterSpacing: 3)),
        const SizedBox(height: 16),

        _tile(isDark: isDark, icon: Icons.info_outline, label: '버전', subtitle: '1.0.0 (Build 1)', trailing: const SizedBox()),
        const SizedBox(height: 10),
        _tile(isDark: isDark, icon: Icons.wifi_off_rounded, label: '오프라인 전용', subtitle: '인터넷 없이 모든 기능 사용 가능', trailing: Icon(Icons.check_circle_outline, size: 18, color: EdenColors.primary)),
        const SizedBox(height: 10),
        _tile(isDark: isDark, icon: Icons.menu_book_outlined, label: '성경 데이터', subtitle: '개역한글 27,121절 + KJV 31,102절', trailing: const SizedBox()),
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _tile({required bool isDark, required IconData icon, required String label, String? subtitle, required Widget trailing}) {
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: EdenColors.secondary), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 12, color: EdenColors.textTertiaryLight), overflow: TextOverflow.ellipsis),
        ])),
        trailing,
      ]),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon; final String value, label; final Color color; final bool isDark;
  const _StatBadge({required this.icon, required this.value, required this.label, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: EdenColors.textTertiaryLight, letterSpacing: 1)),
      ]),
    ));
  }
}
