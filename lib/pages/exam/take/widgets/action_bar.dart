// lib/pages/exam/take/widgets/action_bar.dart

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class ActionBar extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final VoidCallback onNavigator; // imza korunuyor

  const ActionBar({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onSubmit,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===================================================
            // PREVIOUS / NEXT
            // ===================================================
            Row(
              children: [
                // ◀ Previous
                TextButton.icon(
                  onPressed: onPrev,
                  icon: PhosphorIcon(
                    PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
                    size: 16,
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

                // Next ▶  (TEXT → ICON)
                TextButton.icon(
                  onPressed: onNext,
                  icon: const SizedBox.shrink(), // icon sonra gelecek
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

            const SizedBox(height: AppSpacing.xs),

            // ===================================================
            // SUBMIT
            // ===================================================
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLightPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
