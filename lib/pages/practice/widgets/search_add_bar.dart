import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../controllers/practice_controller.dart';

class SearchAddBar extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final bool isFilterActive;
  final VoidCallback onFilterPressed;
  final VoidCallback onRandomPressed;

  const SearchAddBar({
    super.key,
    required this.searchText,
    required this.onSearchChanged,
    required this.isFilterActive,
    required this.onFilterPressed,
    required this.onRandomPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Center(
                child: TextFormField(
                  initialValue: searchText,
                  onChanged: onSearchChanged,
                  cursorColor: AppColors.primary,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search by title...',
                    hintStyle: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),
          //  Filter + Random ikonları
          _ToolbarIconButton(
            icon: PhosphorIcons.slidersHorizontal(PhosphorIconsStyle.regular),
            tooltip: 'Filter',
            isActive: isFilterActive,
            onTap: onFilterPressed,
          ),
          const SizedBox(width: AppSpacing.xs),
          _ToolbarIconButton(
            icon: PhosphorIcons.shuffle(PhosphorIconsStyle.regular),
            tooltip: 'Pick random',
            isActive: false,
            onTap: onRandomPressed,
          ),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final PhosphorIconData icon;
  final String? tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isActive ? AppColors.primary : AppColors.textMuted;

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(
            icon,
            size: 22,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
