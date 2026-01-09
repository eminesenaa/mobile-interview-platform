// lib/widgets/review_ai_explanation_dialog.dart

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class ReviewAiExplanationDialog extends StatelessWidget {
  final Future<String> explanationFuture;
  final Future<String?>? correctAnswerFuture;

  const ReviewAiExplanationDialog({
    super.key,
    required this.explanationFuture,
    this.correctAnswerFuture,
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
        constraints: const BoxConstraints(
          maxWidth: 520,
          maxHeight: 520,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================
            // HEADER (Sadece "Explanation")
            // ===================================================
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
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
                      size: 20,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Correct Answer (varsa)
                    if (correctAnswerFuture != null)
                      FutureBuilder<String?>(
                        future: correctAnswerFuture,
                        builder: (context, snap) {
                          final txt = (snap.data ?? '').trim();
                          if (txt.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Correct Answer',
                                style: AppTextStyles.bodyStrong.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),

                              // 🔧 Renk alttaki explanation ile AYNI
                              Text(
                                txt,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),
                              Divider(color: AppColors.border),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          );
                        },
                      ),

                    // 🔹 Explanation body
                    Expanded(
                      child: FutureBuilder<String>(
                        future: explanationFuture,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (snap.hasError) {
                            return Text(
                              'Failed to load explanation. Please try again.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.error,
                              ),
                            );
                          }

                          final text = (snap.data ?? '').trim();
                          if (text.isEmpty) {
                            return Text(
                              'No explanation available for this question.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            child: Text(
                              text,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
