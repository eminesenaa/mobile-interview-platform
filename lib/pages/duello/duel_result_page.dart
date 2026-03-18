// lib/pages/duello/duel_result_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/duel_result_controller.dart';
import 'package:interview_project/pages/duello/widgets/duel_result_action_buttons.dart';
import 'package:interview_project/pages/duello/widgets/result_header.dart';
import 'package:interview_project/pages/duello/widgets/result_stats_section.dart';

/// ===============================================================
/// 🎯 DUEL RESULT PAGE (FINAL CLEAN VERSION)
/// ===============================================================
///
/// ✔ Header üstte sabit
/// ✔ Stats ortalanmış
/// ✔ Bottom buttons sabit
/// ✔ Boşluklar dengeli
///
class DuelResultPage extends StatelessWidget {
  const DuelResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DuelResultController());

    return Scaffold(
      body: Container(
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
            /// ⏳ LOADING
            if (controller.isApplyingXp.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Calculating results...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }

            /// 🎮 CONTENT
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  /// 🔥 ÜST + ORTA ALAN
                  Expanded(
                    child: Column(
                      children: [
                        /// HEADER
                        const SizedBox(height: AppSpacing.lg),
                        ResultHeader(controller: controller),

                        /// SPACE (üst)
                        const Spacer(),

                        /// STATS (MERKEZ)
                        ResultStatsSection(controller: controller),

                        /// SPACE (alt)
                        const Spacer(),

                        /// ACTION BUTTONS
                        const DuelResultActionButtons(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
