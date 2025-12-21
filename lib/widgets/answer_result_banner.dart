import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/constants.dart';

/// =======================================================
///  ANSWER RESULT BANNER
/// =======================================================
///
/// Shown AFTER submit, BEFORE AI explanation.
/// - Shows only Correct / Not Quite
/// - Motivational message
/// - Earned XP (shown ONLY if > 0)
/// - Clear "Why?" action
///
class AnswerResultBanner extends StatelessWidget {
  final bool correct;
  final int earnedXp;
  final VoidCallback onWhyPressed;

  const AnswerResultBanner({
    super.key,
    required this.correct,
    required this.earnedXp,
    required this.onWhyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = correct ? AppColors.success : AppColors.error;

    final String titleText = correct ? 'Correct!' : 'Not Quite';

    final String subtitleText = correct
        ? 'Nice work! You nailed this one.'
        : 'Almost there. Let’s see what went wrong.';

    final IconData icon = correct ? Icons.check_circle : Icons.cancel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: accentColor,
          width: 2.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================================================
          // HEADER (ICON + RESULT)
          // ===================================================
          Row(
            children: [
              Icon(icon, color: accentColor, size: 26),
              const SizedBox(width: AppSpacing.sm),
              Text(
                titleText,
                style: AppTextStyles.headline.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ===================================================
          // MOTIVATION TEXT
          // ===================================================
          Text(
            subtitleText,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          // ===================================================
          // XP INFO (ONLY IF > 0)
          // ===================================================
          if (earnedXp > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.star(PhosphorIconsStyle.fill),
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  'You earned $earnedXp XP',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // ===================================================
          // WHY BUTTON (PILL STYLE)
          // ===================================================
          InkWell(
            onTap: onWhyPressed,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: accentColor.withOpacity(0.4),
                  width: 1.6,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Why?',
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
