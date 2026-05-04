// ===================== File: hr_question_select_card.dart =====================
// Purpose:
// Question card for HR "Select from Database"
//
// Features:
// - SAME UI as QuestionCard
// - NO navigation / NO solve
// - Selection-based interaction
// - Clean reusable structure
//
// Differences from QuestionCard:
// - Right side = selection circle (not bookmark)
// - Tap = toggle selection
// - No LibraryController dependency
// ============================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '/../../../../constants/constants.dart';
import '/../../../../models/question.dart';

class HrQuestionSelectCard extends StatelessWidget {
  const HrQuestionSelectCard({
    super.key,
    required this.question,
    required this.isSelected,
    required this.onTap,
  });

  final Question question;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs / 3,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),

            // ===============================
            // CARD DECORATION (same as practice)
            // ===============================
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),

              // 🔥 Selected state
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),

              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 14,
                        spreadRadius: 1,
                      )
                    ]
                  : AppShadows.medium,
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ===============================
                // LEFT SIDE (CONTENT)
                // ===============================
                Expanded(
                  child: _CardBody(question: question),
                ),

                const SizedBox(width: AppSpacing.sm),

                // ===============================
                // RIGHT SIDE (SELECTION ICON)
                // ===============================
                _SelectionIndicator(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// ===================== CARD BODY (REUSED STRUCTURE) =====================
//

class _CardBody extends StatelessWidget {
  const _CardBody({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================
        // TITLE
        // ===============================
        Text(
          question.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyStrong.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // ===============================
        // DIFFICULTY + TOPIC
        // ===============================
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (question.difficulty != null)
              _DifficultyPill(difficulty: question.difficulty!),
            if (question.difficulty != null)
              const SizedBox(width: AppSpacing.sm),
            if (question.topic != null && question.topic!.isNotEmpty)
              Text(
                question.topic!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

//
// ===================== SELECTION INDICATOR =====================
//

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      child: isSelected
          ? Icon(
              PhosphorIcons.check(PhosphorIconsStyle.bold),
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }
}

//
// ===================== DIFFICULTY PILL =====================
//

class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final Color color = _difficultyColor(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        _difficultyLabel(difficulty),
        style: AppTextStyles.chip.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _difficultyColor(Difficulty d) {
    final name = d.name.toLowerCase();

    if (name.contains('easy') && !name.contains('hard')) {
      return AppColors.difficultyEasy;
    }
    if (name.contains('easy') && name.contains('medium')) {
      return AppColors.difficultyEasyMedium;
    }
    if (name.contains('medium') &&
        !name.contains('easy') &&
        !name.contains('hard')) {
      return AppColors.difficultyMedium;
    }
    if (name.contains('medium') && name.contains('hard')) {
      return AppColors.difficultyMediumHard;
    }
    if (name.contains('hard') && !name.contains('easy')) {
      return AppColors.difficultyHard;
    }

    return AppColors.primary;
  }

  String _difficultyLabel(Difficulty d) {
    return d.name.toUpperCase().replaceAll('_', ' ');
  }
}
