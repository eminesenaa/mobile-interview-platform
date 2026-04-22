import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class RdCandidatesHeader extends StatelessWidget {
  final int showing;
  final int total;
  final VoidCallback onSort;

  const RdCandidatesHeader({
    super.key,
    required this.showing,
    required this.total,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Showing $showing of $total",
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textMuted, fontSize: 13),
        ),
        GestureDetector(
          onTap: onSort,
          child: Row(
            children: [
              Text(
                "Score",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                PhosphorIcons.arrowFatDown(
                  PhosphorIconsStyle.fill,
                ),
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
