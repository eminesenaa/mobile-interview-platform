// ===================== File: st_header_section.dart =====================
// Purpose:
// Displays user avatar + name + email (top section)
//
// Notes:
// - Uses ProfileController.user (Firestore model)
// - Safe null handling
// - Flat clean design (no container)
// =======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/constants.dart';
import '../../controllers/profile_controller.dart';

class StHeaderSection extends StatelessWidget {
  const StHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();

    return Obx(() {
      final user = c.user.value;

      return Column(
        children: [
          // ================= AVATAR =================
          CircleAvatar(
            radius: 36,
            backgroundImage:
                (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : const AssetImage("assets/avatars/avatar1.jpg")
                        as ImageProvider,
          ),

          const SizedBox(height: AppSpacing.sm),

          // ================= NAME =================
          Text(
            "${user?.name ?? ''} ${user?.surname ?? ''}",
            style: AppTextStyles.title,
          ),

          const SizedBox(height: 2),

          // ================= EMAIL =================
          Text(
            user?.email ?? "",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      );
    });
  }
}
