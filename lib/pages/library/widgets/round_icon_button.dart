// ===================== UPDATED: round_icon_button.dart =====================

import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  /// 🔥 Yeni eklenen param: buton seçili mi?
  final bool selected;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.selected = false, // default
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 28,
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderStrong,
            width: selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          icon,
          size: 20,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
