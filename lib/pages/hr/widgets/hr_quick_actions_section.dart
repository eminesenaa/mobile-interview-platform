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
  final VoidCallback onCreateInterview;
  final VoidCallback onViewInterviews;
  final VoidCallback onViewCandidates;

  const HRQuickActionsSection({
    super.key,
    required this.onCreateInterview,
    required this.onViewInterviews,
    required this.onViewCandidates,
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
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ===============================
        // CREATE INTERVIEW
        // ===============================
        HRActionCard(
          title: "Create Interview",
          subtitle: "Set up a new interview session",
          icon: PhosphorIcons.plus(),
          accentColor: AppColors.accentRoyalPlum,
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
          accentColor: AppColors.stormyTeal,
          onTap: onViewInterviews,
        ),

        const SizedBox(height: AppSpacing.sm),

        // ===============================
        // CANDIDATES
        // ===============================
        HRActionCard(
          title: "Candidates",
          subtitle: "Browse & manage applicants",
          icon: PhosphorIcons.users(),
          accentColor: AppColors.accentSpicyOrange,
          onTap: onViewCandidates,
        ),
      ],
    );
  }
}
