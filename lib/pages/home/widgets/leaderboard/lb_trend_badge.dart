// ===================== File: lb_trend_badge.dart =====================
// Purpose:
// Rank change indicator (+2, -1, 0)
// =================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/colors.dart';

class LbTrendBadge extends StatelessWidget {
  final int value;

  const LbTrendBadge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == 0) {
      return _buildBadge(
        "0",
        AppColors.textMuted,
        icon: PhosphorIcons.minus(PhosphorIconsStyle.bold),
      );
    }

    final isUp = value > 0;

    return _buildBadge(
      "${isUp ? "+" : ""}$value",
      isUp ? AppColors.success : AppColors.error,
      icon: isUp
          ? PhosphorIcons.arrowUp(PhosphorIconsStyle.bold)
          : PhosphorIcons.arrowDown(PhosphorIconsStyle.bold),
    );
  }

  Widget _buildBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 12, color: color),
          if (icon != null) const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
