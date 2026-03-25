import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';
import '../controllers/profile_edit_controller.dart';
import 'avatar_picker_dialog.dart';
import '../../../utils/avatar_utils.dart';

/// ===============================================================
/// ProfileEditAvatar
/// ===============================================================
class ProfileEditAvatar extends StatelessWidget {
  const ProfileEditAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileEditController>();

    return Column(
      children: [
        Obx(() {
          final avatarPath = controller.avatarPath.value;

          return Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
                width: 3,
              ),
              color: avatarPath.isEmpty
                  ? AvatarUtils.getColor(controller.username.value)
                  : null,
              image: avatarPath.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(avatarPath),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarPath.isEmpty ? _buildInitialAvatar(controller) : null,
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () {
            Get.dialog(const AvatarPickerDialog());
          },
          child: Text(
            "Change avatar",
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================================================
/// HELPERS
/// ===============================================================

Widget _buildInitialAvatar(ProfileEditController c, {bool small = false}) {
  return Center(
    child: Text(
      AvatarUtils.getInitials(c.name.value, c.surname.value),
      style: AppTextStyles.headline.copyWith(
        color: Colors.white,
        fontSize: small ? 16 : 28,
      ),
    ),
  );
}
