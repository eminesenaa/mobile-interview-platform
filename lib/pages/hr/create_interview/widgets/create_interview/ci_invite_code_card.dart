// ===================== File: ci_invite_code_card.dart =====================
// Purpose:
// Displays generated invite code (NO generate button)
//
// UX:
// - Label on top
// - Large highlighted code below
// - Code is auto-generated from controller
//
// IMPORTANT:
// - Code must be unique (handled in backend later)
//
// TODO (Backend):
// - Ensure uniqueness before saving
// - Store code in interview document
// - Share with candidates
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/../../../../constants/constants.dart';
import '../../../controllers/create_interview_controller.dart';

class CIInviteCodeCard extends StatelessWidget {
  const CIInviteCodeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateInterviewController>();

    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= LABEL =================
            Text(
              "INVITE CODE",
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ================= CODE =================
            Text(
              controller.inviteCode.value,
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    });
  }
}
