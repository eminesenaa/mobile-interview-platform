import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';
import '../controllers/profile_edit_controller.dart';
import '../../../utils/avatar_utils.dart';

/// ===============================================================
/// AvatarPickerDialog
/// ===============================================================
class AvatarPickerDialog extends StatefulWidget {
  const AvatarPickerDialog({super.key});

  @override
  State<AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<AvatarPickerDialog> {
  final controller = Get.find<ProfileEditController>();

  late String tempSelectedAvatar;

  /// avatars + initials (en sonda)
  final List<String> avatars = [
    ...List.generate(6, (i) => "assets/avatars/avatar${i + 1}.jpg"),
    "",
  ];

  @override
  void initState() {
    super.initState();
    tempSelectedAvatar = controller.avatarPath.value;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Avatar",
              style: AppTextStyles.headline,
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ===============================
            /// PREVIEW
            /// ===============================
            _AvatarPreview(
              avatarPath: tempSelectedAvatar,
              controller: controller,
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ===============================
            /// GRID
            /// ===============================
            GridView.builder(
              shrinkWrap: true,
              itemCount: avatars.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                final avatar = avatars[index];
                final isSelected = avatar == tempSelectedAvatar;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      tempSelectedAvatar = avatar;
                    });
                  },
                  child: _AvatarItem(
                    avatar: avatar,
                    isSelected: isSelected,
                    controller: controller,
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ===============================
            /// ACTIONS
            /// ===============================
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(
                        color: AppColors.textPrimary.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      controller.avatarPath.value = tempSelectedAvatar;
                      Get.back();
                    },
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// PREVIEW WIDGET
/// ===============================================================
class _AvatarPreview extends StatelessWidget {
  final String avatarPath;
  final ProfileEditController controller;

  const _AvatarPreview({
    required this.avatarPath,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
        color:
            avatarPath.isEmpty ? AvatarUtils.getColor(controller.username.value) : null,
        image: avatarPath.isNotEmpty
            ? DecorationImage(
                image: AssetImage(avatarPath),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarPath.isEmpty ? _buildInitialAvatar(controller) : null,
    );
  }
}

/// ===============================================================
/// GRID ITEM WIDGET
/// ===============================================================
class _AvatarItem extends StatelessWidget {
  final String avatar;
  final bool isSelected;
  final ProfileEditController controller;

  const _AvatarItem({
    required this.avatar,
    required this.isSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 3,
        ),
        color: avatar.isEmpty ? AvatarUtils.getColor(controller.username.value) : null,
        image: avatar.isNotEmpty
            ? DecorationImage(
                image: AssetImage(avatar),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child:
          avatar.isEmpty ? _buildInitialAvatar(controller, small: true) : null,
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
