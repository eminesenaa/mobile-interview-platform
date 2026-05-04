// ===================== File: hp_leaderboard_section.dart =====================
// Purpose:
// Leaderboard section with header + preview
// ======================================================================

import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';
import 'hp_leaderboard_preview.dart';
import 'hp_section_header.dart';

class HpLeaderboardSection extends StatelessWidget {
  final List top3;
  final dynamic me;
  final VoidCallback onTap;

  const HpLeaderboardSection({
    super.key,
    required this.top3,
    required this.me,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        HpSectionHeader(
          title: "Leaderboard",
          actionText: "Full Board",
          onTap: onTap,
        ),

        const SizedBox(height: AppSpacing.md),

        // CARD
        HpLeaderboardPreview(
          top3: top3,
          me: me,
        ),
      ],
    );
  }
}
