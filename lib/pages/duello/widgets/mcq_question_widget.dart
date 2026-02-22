import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/models/duel_enums.dart';
import 'package:interview_project/pages/duello/controllers/duel_game_controller.dart';

class MCQQuestionWidget extends StatelessWidget {
  final Question question;
  final DuelGameController controller;
  final DuelQuestionPhase phase;

  const MCQQuestionWidget({
    super.key,
    required this.question,
    required this.controller,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================
        // QUESTION CARD
        // =========================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.medium,
          ),
          child: Text(
            question.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLarge,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // =========================
        // OPTIONS
        // =========================
        Expanded(
          child: ListView.builder(
            itemCount: question.options?.length ?? 0,
            itemBuilder: (context, index) {
              return _buildOption(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, int index) {
    final match = controller.match.value!;
    final localPlayer =
        match.players.firstWhere((p) => p.userId == 'local_user');

    final selected = localPlayer.selectedOptionIndex == index;

    final int? correctAnswerIndex = question.correctAnswer != null
        ? int.tryParse(question.correctAnswer!)
        : null;

    Color background = AppColors.surface;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.textPrimary;

    if (phase == DuelQuestionPhase.reveal) {
      if (index == correctAnswerIndex) {
        background = AppColors.primarySoftBackground;
        borderColor = AppColors.success;
        textColor = AppColors.success;
      } else if (selected) {
        background = AppColors.surfaceMuted;
        borderColor = AppColors.error;
        textColor = AppColors.error;
      }
    } else if (selected) {
      background = AppColors.primarySoftBackground;
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: phase == DuelQuestionPhase.active
          ? () => controller.selectOption(index)
          : null,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            question.options![index],
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
