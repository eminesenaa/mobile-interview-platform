// ===================== File: st_toggle_tile.dart =====================
// Purpose:
// Toggle switch tile (Preferences)
//
// Used for:
// - Notifications
// - Dark Mode
// =====================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class StToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const StToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ICON
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 18),
        ),

        const SizedBox(width: AppSpacing.md),

        // TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyStrong),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),

        // SWITCH
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
