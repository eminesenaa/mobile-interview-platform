import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:interview_project/constants/constants.dart';

/// ===============================================================
/// 🧠 LOBBY HEADER
/// ===============================================================
///
/// ✔ Custom header (AppBar yerine)
/// ✔ Back button
/// ✔ Centered title
/// ✔ Gradient background ile uyumlu (light text)
///
class LobbyHeader extends StatelessWidget {
  const LobbyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          /// BACK BUTTON
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                color: Colors.white,
                size: AppIconSizes.md,
              ),
            ),
          ),

          const Spacer(),

          /// TITLE
          Text(
            'Private Room',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 20,
              color: AppColors.textLightPrimary,
            ),
          ),

          const Spacer(),

          /// sağ taraf boş (denge için)
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
