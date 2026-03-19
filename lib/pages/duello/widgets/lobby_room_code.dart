import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:interview_project/constants/constants.dart';

/// ===============================================================
/// 🔑 LOBBY ROOM CODE
/// ===============================================================
///
/// ✔ Big readable code
/// ✔ Copy button
/// ✔ Glass card style
///
class LobbyRoomCode extends StatelessWidget {
  final String password;

  const LobbyRoomCode({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          /// LABEL
          Text(
            'ROOM CODE',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLightPrimary.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 6),

          /// CODE + COPY
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                password,
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 28,
                  letterSpacing: 6,
                  color: AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: password));

                  Get.snackbar(
                    'Copied',
                    'Room code copied',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black.withOpacity(0.7),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(AppSpacing.lg),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: Icon(
                    PhosphorIcons.copy(PhosphorIconsStyle.bold),
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
