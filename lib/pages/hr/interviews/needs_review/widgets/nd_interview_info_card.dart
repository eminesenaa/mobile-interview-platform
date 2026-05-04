import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

/// ===============================================================
/// ND INTERVIEW INFO CARD
/// ---------------------------------------------------------------
/// Needs Review Detail sayfasında interview bilgilerini gösterir.
/// ===============================================================
class NdInterviewInfoCard extends StatelessWidget {
  final String dateText;
  final String candidatesText;
  final String interviewId;

  const NdInterviewInfoCard({
    super.key,
    required this.dateText,
    required this.candidatesText,
    required this.interviewId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// =========================
          /// TOP ROW (DATE + CANDIDATES)
          /// =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(label: "DATE", value: dateText),
              _InfoItem(label: "CANDIDATES", value: candidatesText),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          /// =========================
          /// SOFT DIVIDER
          /// =========================
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.border.withOpacity(0.5), // 🔥 soft görünüm
          ),

          const SizedBox(height: AppSpacing.sm),

          /// =========================
          /// INTERVIEW ID
          /// =========================
          Text(
            interviewId,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyStrong),
      ],
    );
  }
}
