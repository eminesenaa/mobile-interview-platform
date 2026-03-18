import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/duel_type_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// ===============================================================
/// 🎮 DUEL RESULT ACTION BUTTONS (NEW DESIGN)
/// ===============================================================
///
/// ✔ Circular icon buttons
/// ✔ Icon + label altında
/// ✔ Yan yana hizalı
/// ✔ Reusable widget yapısı
///
class DuelResultActionButtons extends StatelessWidget {
  const DuelResultActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /// 🏠 HOME
          _ActionItem(
            icon: PhosphorIcons.house(PhosphorIconsStyle.fill),
            label: "Home",
            onTap: () {
              Get.until((route) => route.isFirst);
            },
          ),

          /// 🎮 PLAY AGAIN
          _ActionItem(
            icon: PhosphorIcons.arrowClockwise(PhosphorIconsStyle.fill),
            label: "Play Again",
            onTap: () {
              Get.until((route) => route.isFirst);
              Get.to(() => const DuelTypePage());
            },
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// 🔘 SINGLE ACTION ITEM (Reusable)
/// ===============================================================
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🎯 CIRCLE BUTTON
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppColors.surface,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        /// 📝 LABEL
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textLightPrimary,
          ),
        ),
      ],
    );
  }
}
