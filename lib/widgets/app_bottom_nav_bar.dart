// lib/widgets/app_bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../constants/constants.dart';
import '../constants/text_styles.dart';
import '../services/sfx/sound_service.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface, // düz beyaz bar
        border: Border(
          top: BorderSide(
            color: AppColors.border, // ince gri çizgi
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        top: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final selected = index == currentIndex;
          return _FlatNavItem(
            icon: selected ? item.activeIcon ?? item.icon : item.icon,
            label: item.label,
            selected: selected,
            onTap: () => onItemSelected(index),
          );
        }),
      ),
    );
  }
}

/// Item modeli
class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}

/// Nav Items
final List<_NavItemData> _navItems = [
  _NavItemData(
    icon: PhosphorIcons.house(PhosphorIconsStyle.light),
    activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
    label: 'Home',
  ),
  _NavItemData(
    icon: PhosphorIcons.playCircle(PhosphorIconsStyle.light),
    activeIcon: PhosphorIcons.playCircle(PhosphorIconsStyle.fill),
    label: 'Practice',
  ),
  _NavItemData(
    icon: PhosphorIcons.clipboardText(PhosphorIconsStyle.light),
    activeIcon: PhosphorIcons.clipboardText(PhosphorIconsStyle.fill),
    label: 'Exam',
  ),
  _NavItemData(
    icon: PhosphorIcons.books(PhosphorIconsStyle.light),
    activeIcon: PhosphorIcons.books(PhosphorIconsStyle.fill),
    label: 'Library',
  ),
  _NavItemData(
    icon: PhosphorIcons.user(PhosphorIconsStyle.light),
    activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
    label: 'Profile',
  ),
];

class _FlatNavItem extends StatelessWidget {
  const _FlatNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.zero,
      onTap: () {
        // 🔊 Tab switch sound
        SoundService.playSync(SoundEffect.tabSwitch);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSizes.lg,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: AppDurations.normal,
              curve: Curves.easeOut,
              height: 3,
              width: selected ? 28 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
