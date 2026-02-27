import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/text_styles.dart';
import 'package:interview_project/pages/duello/widgets/duel_category_card.dart';
import 'package:interview_project/pages/duello/widgets/duel_players_layout.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../constants/constants.dart';
import '../../models/duel_config.dart';
import '../../models/duel_enums.dart';
import '../../utils/duel_category_style.dart';
import 'controllers/matchmaking_controller.dart';

class MatchmakingPage extends StatelessWidget {
  final DuelConfig config;

  const MatchmakingPage({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    /// Controller yalnızca bir kere oluşturulur
    final controller = Get.put(
      MatchmakingController(config),
      permanent: false,
    );

    return Scaffold(
      /// Scaffold background şeffaf yapıyoruz
      backgroundColor: Colors.transparent,

      body: SizedBox.expand(
        child: Container(
          /// Fullscreen gradient garanti
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
              final match = controller.match.value;
              final status = controller.status.value;
              final playerCount = match?.players.length ?? 0;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      // ===============================
                      // CATEGORY CARD (TOP CENTER)
                      // ===============================
                      DuelCategoryCard(
                        title: config.category,
                        color: DuelCategoryStyle.getColor(config.category),
                        isSelected: true,
                        size: 80,
                      ),

                      const SizedBox(height: 80),

                      // ===============================
                      // PLAYERS AVATARS
                      // ===============================
                      if (match != null) DuelPlayersLayout(match: match),

                      const SizedBox(height: 70),

                      // ===============================
                      // STATUS TEXT
                      // ===============================
                      Text(
                        _statusText(status, playerCount),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ===============================
                      // LOADER
                      // ===============================
                      if (status == DuelStatus.searching)
                        LoadingAnimationWidget.discreteCircle(
                          color: Colors.white,
                          size: 56,
                          secondRingColor: Colors.white.withValues(alpha: 0.6),
                          thirdRingColor: Colors.white.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Status mesajı üretir
  String _statusText(DuelStatus status, int count) {
    switch (status) {
      case DuelStatus.searching:
        return "$count players joined\nSearching...";
      case DuelStatus.matched:
        return "Match Found!";
      case DuelStatus.countdown:
        return "Game Starting...";
      default:
        return "";
    }
  }
}
