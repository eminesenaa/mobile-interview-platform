import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_result.dart';

import '../../home/home_page.dart';
import '../duel_type_page.dart';

class DuelResultActionButtons extends StatelessWidget {
  const DuelResultActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Play Again
        ElevatedButton(
          onPressed: () {
            Get.offAll(() => const DuelTypePage());
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

        // Home
        OutlinedButton(
          onPressed: () {
            Get.offAll(() => const HomePage());
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
