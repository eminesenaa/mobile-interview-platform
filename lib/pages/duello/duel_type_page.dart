import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/duello/widgets/duel_config_modal.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/colors.dart';
import '../home/home_page.dart';
import 'widgets/duel_mode_card.dart';
import 'private_room_lobby_page.dart';

class DuelTypePage extends StatelessWidget {
  const DuelTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// BACK BUTTON (Gerçek AppBar hizası)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 8),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (Get.key.currentState?.canPop() ?? false) {
                        Get.back();
                      } else {
                        Get.offAll(() => const HomePage());
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// CARDS (padding burada başlıyor)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      /// 1v1
                      DuelModeCard(
                        position: CardPosition.top,
                        title: "1v1",
                        description:
                            "Match with one opponent and start instantly.",
                        icon: PhosphorIcons.userSwitch(),
                        color: AppColors.primary,
                        onTap: () {
                          Get.dialog(
                            DuelConfigModal(modeTitle: "1v1"),
                            barrierColor: Colors.transparent,
                          );
                        },
                      ),

                      /// Multiplayer
                      Transform.translate(
                        offset: const Offset(0, -38),
                        child: DuelModeCard(
                          position: CardPosition.middle,
                          title: "Multiplayer",
                          description:
                              "Play with 3–5 players in a competitive room.",
                          icon: PhosphorIcons.usersThree(),
                          color: AppColors.warning,
                          onTap: () {
                            Get.dialog(
                              DuelConfigModal(modeTitle: "Multiplayer"),
                              barrierColor: Colors.transparent,
                            );
                          },
                        ),
                      ),

                      /// Private Room
                      Transform.translate(
                        offset: const Offset(0, -76),
                        child: DuelModeCard(
                          position: CardPosition.bottom,
                          title: "Private Room",
                          description:
                              "Invite friends and create a custom duel room.",
                          icon: PhosphorIcons.lockKey(),
                          color: AppColors.success,
                          onTap: () {
                            Get.to(() => const PrivateRoomLobbyPage());
                          },
                        ),
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
