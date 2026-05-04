// ===================== File: hp_duel_card.dart =====================
// Purpose:
// Premium Duel Card (Home Page)
//
// Design:
// - Dark gradient background (inspired by InterviewCard)
// - Subtle decorative circles
// - Clean hierarchy
// - Strong CTA
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../constants/constants.dart';

class HpDuelCard extends StatelessWidget {
  final VoidCallback onTap;

  const HpDuelCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [
            AppColors.topicDeepTwilight,
            AppColors.topicBrightTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      // 🔥 IMPORTANT: clip for shapes
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            // ================= DECORATIVE SHAPES =================
            Positioned(
              top: -30,
              right: -30,
              child: _circleDecoration(120),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: _circleDecoration(80),
            ),

            // ================= CONTENT =================
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // ================= LEFT =================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 LABEL
                        Text(
                          "1V1 • MULTIPLAYER • PRIVATE ROOM",
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textLightPrimary.withOpacity(0.6),
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // 🔹 TITLE
                        Text(
                          "Duel Arena",
                          style: AppTextStyles.headline.copyWith(
                            color: AppColors.textLightPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // 🔹 DESCRIPTION
                        Text(
                          "Challenge someone. Prove your edge.",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // 🔹 CTA
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.topicDeepTwilight,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Start",
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.textLightPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  PhosphorIcons.arrowRight(
                                      PhosphorIconsStyle.bold),
                                  size: 16,
                                  color: AppColors.textLightPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // ================= RIGHT ICON =================
                  Opacity(
                    opacity: 0.2,
                    child: Icon(
                      PhosphorIcons.sword(),
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DECORATIVE CIRCLE =================
  Widget _circleDecoration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }
}
