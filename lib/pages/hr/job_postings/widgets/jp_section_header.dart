import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class JPSectionHeader extends StatelessWidget {
  final String title;
  final String? badge;

  const JPSectionHeader({
    super.key,
    required this.title,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.label.copyWith(fontSize: 13),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge!,
              style: AppTextStyles.bodySmall,
            ),
          )
      ],
    );
  }
}
