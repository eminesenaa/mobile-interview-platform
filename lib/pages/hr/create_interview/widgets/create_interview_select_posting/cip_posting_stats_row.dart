import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '/../../../../constants/constants.dart';

class CipPostingStatsRow extends StatelessWidget {
  final int applicants;
  final int accepted;
  final int rejected;

  const CipPostingStatsRow({
    super.key,
    required this.applicants,
    required this.accepted,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _item(
            applicants,
            "APPLICANTS",
            PhosphorIcons.users(PhosphorIconsStyle.fill),
            AppColors.textSecondary),
        _verticalDivider(),
        _item(
            accepted,
            "ACCEPTED",
            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            AppColors.success),
        _verticalDivider(),
        _item(rejected, "REJECTED",
            PhosphorIcons.xCircle(PhosphorIconsStyle.fill), AppColors.error),
      ],
    );
  }

  // ================= ITEM =================
  Widget _item(int value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppIconSizes.md, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  "$value",
                  style: AppTextStyles.title.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ================= DIVIDER =================
  Widget _verticalDivider() {
    return SizedBox(
      width: 8,
      child: Center(
        child: Container(
          width: 1,
          height: 24,
          color: AppColors.border,
        ),
      ),
    );
  }
}
