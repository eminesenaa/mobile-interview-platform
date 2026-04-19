import 'package:flutter/material.dart';
import '/../../../constants/constants.dart';

/// ===============================================================
/// ND VIEW ALL BUTTON
/// ===============================================================
class NdViewAllButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const NdViewAllButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primarySoftBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.textButton,
          ),
        ),
      ),
    );
  }
}
