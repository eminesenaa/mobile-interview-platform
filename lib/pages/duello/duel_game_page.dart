import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/pages/duello/controllers/duel_game_controller.dart';
import 'package:interview_project/pages/duello/widgets/duel_game_layout.dart';
import 'package:interview_project/pages/duello/widgets/duel_score_progress_bar.dart';
import 'package:interview_project/pages/duello/widgets/question_renderer.dart';

import '../../models/duel_match.dart';
import '../../models/question.dart';

class DuelGamePage extends StatelessWidget {
  const DuelGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Argümanı güvenli bir şekilde alıyoruz
    final DuelMatch? initialMatch = Get.arguments as DuelMatch?;

    if (initialMatch == null) {
      return const Scaffold(
        body: Center(child: Text("Maç verisi bulunamadı.")),
      );
    }

    final controller = Get.put(
      DuelGameController(initialMatch),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Obx(() {
          // =============================
          // LOADING STATE
          // =============================
          if (controller.isLoadingQuestions.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Sorular yükleniyor...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final currentMatch = controller.match.value;

          // Match veya Question null ise koruma sağlıyoruz
          final Question? question = currentMatch?.currentQuestion;

          if (currentMatch == null || question == null) {
            return const Center(
              child: Text(
                'Sorular yüklenemedi.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final phase = currentMatch.questionPhase;

          return Column(
            children: [
              // =============================
              // SCORE PROGRESS BAR
              // =============================
              DuelScoreProgressBar(
                players: currentMatch.players,
                // controller içindeki metodu kullanmak daha güvenli
                localUserId:
                    FirebaseAuth.instance.currentUser?.uid ?? 'local_user',
                totalQuestions: currentMatch.questions.length,
              ),

              // =============================
              // GAME LAYOUT
              // =============================
              Expanded(
                child: DuelGameLayout(
                  currentQuestionIndex: currentMatch.currentQuestionIndex,
                  totalQuestions: currentMatch.questions.length,
                  category: question.topic, // Artık question null değil
                  remainingSeconds: controller.remainingSeconds.value,
                  child: QuestionRenderer(
                    question: question, // Artık Question? değil Question
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
}
