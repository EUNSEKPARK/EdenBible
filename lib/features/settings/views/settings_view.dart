import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/theme/colors.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/tts_service.dart';
import '../../tutorial/views/tutorial_view.dart';

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

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('프로필 사진', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ListTile(leading: const Icon(Icons.camera_alt_rounded), title: const Text('카메라'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library_rounded), title: const Text('갤러리'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          if (_settings.profileImagePath.isNotEmpty)
            ListTile(leading: Icon(Icons.delete_outline, color: Colors.red.shade400), title: Text('사진 삭제', style: TextStyle(color: Colors.red.shade400)),
              onTap: () { _settings.setProfileImagePath(''); Navigator.pop(ctx); }),
        ]),
      )),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last;
    final savePath = '${dir.path}/profile_image.$ext';
    await File(picked.path).copy(savePath);
    await _settings.setProfileImagePath(savePath);
  }

  void _editNickname() {
    final controller = TextEditingController(text: _settings.nickname);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('닉네임 설정'),
      content: TextField(
        controller: controller, autofocus: true, maxLength: 12,
        decoration: const InputDecoration(hintText: '이름을 입력하세요', counterText: ''),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) { _settings.setNickname(controller.text); Navigator.pop(ctx); },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
        TextButton(onPressed: () { _settings.setNickname(controller.text); Navigator.pop(ctx); }, child: const Text('저장')),
      ],
    ));
  }

  void _showThemePicker() {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('화면 테마', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _ThemeOption(icon: Icons.light_mode_rounded, label: '라이트', isSelected: _settings.themeMode == ThemeMode.light,
            onTap: () { _settings.setThemeMode(ThemeMode.light); Navigator.pop(ctx); }),
          _ThemeOption(icon: Icons.dark_mode_rounded, label: '다크', isSelected: _settings.themeMode == ThemeMode.dark,
            onTap: () { _settings.setThemeMode(ThemeMode.dark); Navigator.pop(ctx); }),
          _ThemeOption(icon: Icons.brightness_auto_rounded, label: '시스템 설정', isSelected: _settings.themeMode == ThemeMode.system,
            onTap: () { _settings.setThemeMode(ThemeMode.system); Navigator.pop(ctx); }),
        ]),
      )),
    );
  }

  void _showGoalPicker() {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        int selected = _settings.dailyGoalChapters;
        return StatefulBuilder(builder: (ctx, setLocal) => SafeArea(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('하루 읽기 목표', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('매일 몇 장씩 읽을까요?', style: TextStyle(fontSize: 13, color: EdenColors.textTertiaryLight)),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(onPressed: () { if (selected > 1) setLocal(() => selected--); }, icon: const Icon(Icons.remove_circle_outline, size: 32)),
              const SizedBox(width: 20),
              Text('$selected장', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: EdenColors.primary)),
              const SizedBox(width: 20),
              IconButton(onPressed: () { if (selected < 20) setLocal(() => selected++); }, icon: const Icon(Icons.add_circle_outline, size: 32)),
            ]),
            const SizedBox(height: 8),
            Text(selected <= 3 ? '천천히, 꾸준히!' : selected <= 7 ? '좋은 습관이 될 거예요!' : '도전적인 목표! 화이팅!',
              style: TextStyle(fontSize: 13, color: EdenColors.accent)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () { _settings.setDailyGoalChapters(selected); Navigator.pop(ctx); },
              child: const Text('설정 완료'))),
          ]),
        )));
      },
    );
  }

  void _showResetDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('데이터 초기화'),
      content: const Text('읽기 기록, 북마크, 감정 히스토리가 삭제됩니다.\n프로필(이름, 사진)은 유지됩니다.\n\n정말 초기화하시겠어요?'),
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
    final tts = TtsService();
    final displayName = _settings.nickname.isNotEmpty ? _settings.nickname : '사용자';
    final goalProgress = _settings.dailyGoalChapters > 0 ? (_settings.todayReadChapters / _settings.dailyGoalChapters).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ═══ 프로필 카드 ═══
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(24)),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: EdenColors.primary.withValues(alpha: 0.15), border: Border.all(color: Colors.white, width: 3)),
                    child: _settings.profileImagePath.isNotEmpty && File(_settings.profileImagePath).existsSync()
                        ? ClipOval(child: Image.file(File(_settings.profileImagePath), width: 72, height: 72, fit: BoxFit.cover))
                        : Icon(Icons.person_rounded, size: 36, color: EdenColors.primary),
                  ),
                  Positioned(bottom: 0, right: 0, child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: EdenColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                  )),
                ]),
              ),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: _editNickname,
                  child: Row(children: [
                    Flexible(child: Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_rounded, size: 16, color: EdenColors.secondary),
                  ]),
                ),
                const SizedBox(height: 4),
                Text('에덴 성경책과 함께하는 중', style: TextStyle(fontSize: 12, color: EdenColors.textTertiaryLight)),
              ])),
            ]),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('통독 진행률', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: EdenColors.primary, letterSpacing: 2)),
                  Text('${(_settings.readingProgress * 100).toInt()}% (${_settings.readChaptersCount}/1,189장)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EdenColors.secondary)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _settings.readingProgress, minHeight: 6,
                  backgroundColor: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFE4E2DD), valueColor: AlwaysStoppedAnimation(EdenColors.primary))),
              ])),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('오늘 목표', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: EdenColors.accent, letterSpacing: 2)),
                  Text('${_settings.todayReadChapters} / ${_settings.dailyGoalChapters}장',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _settings.todayReadChapters >= _settings.dailyGoalChapters ? EdenColors.accent : EdenColors.secondary)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: goalProgress, minHeight: 6,
                  backgroundColor: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFE4E2DD), valueColor: AlwaysStoppedAnimation(EdenColors.accent))),
              ])),
            const SizedBox(height: 10),
            Row(children: [
              _StatBadge(icon: Icons.local_fire_department_rounded, value: '${_settings.streakDays}일', label: '연속 읽기', color: EdenColors.accent, isDark: isDark),
              const SizedBox(width: 8),
              _StatBadge(icon: Icons.auto_stories_rounded, value: '${_settings.totalChaptersRead}장', label: '누적 읽기', color: EdenColors.primary, isDark: isDark),
              const SizedBox(width: 8),
              _StatBadge(icon: Icons.bookmark_rounded, value: '${_settings.bookmarks.length}개', label: '북마크', color: const Color(0xFF7B8FA1), isDark: isDark),
              const SizedBox(width: 8),
              _StatBadge(icon: Icons.favorite_rounded, value: '${_settings.emotionHistory.length}회', label: '힐링', color: const Color(0xFFC97B5B), isDark: isDark),
            ]),
          ]),
        ),
        const SizedBox(height: 28),

        // ═══ 읽기 설정 ═══
        _SectionTitle(label: '읽기 설정'),
        const SizedBox(height: 16),

        GestureDetector(onTap: _showThemePicker, child: _tile(isDark: isDark, icon: Icons.palette_outlined, label: '화면 테마',
          subtitle: _settings.themeMode == ThemeMode.light ? '라이트' : _settings.themeMode == ThemeMode.dark ? '다크' : '시스템 설정',
          trailing: Icon(Icons.chevron_right, color: EdenColors.textTertiaryLight))),
        const SizedBox(height: 10),

        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.format_size, color: EdenColors.secondary), const SizedBox(width: 14), const Text('글자 크기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)), const Spacer(), Text('${_settings.fontSize.toInt()}pt', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: EdenColors.primary))]),
            const SizedBox(height: 10),
            Slider(value: _settings.fontSize, min: 14, max: 32, divisions: 18, activeColor: EdenColors.primary, inactiveColor: EdenColors.secondary.withValues(alpha: 0.2), onChanged: (v) => _settings.setFontSize(v)),
          ])),
        const SizedBox(height: 10),

        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.format_line_spacing_rounded, color: EdenColors.secondary), const SizedBox(width: 14), const Text('줄 간격', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)), const Spacer(),
              Text(_settings.lineHeight <= 1.5 ? '좁게' : _settings.lineHeight <= 1.9 ? '보통' : _settings.lineHeight <= 2.2 ? '넓게' : '아주 넓게',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: EdenColors.primary))]),
            const SizedBox(height: 10),
            Slider(value: _settings.lineHeight, min: 1.4, max: 2.6, divisions: 6, activeColor: EdenColors.primary, inactiveColor: EdenColors.secondary.withValues(alpha: 0.2), onChanged: (v) => _settings.setLineHeight(v)),
          ])),
        const SizedBox(height: 10),

        Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05))),
          child: Text('여호와는 나의 목자시니 내가 부족함이 없으리로다 그가 나를 푸른 초장에 누이시며 쉴 만한 물 가로 인도하시는도다',
            style: TextStyle(fontSize: _settings.fontSize, height: _settings.lineHeight), textAlign: TextAlign.center)),
        const SizedBox(height: 10),

        GestureDetector(onTap: () => _settings.setTranslation(_settings.translation == 'krv' ? 'kjv' : 'krv'),
          child: _tile(isDark: isDark, icon: Icons.translate, label: '기본 번역본', subtitle: _settings.translation == 'krv' ? '개역한글' : 'KJV', trailing: Icon(Icons.swap_horiz, color: EdenColors.primary))),
        const SizedBox(height: 10),

        ListenableBuilder(listenable: tts, builder: (_, __) => GestureDetector(
          onTap: () => tts.cycleSpeed(),
          child: _tile(isDark: isDark, icon: Icons.speed_rounded, label: 'TTS 읽기 속도', subtitle: tts.speedLabel, trailing: Icon(Icons.chevron_right, color: EdenColors.textTertiaryLight)))),
        const SizedBox(height: 10),

        GestureDetector(onTap: _showGoalPicker,
          child: _tile(isDark: isDark, icon: Icons.flag_rounded, label: '하루 읽기 목표', subtitle: '${_settings.dailyGoalChapters}장 / 일', trailing: Icon(Icons.chevron_right, color: EdenColors.textTertiaryLight))),
        const SizedBox(height: 28),

        // ═══ 데이터 관리 ═══
        _SectionTitle(label: '데이터 관리'),
        const SizedBox(height: 16),

        _tile(isDark: isDark, icon: Icons.bookmark_outline, label: '저장된 북마크', subtitle: '${_settings.bookmarks.length}개', trailing: Icon(Icons.chevron_right, color: EdenColors.textTertiaryLight)),
        const SizedBox(height: 10),

        GestureDetector(onTap: _showResetDialog,
          child: _tile(isDark: isDark, icon: Icons.delete_outline, label: '데이터 초기화', subtitle: '프로필 유지, 읽기 기록/북마크/힐링 삭제', trailing: Icon(Icons.chevron_right, color: Colors.red.withValues(alpha: 0.5)))),
        const SizedBox(height: 28),

        // ═══ 앱 정보 ═══
        _SectionTitle(label: '앱 정보'),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => TutorialView(onComplete: () => Navigator.pop(context)))),
          child: _tile(isDark: isDark, icon: Icons.help_outline_rounded, label: '사용법 튜토리얼', subtitle: '앱 사용 설명을 다시 볼 수 있어요', trailing: Icon(Icons.chevron_right, color: EdenColors.textTertiaryLight))),
        const SizedBox(height: 10),

        _tile(isDark: isDark, icon: Icons.info_outline, label: '버전', subtitle: '1.0.0 (Build 1)', trailing: const SizedBox()),
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

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});
  @override
  Widget build(BuildContext context) => Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: EdenColors.secondary, letterSpacing: 3));
}

class _ThemeOption extends StatelessWidget {
  final IconData icon; final String label; final bool isSelected; final VoidCallback onTap;
  const _ThemeOption({required this.icon, required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: isSelected ? EdenColors.primary : EdenColors.secondary),
    title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
    trailing: isSelected ? Icon(Icons.check_circle, color: EdenColors.primary) : null,
    onTap: onTap,
  );
}

class _StatBadge extends StatelessWidget {
  final IconData icon; final String value, label; final Color color; final bool isDark;
  const _StatBadge({required this.icon, required this.value, required this.label, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 8, color: EdenColors.textTertiaryLight, letterSpacing: 0.5)),
      ]),
    ));
  }
}
