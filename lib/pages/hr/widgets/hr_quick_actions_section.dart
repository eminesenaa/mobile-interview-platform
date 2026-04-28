// ===================== File: hr_quick_actions_section.dart =====================
// Purpose:
// Displays "Quick Actions" section in HR Dashboard (UPDATED)
//
// Improvements:
// - Section title is now muted (like design)
// - Uses Phosphor icons
// - Clean spacing & layout
// - Fully compatible with updated HRActionCard
// ===============================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import 'hr_action_card.dart';

class HRQuickActionsSection extends StatelessWidget {
  final VoidCallback onManagePostings;
  final VoidCallback onCreateInterview;
  final VoidCallback onViewInterviews;
  final VoidCallback onViewResults;

  const HRQuickActionsSection({
    super.key,
    required this.onManagePostings,
    required this.onCreateInterview,
    required this.onViewInterviews,
    required this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================
        // SECTION TITLE (MUTED)
        // ===============================
        Text(
          "QUICK ACTIONS",
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ===============================
        // JOB POSTINGS
        // ===============================
        HRActionCard(
          title: "Job Postings",
          subtitle: "Create & manage job applications",
          icon: PhosphorIcons.briefcase(),
          accentColor: AppColors.topicBrightTeal,
          onTap: onManagePostings,
        ),

        const SizedBox(height: AppSpacing.sm),

        // ===============================
        // CREATE INTERVIEW
        // ===============================
        HRActionCard(
          title: "Create Interview",
          subtitle: "Set up a new interview session",
          icon: PhosphorIcons.plus(),
          accentColor: AppColors.strawberryRed,
          onTap: onCreateInterview,
        ),

        const SizedBox(height: AppSpacing.sm),

        // ===============================
        // VIEW INTERVIEWS
        // ===============================
        HRActionCard(
          title: "View Interviews",
          subtitle: "Manage scheduled sessions",
          icon: PhosphorIcons.monitor(),
          accentColor: AppColors.darkMagenta,
          onTap: onViewInterviews,
        ),

        const SizedBox(height: AppSpacing.sm),

        // ===============================
        // VIEW RESULTS
        // ===============================
        HRActionCard(
          title: "Results",
          subtitle: "Review completed interviews",
          icon: PhosphorIcons.chartBar(),
          accentColor: AppColors.honeyBronze,
          onTap: onViewResults,
        ),
      ],
    );
  }
}
