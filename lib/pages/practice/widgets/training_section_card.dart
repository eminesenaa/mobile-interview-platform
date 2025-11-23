// ===================== File: lib/pages/practice/widgets/training_section_card.dart =====================
// Purpose: Training module içindeki tek bir section'ı ve o section'a bağlı
//          soru listesini gösteren kart widget.
// UI notları:
// - Section başlığı üstte, isteğe bağlı kısa açıklama altında.
// - Altında numaralandırılmış soru satırları.
// - Section kendi başına tıklanmaz; sadece soru satırı tıklanabilir.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/models/training_section.dart';

class TrainingSectionCard extends StatelessWidget {
  final TrainingSection section;
  final List<Question> questions;

  /// Soruya tıklanınca tetiklenecek callback.
  final ValueChanged<Question>? onQuestionTap;

  const TrainingSectionCard({
    super.key,
    required this.section,
    required this.questions,
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border, // subtle border
          width: 1,
        ),
        boxShadow: AppShadows.low,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            section.title,
            style: AppTextStyles.bodyStrong,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Optional description
          if (section.description != null &&
              section.description!.trim().isNotEmpty) ...[
            Text(
              section.description!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          if (questions.isNotEmpty)
            const Divider(
              height: AppSpacing.lg,
              thickness: 1,
              color: AppColors.border,
            ),

          // Question rows
          for (int i = 0; i < questions.length; i++) ...[
            _SectionQuestionRow(
              index: i,
              question: questions[i],
              onTap: onQuestionTap == null
                  ? null
                  : () => onQuestionTap!(questions[i]),
            ),
            if (i != questions.length - 1)
              const Divider(
                height: AppSpacing.md,
                thickness: 0.6,
                color: AppColors.border,
              ),
          ],

          if (questions.isEmpty)
            Text(
              'No questions added yet.',
              style: AppTextStyles.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _SectionQuestionRow extends StatelessWidget {
  final int index;
  final Question question;
  final VoidCallback? onTap;

  const _SectionQuestionRow({
    required this.index,
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final diffLabel = _difficultyLabel(question.difficulty);
    final diffColor = _difficultyColor(question.difficulty);
    final isCompleted = question.status == Status.solved;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Leading numbered circle
            // Leading status circle (index veya tik)
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: isCompleted ? AppColors.primary : Colors.transparent,
                border: isCompleted
                    ? null
                    : Border.all(
                        color: AppColors.borderStrong,
                        width: 1.2,
                      ),
              ),
              alignment: Alignment.center,
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
                      '${index + 1}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Question title
            Expanded(
              child: Text(
                question.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong,
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Difficulty label
            if (diffLabel.isNotEmpty)
              Text(
                diffLabel,
                style: AppTextStyles.label.copyWith(
                  color: diffColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _difficultyLabel(Difficulty diff) {
    switch (diff) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.easy_medium:
        return 'Easy-Med';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.medium_hard:
        return 'Med-Hard';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  static Color _difficultyColor(Difficulty diff) {
    switch (diff) {
      case Difficulty.easy:
        return AppColors.difficultyEasy;
      case Difficulty.easy_medium:
        return AppColors.difficultyEasyMedium;
      case Difficulty.medium:
        return AppColors.difficultyMedium;
      case Difficulty.medium_hard:
        return AppColors.difficultyMediumHard;
      case Difficulty.hard:
        return AppColors.difficultyHard;
    }
  }
}
