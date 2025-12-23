import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class QuestionHeader extends StatelessWidget {
  final int current;
  final int total;

  final bool isFlagged;
  final VoidCallback? onToggleFlag;
  final VoidCallback? onClear;

  const QuestionHeader({
    super.key,
    required this.current,
    required this.total,
    required this.isFlagged,
    this.onToggleFlag,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // LEFT
        Text(
          'Question $current of $total',
          style: AppTextStyles.title,
        ),

        const Spacer(),

        // FLAG
        _HeaderAction(
          label: 'Flag',
          icon: isFlagged
              ? PhosphorIcons.flag(PhosphorIconsStyle.fill)
              : PhosphorIcons.flag(PhosphorIconsStyle.regular),
          color: isFlagged ? AppColors.primary : AppColors.textSecondary,
          onTap: onToggleFlag,
        ),

        if (onClear != null) ...[
          const SizedBox(width: AppSpacing.md),

          // CLEAR
          _HeaderAction(
            label: 'Clear',
            icon: PhosphorIcons.arrowCounterClockwise(
              PhosphorIconsStyle.regular,
            ),
            color: AppColors.textSecondary,
            onTap: onClear,
          ),
        ],
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _HeaderAction({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
