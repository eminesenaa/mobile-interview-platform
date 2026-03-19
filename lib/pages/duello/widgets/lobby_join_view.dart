import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/private_room_controller.dart';

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
    return Column(
      children: [
        const Spacer(),

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
            onChanged: (val) => controller.joinPassword.value = val,
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

        const SizedBox(height: AppSpacing.xxl),

        /// 🚀 JOIN BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                controller.isJoining.value ? null : () => controller.joinRoom(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: controller.isJoining.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "Join Room",
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const Spacer(),
      ],
    );
  }
}
