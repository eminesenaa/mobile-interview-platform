// ===================== File: st_danger_tile.dart =====================
// Purpose:
// Dangerous action tile (Delete Account)
//
// Fix:
// - Same height as other tiles
// - Keeps red styling
// - More compact layout
// =====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class StDangerTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const StDangerTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ================= ICON =================
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              PhosphorIcons.x(),
              size: 18, // 🔥 sabitledik
              color: AppColors.error,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ================= TEXT =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 🔥 height fix
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.error,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // ================= ARROW =================
          Icon(
            PhosphorIcons.caretRight(),
            size: 16,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}
