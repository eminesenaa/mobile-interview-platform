import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/text_styles.dart';

/// ===============================================================
/// ND SECTION LABEL
/// ===============================================================
class NdSectionLabel extends StatelessWidget {
  final String title;
  final String? trailing;

  const NdSectionLabel({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}
