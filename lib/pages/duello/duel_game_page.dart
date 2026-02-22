import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/text_styles.dart';
import 'package:interview_project/pages/duello/controllers/duel_game_controller.dart';
import 'package:interview_project/pages/duello/widgets/duel_category_card.dart';
import 'package:interview_project/pages/duello/widgets/duel_game_layout.dart';
import 'package:interview_project/pages/duello/widgets/duel_score_progress_bar.dart';
import 'package:interview_project/pages/duello/widgets/question_renderer.dart';
import 'package:interview_project/utils/duel_category_style.dart';

import '../../models/duel_match.dart';
import '../../models/duel_enums.dart';

class DuelGamePage extends StatelessWidget {
  const DuelGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DuelMatch match = Get.arguments as DuelMatch;

    final controller = Get.put(
      DuelGameController(match),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Obx(() {
          final currentMatch = controller.match.value!;
          final question = currentMatch.currentQuestion;
          final phase = currentMatch.questionPhase;

          return Column(
            children: [
              // =============================
              // SCORE PROGRESS BAR
              // =============================
              DuelScoreProgressBar(
                players: currentMatch.players,
                localUserId: 'local_user',
                totalQuestions: currentMatch.questions.length,
              ),

              // =============================
              // GAME LAYOUT
              // =============================
              Expanded(
                child: DuelGameLayout(
                  currentQuestionIndex: currentMatch.currentQuestionIndex,
                  totalQuestions: currentMatch.questions.length,
                  category: question.topic,
                  remainingSeconds: controller.remainingSeconds.value,
                  child: QuestionRenderer(
                    question: question,
                    controller: controller,
                    phase: phase,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOption({
    required DuelGameController controller,
    required DuelMatch match,
    required String optionText,
    required int index,
    required DuelQuestionPhase phase,
    required int? correctAnswer,
  }) {
    final localPlayer =
        match.players.firstWhere((p) => p.userId == 'local_user');

    final selected = localPlayer.selectedOptionIndex == index;

    Color background = Colors.white;

    if (phase == DuelQuestionPhase.reveal) {
      if (index == correctAnswer) {
        background = Colors.green;
      } else if (selected) {
        background = Colors.red;
      }
    } else if (selected) {
      background = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: phase == DuelQuestionPhase.active
          ? () => controller.selectOption(index)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            optionText,
            style: AppTextStyles.title,
          ),
        ),
      ),
    );
  }
}
