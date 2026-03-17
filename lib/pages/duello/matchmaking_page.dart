import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/text_styles.dart';

import 'package:interview_project/pages/duello/widgets/duel_category_card.dart';
import 'package:interview_project/pages/duello/widgets/duel_players_layout.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../models/duel_config.dart';
import '../../models/duel_enums.dart';
import '../../utils/duel_category_style.dart';
import 'controllers/matchmaking_controller.dart';

/// ===============================================================
/// MatchmakingPage (FINAL CLEAN VERSION)
/// ---------------------------------------------------------------
/// 1. Top → Category + Player Count
/// 2. Center → Avatars
/// 3. Bottom → Searching
/// ===============================================================
class MatchmakingPage extends StatelessWidget {
  final DuelConfig config;

  const MatchmakingPage({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      MatchmakingController(config),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// ===============================
        /// BACKGROUND
        /// ===============================
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

            /// 🔥 BUG FIX → minimum 1 player göster
            final rawCount = match?.players.length ?? 0;
            final playerCount = rawCount == 0 ? 1 : rawCount;

            final lobbySeconds = controller.lobbyCountdownSeconds.value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  /// ===================================================
                  /// 🔝 TOP → CATEGORY + PLAYER COUNT
                  /// ===================================================
                  const SizedBox(height: AppSpacing.xxl),

                  Column(
                    children: [
                      DuelCategoryCard(
                        title: config.category,
                        color: DuelCategoryStyle.getColor(config.category),
                        isSelected: true,
                        size: 72,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        config.category,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textLightPrimary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      /// 🔥 ÜST AYIRAÇ (daha kalın + belirgin)
                      Container(
                        width: 75,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      /// 🔥 ÜST AYIRAÇ (daha kalın + belirgin)
                      Container(
                        width: 100,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        "$playerCount ${playerCount == 1 ? "player" : "players"} joined.",
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textLightPrimary.withOpacity(0.95),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      /// 🔥 ALT AYIRAÇ (aynı stil)
                      Container(
                        width: 100,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Container(
                        width: 75,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),

                  /// ===================================================
                  /// 🎯 CENTER → AVATARS
                  /// ===================================================
                  Expanded(
                    child: Center(
                      child: match != null
                          ? DuelPlayersLayout(match: match)
                          : const SizedBox(),
                    ),
                  ),

                  /// ===================================================
                  /// 🔻 BOTTOM → SEARCHING
                  /// ===================================================
                  Column(
                    children: [
                      if (status == DuelStatus.searching)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Searching for an opponent",
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.textLightPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            LoadingAnimationWidget.waveDots(
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        )
                      else
                        Text(
                          _statusText(status, playerCount, lobbySeconds),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline.copyWith(
                            color: AppColors.textLightPrimary,
                          ),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      /// countdown
                      if (status == DuelStatus.lobbyCountdown)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 3,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$lobbySeconds',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  /// ===============================================================
  /// STATUS TEXT
  /// ===============================================================
  String _statusText(DuelStatus status, int count, int lobbySeconds) {
    switch (status) {
      case DuelStatus.searching:
        return "$count players joined\nSearching for an opponent...";
      case DuelStatus.matched:
        return "Match Found!";
      case DuelStatus.countdown:
        return "Game Starting...";
      case DuelStatus.lobbyCountdown:
        return "$count players joined\nGame starts in ${lobbySeconds}s";
      default:
        return "";
    }
  }
}
