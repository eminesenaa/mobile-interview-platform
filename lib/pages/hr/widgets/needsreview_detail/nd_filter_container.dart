import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

/// ===============================================================
/// FILTER CONTAINER (CLEAN / MINIMAL VERSION)
/// ---------------------------------------------------------------
/// - Beyaz yüzey
/// - İnce primary border
/// - Hafif shadow
/// - Header sade ve aynı yüzey içinde
/// ===============================================================
class NdFilterContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onClear;

  const NdFilterContainer({
    super.key,
    required this.child,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,

        /// 🔥 Soft primary border
        border: Border.all(
          color: AppColors.textMuted.withOpacity(0.26),
        ),

        borderRadius: BorderRadius.circular(AppRadius.lg),

        /// 🔥 çok hafif shadow (opsiyonel ama önerilir)
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// =========================
          /// HEADER (INLINE)
          /// =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filters".toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  "Clear all",
                  style: AppTextStyles.textButton.copyWith(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          /// =========================
          /// CONTENT
          /// =========================
          child,
        ],
      ),
    );
  }
}
