import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class ReadOnlyCodeBlock extends StatelessWidget {
  final String code;

  const ReadOnlyCodeBlock({
    super.key,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.25),
          width: 1.2,
        ),
      ),
      child: SelectableText(
        code,
        style: AppTextStyles.bodySmall.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}
