// ===================== File: id_dashboard_hero.dart =====================
// Purpose:
// Hero header section for Interview Dashboard
//
// Includes:
// - Small label ("CANDIDATE PORTAL")
// - Big stylized title ("Your Interview Dashboard")
// - Subtitle
//
// Design:
// - Editorial / Apple-style hero
// - Strong typography hierarchy
// - Clean spacing
//
// Usage:
// Placed under AppBar and above StatsRow
// ========================================================================

import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';

class IdDashboardHero extends StatelessWidget {
  const IdDashboardHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= LABEL =================
        Text(
          "CANDIDATE PORTAL",
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ================= TITLE =================
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Your  ",
                style: AppTextStyles.displayLarge.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: "Interview",
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: "\n"),
              TextSpan(
                text: "Dashboard",
                style: AppTextStyles.displayLarge.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ================= SUBTITLE =================
        Text(
          "Apply, track, and join your interviews in one place.",
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}
