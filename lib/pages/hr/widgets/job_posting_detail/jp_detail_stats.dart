import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

/// ===================== JP DETAIL STATS =====================
/// 2x2 GRID layout (fixed, responsive, no overflow)
///
/// Layout:
/// [ Applicants ] [ Accepted ]
/// [ Rejected  ] [ Pending  ]
/// ===========================================================

class JPDetailStats extends StatelessWidget {
  final int applicants;
  final int accepted;
  final int rejected;
  final int pending;

  const JPDetailStats({
    super.key,
    required this.applicants,
    required this.accepted,
    required this.rejected,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem("Applicants", applicants, AppColors.textPrimary),
      _StatItem("Accepted", accepted, AppColors.success),
      _StatItem("Rejected", rejected, AppColors.error),
      _StatItem("Pending", pending, AppColors.warning),
    ];

    return GridView.count(
      crossAxisCount: 2,
      // 🔥 2x2 layout
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      // 🔥 kutu oranı (çok önemli)
      children: items.map((e) => _card(e)).toList(),
    );
  }

  /// ================= CARD =================
  Widget _card(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.value.toString(),
            style: AppTextStyles.headline.copyWith(
              color: item.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// ===================== MODEL =====================
class _StatItem {
  final String label;
  final int value;
  final Color color;

  _StatItem(this.label, this.value, this.color);
}
