import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/widgets/duel_category_card.dart';
import 'package:interview_project/utils/duel_category_style.dart';

class DuelGameLayout extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final String category;
  final int remainingSeconds;
  final Widget child;

  const DuelGameLayout({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.category,
    required this.remainingSeconds,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
    totalQuestions == 0 ? 0 : (currentQuestionIndex + 1) / totalQuestions;

    return Container(
      color: AppColors.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),

              // =============================
              // TOP BAR
              // =============================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Question Counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoftBackground,
                      borderRadius:
                      BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      "${currentQuestionIndex + 1}/$totalQuestions",
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Category Card (hazır widget)
                  DuelCategoryCard(
                    title: category,
                    color: DuelCategoryStyle.getColor(category),
                    isSelected: true,
                    size: 48, // Daha dengeli boyut
                  ),

                  const Spacer(),

                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                      BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      "${remainingSeconds}s",
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // =============================
              // QUESTION AREA
              // =============================
              Expanded(child: child),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}