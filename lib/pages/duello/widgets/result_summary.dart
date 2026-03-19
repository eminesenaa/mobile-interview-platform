import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// ===============================================================
/// 🎯 RESULT SUMMARY (Placement + Message + Mini Stats)
/// ===============================================================
///
/// Used in multi result page:
/// - Shows placement (1st, 2nd...)
/// - Personal message
/// - Compact stat chips (XP, Combo)
///
class ResultSummary extends StatelessWidget {
  final int rank;
  final String message;
  final int xp;
  final int combo;

  const ResultSummary({
    super.key,
    required this.rank,
    required this.message,
    required this.xp,
    required this.combo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🏅 PLACEMENT
        Text(
          _placementText(rank),
          style: AppTextStyles.bodyStrong.copyWith(
            fontSize: 18,
            color: AppColors.textLightPrimary.withOpacity(0.9),
          ),
        ),

        const SizedBox(height: 4),

        /// 💬 MESSAGE
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textLightPrimary.withOpacity(0.75),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        /// ✨ MINI STATS (CHIPS)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip(
              icon: PhosphorIcons.sparkle(PhosphorIconsStyle.bold),
              text: '$xp XP',
            ),
            const SizedBox(width: AppSpacing.sm),
            _chip(
              icon: PhosphorIcons.fire(PhosphorIconsStyle.bold),
              text: 'x$combo',
            ),
          ],
        ),
      ],
    );
  }

  /// 🧠 Placement text formatter
  String _placementText(int rank) {
    switch (rank) {
      case 1:
        return '1st Place';
      case 2:
        return '2nd Place';
      case 3:
        return '3rd Place';
      default:
        return '$rank.th Place';
    }
  }

  /// 🎨 Chip widget (glass style)
  Widget _chip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textLightPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
