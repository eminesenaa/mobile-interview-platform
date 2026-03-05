// lib/pages/duello/duel_result_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/duel_result_controller.dart';
import 'package:interview_project/pages/duello/widgets/duel_result_action_buttons.dart';

class DuelResultPage extends StatelessWidget {
  const DuelResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DuelResultController());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Obx(() {
          if (controller.isApplyingXp.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Calculating results...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── EMOJİ ──
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.elasticOut,
                        builder: (_, v, child) =>
                            Transform.scale(scale: v, child: child),
                        child: Text(
                          controller.isWinner ? '🏆' : '😤',
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── KİŞİSEL MESAJ ──
                      Text(
                        controller.personalMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── SCORE ──
                      _ResultCard(
                        icon: '⭐',
                        label: 'Score',
                        value: controller.myScore.toString(),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── XP ──
                      _ResultCard(
                        icon: '✨',
                        label: 'XP Earned',
                        value: '+${controller.myXp} XP',
                        highlight: true,
                        trailing: controller.xpApplyError.value
                            ? GestureDetector(
                                onTap: controller.retryApplyXp,
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── ACCURACY ──
                      _ResultCard(
                        icon: '🎯',
                        label: 'Accuracy',
                        value:
                            '%${controller.myAccuracyPercent.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── COMBO ──
                      _ResultCard(
                        icon: '🔥',
                        label: 'Best Combo',
                        value: controller.myCombo > 0
                            ? '${controller.myCombo}×'
                            : '—',
                      ),
                    ],
                  ),
                ),

                // ── BUTONLAR ──
                const DuelResultActionButtons(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool highlight;
  final Widget? trailing;

  const _ResultCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(highlight ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: highlight
            ? Border.all(color: Colors.white.withOpacity(0.45), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          trailing ??
              Text(
                value,
                style: AppTextStyles.bodyStrong.copyWith(
                  fontSize: highlight ? 20 : 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
        ],
      ),
    );
  }
}
