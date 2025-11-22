import 'package:flutter/material.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/text_styles.dart';

import '../../../models/question.dart';
import '../../question_types/question_navigator.dart';

class PopularQuestionCard extends StatelessWidget {
  final Question question;
  final double? width;
  final EdgeInsets padding;

  /// Dikey listelerde varsayılan kullanım
  const PopularQuestionCard({
    super.key,
    required this.question,
    this.width,
    this.padding = const EdgeInsets.all(16),
  });

  /// Yatay (horizontal) listeye uygun kısa yol
  const PopularQuestionCard.horizontal({
    super.key,
    required this.question,
    required double this.width,
  }) : padding = const EdgeInsets.fromLTRB(16, 14, 16, 14);

  void _openQuestion() => QuestionNavigator.open(question);

  @override
  Widget build(BuildContext context) {
    final Color strokeColor = _difficultyStrokeColor(question.difficulty);

    return SizedBox(
      width: width,
      child: Card(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: AppColors.shadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _openQuestion,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: strokeColor,
                width: 4.2, // bir tık daha kalın kenar
              ),
            ),
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DifficultyHeader(difficulty: question.difficulty),

                  // Title + Tags ortalansın diye Expanded içinde Center
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      // dikey ortalı, soldan hizalı
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            question.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppTextStyles.bodyStrong.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ), // title
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _Chip(
                                icon: Icons.category_outlined,
                                label: question.topic ?? '—',
                              ),
                              _Chip(
                                icon: _typeIcon(question.type),
                                label: _typeLabel(question.type),
                              ),
                            ],
                          ), // tags
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========= Helpers =========

  static Color _difficultyStrokeColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.easy_medium:
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.medium_hard:
      case Difficulty.hard:
        return AppColors.error;
    }
  }

  static IconData _typeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.coding:
        return Icons.code;
      case QuestionType.mcq:
        return Icons.list_alt;
      case QuestionType.fillBlank:
        return Icons.space_bar;
      case QuestionType.shortAnswer:
        return Icons.chat_bubble_outline;
      default:
        return Icons.help_outline;
    }
  }

  static String _typeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.coding:
        return 'Coding';
      case QuestionType.mcq:
        return 'MCQ';
      case QuestionType.fillBlank:
        return 'Fill-in-Blanks';
      case QuestionType.shortAnswer:
        return 'Short Answer';
      default:
        return 'Question';
    }
  }
}

/// Üstteki “Easy / Medium / Hard” chip’i
class _DifficultyHeader extends StatelessWidget {
  final Difficulty difficulty;

  const _DifficultyHeader({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final Color base = PopularQuestionCard._difficultyStrokeColor(difficulty);
    final Color bg = base.withOpacity(0.10);
    final Color fg = base.withOpacity(0.95);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lightbulb_outline, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            _difficultyLabel(difficulty),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static String _difficultyLabel(Difficulty d) {
    switch (d) {
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
}

/// Alt tagler için genel chip
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
