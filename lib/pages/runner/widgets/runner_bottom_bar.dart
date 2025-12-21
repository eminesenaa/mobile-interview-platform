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

  final bool hasPrev;
  final bool hasNext;
  final bool isSubmitting;
  final bool canSubmit;

  final VoidCallback onPrev;
  final VoidCallback onSubmit;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  final String submitLabel;
  final bool submitBlocked;

  @override
  Widget build(BuildContext context) {
    final bool sendEnabled = canSubmit && !isSubmitting && !submitBlocked;

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
            // PREVIOUS | NEXT / FINISH
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

                // ---------- Next / Finish ----------
                TextButton(
                  onPressed:
                      !isSubmitting ? (hasNext ? onNext : onFinish) : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(hasNext ? 'Next' : 'Finish'),
                      const SizedBox(width: 4),
                      Icon(hasNext ? Icons.chevron_right : Icons.check),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ===================================================
            // SEND BUTTON (NO LOADING SPINNER)
            // ===================================================
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: sendEnabled ? onSubmit : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
                child: isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.waveDots(
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
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
