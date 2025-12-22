import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';

class RunnerBottomBar extends StatelessWidget {
  const RunnerBottomBar({
    super.key,
    required this.hasPrev,
    required this.hasNext,
    required this.isSubmitting,
    required this.canSubmit,
    required this.onPrev,
    required this.onSubmit,
    required this.onNext,
    required this.onFinish,
    this.submitLabel = 'Send',
    this.submitBlocked = false,
  });

  // Navigation state
  final bool hasPrev;
  final bool hasNext;

  // Submit state
  final bool isSubmitting;
  final bool canSubmit;
  final bool submitBlocked;

  // Actions
  final VoidCallback onPrev;
  final VoidCallback onSubmit; // 🔑 artık Send / Continue / Try Again hepsi buradan
  final VoidCallback onNext;
  final VoidCallback onFinish;

  // UI
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    final bool primaryEnabled =
        canSubmit && !isSubmitting && !submitBlocked;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===================================================
            // PREVIOUS | NEXT
            // ===================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ---------- Previous ----------
                TextButton(
                  onPressed: (hasPrev && !isSubmitting) ? onPrev : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.chevron_left),
                      SizedBox(width: 4),
                      Text('Previous'),
                    ],
                  ),
                ),

                // ---------- Next ----------
                TextButton(
                  onPressed:
                  (hasNext && !isSubmitting) ? onNext : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Next'),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ===================================================
            // PRIMARY ACTION BUTTON
            // Send / Continue / Try Again
            // ===================================================
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: primaryEnabled ? onSubmit : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                  AppColors.primary.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
                child: isSubmitting
                    ? LoadingAnimationWidget.waveDots(
                  color: Colors.white,
                  size: 20,
                )
                    : Text(
                  submitLabel,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: Colors.white,
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
