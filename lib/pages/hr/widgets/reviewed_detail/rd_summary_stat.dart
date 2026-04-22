import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class RdSummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const RdSummaryStat({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72, // 🔥 SABİT YÜKSEKLİK (en önemli fix)
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// VALUE
          Text(
            value,
            style: AppTextStyles.bodyStrong.copyWith(
              color: color ?? AppColors.textPrimary,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          /// LABEL (WRAP FIX)
          Text(
            label,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1, // 🔥 taşmayı engeller
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
