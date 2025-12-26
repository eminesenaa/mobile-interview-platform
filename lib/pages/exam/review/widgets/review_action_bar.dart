// lib/pages/exam/widgets/review_action_bar.dart

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class ReviewActionBar extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onNavigator; // imza korunuyor (ileride lazım olabilir)

  const ReviewActionBar({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onNavigator,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            // ◀ Previous
            TextButton.icon(
              onPressed: onPrev,
              icon: PhosphorIcon(
                PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                'Previous',
                style: AppTextStyles.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
            ),

            const Spacer(),

            // Next ▶
            TextButton.icon(
              onPressed: onNext,
              icon: const SizedBox.shrink(), // ikon label içinde
              label: Row(
                children: [
                  Text(
                    'Next',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  PhosphorIcon(
                    PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
