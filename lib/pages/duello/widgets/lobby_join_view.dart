import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/private_room_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// ===============================================================
/// 🔐 LOBBY JOIN VIEW
/// ===============================================================
///
/// ✔ Room code input
/// ✔ Uppercase + spaced input
/// ✔ Join button
/// ✔ Centered clean layout
///
class LobbyJoinView extends StatelessWidget {
  final PrivateRoomController controller;

  const LobbyJoinView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Transform.translate(
          offset: const Offset(0, -50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🏷 TITLE
              Text(
                "Enter Room Code",
                style: AppTextStyles.bodyStrong.copyWith(
                  fontSize: 18,
                  color: AppColors.textLightPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              /// 🔑 INPUT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                child: TextField(
                  onChanged: (val) {
                    final formatted = val.toUpperCase().trim();
                    controller.joinPassword.value = formatted;

                    if (formatted.length == 6 && !controller.isJoining.value) {
                      controller.joinRoom();
                    }
                  },
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 28,
                    letterSpacing: 6,
                    color: AppColors.textLightPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "XXXXXX",
                    hintStyle: AppTextStyles.displayLarge.copyWith(
                      fontSize: 28,
                      letterSpacing: 6,
                      color: AppColors.textLightPrimary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),

              Obx(() {
                if (!controller.isJoining.value) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Column(
                    children: [
                      LoadingAnimationWidget.discreteCircle(
                        color: Colors.white,
                        size: 36,
                        secondRingColor: Colors.white70,
                        thirdRingColor: Colors.white38,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Joining room...",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
