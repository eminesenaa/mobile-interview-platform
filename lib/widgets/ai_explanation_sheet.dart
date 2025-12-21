import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/constants.dart';

/// =======================================================
///  AI EXPLANATION SHEET (CENTER MODAL)
/// =======================================================
///
/// Shown when user taps "Why?"
/// - Centered modal
/// - No bottom button
/// - Premium, focused explanation panel
///
class AiExplanationSheet extends StatelessWidget {
  final String explanation;

  const AiExplanationSheet({
    super.key,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================
            // HEADER (AI ACCENT)
            // ===================================================
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                color: AppColors.primary.withOpacity(0.06),
              ),
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.lightbulb(PhosphorIconsStyle.bold),
                    size: 22,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Explanation',
                      style: AppTextStyles.headline.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: PhosphorIcon(
                      PhosphorIcons.x(PhosphorIconsStyle.bold),
                      size: 21,
                      color: AppColors.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ===================================================
            // CONTENT
            // ===================================================
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                explanation,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
