// lib/pages/duello/duel_result_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';

import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/duel_result_controller.dart';
import 'package:interview_project/pages/duello/widgets/duel_result_action_buttons.dart';
import 'package:interview_project/pages/duello/widgets/result_header.dart';
import 'package:interview_project/pages/duello/widgets/result_stats_section.dart';
import 'package:interview_project/pages/duello/widgets/result_podium.dart';
import 'package:interview_project/pages/duello/widgets/leaderboard_list.dart';
import 'package:interview_project/pages/duello/widgets/result_summary.dart';

class DuelResultPage extends StatelessWidget {
  const DuelResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DuelResultController());

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
            /// ⏳ LOADING
            if (controller.isApplyingXp.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Calculating widgets...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }

            final players = controller.result.players;

            return Stack(
              children: [
                /// CONTENT
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Expanded(
                        child: players.length == 2
                            ? _buildOneVsOne(controller)
                            : _buildMulti(controller),
                      ),
                    ],
                  ),
                ),

                /// CONFETTI (winner only)
                if (controller.isWinner)
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: controller.confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      emissionFrequency: 0.04,
                      numberOfParticles: 30,
                      gravity: 0.2,
                      colors: const [
                        Colors.white,
                        AppColors.primaryAccent,
                        AppColors.primary,
                        AppColors.accentSpicyOrange,
                        AppColors.honeyBronze,
                      ],
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// ===============================================================
  /// 🎯 1v1 RESULT LAYOUT
  /// ===============================================================
  Widget _buildOneVsOne(DuelResultController controller) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),

        /// HEADER
        ResultHeader(controller: controller),

        const Spacer(),

        /// STATS
        ResultStatsSection(controller: controller),

        const Spacer(),

        /// ACTIONS
        const DuelResultActionButtons(),
      ],
    );
  }

  /// ===============================================================
  /// 🏆 MULTI RESULT LAYOUT (3+ players)
  /// ===============================================================
  Widget _buildMulti(DuelResultController controller) {
    final players = controller.result.players;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),

        /// 🥇 PODIUM
        ResultPodium(players: players),

        const SizedBox(height: AppSpacing.xl),

        /// 📊 LEADERBOARD
        Expanded(
          child: SingleChildScrollView(
            child: LeaderboardList(
              players: players,
              localUserId: controller.localUserId,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        ResultSummary(
          rank: controller.myRank,
          message: controller.personalMessage,
          xp: controller.myXp,
          combo: controller.myCombo,
        ),

        const SizedBox(height: AppSpacing.xl),

        /// 🔘 ACTIONS
        const DuelResultActionButtons(),
      ],
    );
  }
}
