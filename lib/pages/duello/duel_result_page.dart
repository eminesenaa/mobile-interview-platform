import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_result.dart';
import 'package:interview_project/pages/duello/widgets/duel_result_action_buttons.dart';

class DuelResultPage extends StatelessWidget {
  const DuelResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Şimdilik sadece argument alıyoruz ama kullanmıyoruz
    final DuelResult result = Get.arguments as DuelResult;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // ============================
              // CENTER CONTENT
              // ============================
              const Expanded(
                child: Center(
                  child: Text(
                    "Result Page\nComing Soon",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLightPrimary,
                    ),
                  ),
                ),
              ),

              // ============================
              // ACTION BUTTONS
              // ============================
              const DuelResultActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
