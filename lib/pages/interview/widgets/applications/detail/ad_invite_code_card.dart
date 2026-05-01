// ===================== File: ad_invite_code_card.dart =====================
// Purpose:
// Displays interview invite code with copy action (FLAT CLEAN VERSION)
//
// Design:
// - No background container
// - Minimal & premium
// - Strong typography hierarchy
// - Clean CTA button
// ========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class AdInviteCodeCard extends StatelessWidget {
  final String code;

  const AdInviteCodeCard({
    super.key,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ================= HEADER =================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.key(PhosphorIconsStyle.bold),
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              "INTERVIEW CODE",
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                letterSpacing: 1,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ================= CODE =================
        Text(
          code,
          style: AppTextStyles.displayLarge.copyWith(
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ================= DESCRIPTION =================
        Text(
          "Use this code to join your scheduled interview session",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ================= CLEAN BUTTON =================
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: code));

            Get.snackbar(
              "Copied",
              "Interview code copied successfully",
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.surfaceMuted.withOpacity(0.9),
              colorText: AppColors.textPrimary,
              margin: const EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.lg,
              barBlur: 12,
              boxShadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                ),
              ],
              icon: Icon(
                PhosphorIcons.checkCircle(),
                color: AppColors.success,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.copy(),
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  "Copy Code",
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
