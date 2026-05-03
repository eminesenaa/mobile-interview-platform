// ===================== File: np_interview_card.dart =====================
// Purpose:
// Premium Interview Entry Card (Profile Page)
//
// Features:
// - Dark gradient background (like dashboard)
// - Full-bleed decorative circles
// - Icon bubble
// - Clean hierarchy
// - Tap to navigate
//
// Notes:
// - Simplified version of dashboard card (no input / button)
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class NpInterviewCard extends StatelessWidget {
  final int upcoming;
  final int completed;
  final VoidCallback onTap;

  const NpInterviewCard({
    super.key,
    required this.upcoming,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F172A),
                Color(0xFF020617),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // ================= DECORATIVE SHAPES =================
              Positioned(
                top: -40,
                right: -40,
                child: _circle(140),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: _circle(90),
              ),

              // ================= CONTENT =================
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // ================= ICON BUBBLE =================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.textLightPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        PhosphorIcons.briefcase(),
                        color: AppColors.textLightPrimary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // ================= TEXT =================
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Interviews",
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.textLightPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$upcoming upcoming · $completed completed",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textLightPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= ARROW =================
                    Icon(
                      PhosphorIcons.caretRight(),
                      color: AppColors.textLightPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DECORATIVE CIRCLE =================
  Widget _circle(double size) {
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
