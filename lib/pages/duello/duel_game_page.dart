import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/pages/duello/controllers/duel_game_controller.dart';
import 'package:interview_project/pages/duello/widgets/duel_game_layout.dart';
import 'package:interview_project/pages/duello/widgets/duel_progress_track.dart';
import 'package:interview_project/pages/duello/widgets/duel_score_progress_bar.dart';
import 'package:interview_project/pages/duello/widgets/question_renderer.dart';

import '../../models/duel_match.dart';
import '../../models/question.dart';

/// ===============================================================
/// DuelGamePage
/// ---------------------------------------------------------------
/// Responsibilities:
/// - Displays live duel game UI
/// - Listens to realtime match updates via controller
/// - Renders question, timer, players, and progress
///
/// Notes:
/// - Backend logic is fully preserved
/// - Only UI/UX improvements applied
/// - Uses gradient background (same as matchmaking)
/// ===============================================================
class DuelGamePage extends StatelessWidget {
  const DuelGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    /// Initial match data from navigation
    final DuelMatch? initialMatch = Get.arguments as DuelMatch?;

    /// Safety fallback
    if (initialMatch == null) {
      return const Scaffold(
        body: Center(
          child: Text("Match data not found."),
        ),
      );
    }

    /// Inject controller
    final controller = Get.put(
      DuelGameController(initialMatch),
      permanent: false,
    );

    /// Local user ID
    final String localUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'local_user';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryAccent,
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            /// ===============================
            /// LOADING STATE
            /// ===============================
            if (controller.isLoadingQuestions.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading questions...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final currentMatch = controller.match.value;
            final Question? question = currentMatch?.currentQuestion;

            /// ===============================
            /// ERROR STATE
            /// ===============================
            if (currentMatch == null || question == null) {
              return const Center(
                child: Text(
                  'Failed to load questions.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }

            final phase = currentMatch.questionPhase;

            return Column(
              children: [
                /// ===============================
                /// SCORE / PROGRESS BAR
                /// ===============================
                Obx(() {
                  controller.forceUpdate.value; // force rebuild trigger
                  return DuelProgressTrack(
                    players: controller.players.toList(),
                    localUserId: localUserId,
                    totalQuestions: currentMatch.questions.length,
                  );
                }),

                /// ===============================
                /// MAIN GAME LAYOUT
                /// ===============================
                Expanded(
                  child: DuelGameLayout(
                    currentQuestionIndex: currentMatch.currentQuestionIndex,
                    totalQuestions: currentMatch.questions.length,

                    /// FIX: category fallback (critical bug fix)
                    category: _normalizeCategory(currentMatch.category),

                    remainingSeconds: controller.remainingSeconds.value,

                    /// QUESTION + ANSWERS
                    child: QuestionRenderer(
                      question: question,
                      controller: controller,
                      phase: phase,
                      players: controller.players.toList(),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

String _normalizeCategory(String? raw) {
  if (raw == null || raw.isEmpty) return "Mixed";

  final value = raw.toLowerCase();

  if (value.contains("algorithm")) return "Algorithms";
  if (value.contains("data") && value.contains("structure")) return "Algorithms";
  if (value.contains("program")) return "Programming";
  if (value.contains("machine") || value.contains("ai")) return "Data & AI";
  if (value.contains("sql") || value.contains("database")) return "Databases";
  if (value.contains("network") || value.contains("git")) return "Systems";
  if (value.contains("soft")) return "Soft Skills";

  return "Mixed";
}
