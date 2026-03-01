import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/constants.dart';

import '../duel_type_page.dart';

class DuelResultActionButtons extends StatelessWidget {
  const DuelResultActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── PLAY AGAIN ──
        ElevatedButton(
          onPressed: () {
            // Duel stack'ini temizle, DuelTypePage'e git
            // offAll yerine until + to kullanıyoruz — navbar korunur
            Get.until((route) => route.isFirst);
            Get.to(() => const DuelTypePage());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            "Play Again",
            style: AppTextStyles.button,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── HOME ──
        OutlinedButton(
          onPressed: () {
            // Root'a kadar geri dön — shell ve navbar sağlam kalır
            Get.until((route) => route.isFirst);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: AppColors.surface),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            "Home",
            style: AppTextStyles.textButton.copyWith(
              color: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }
}
