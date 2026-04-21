import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

class EdenBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EdenBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? EdenColors.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, filledIcon: Icons.home_rounded, label: '홈', index: 0, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.menu_book_outlined, filledIcon: Icons.menu_book_rounded, label: '성경', index: 1, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.favorite_outline_rounded, filledIcon: Icons.favorite_rounded, label: '힐링', index: 2, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.bookmark_outline_rounded, filledIcon: Icons.bookmark_rounded, label: '북마크', index: 3, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.nightlight_outlined, filledIcon: Icons.nightlight_round, label: '수면묵상', index: 4, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.settings_outlined, filledIcon: Icons.settings_rounded, label: '설정', index: 5, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({required this.icon, required this.filledIcon, required this.label, required this.index, required this.currentIndex, required this.onTap});

  bool get isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? EdenColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? filledIcon : icon, size: 26, color: isActive ? EdenColors.primary : EdenColors.secondary.withValues(alpha: 0.7)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, color: isActive ? EdenColors.primary : EdenColors.secondary.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
