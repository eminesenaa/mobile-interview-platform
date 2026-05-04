// ===================== File: edit_profile_page.dart =====================
// Purpose:
// Redesigned Edit Profile Page (Clean + Grouped UI)
//
// Notes:
// - Uses new edit_profile widgets
// - Backend & controller untouched
// - Fully reactive (GetX)
// ======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../constants/constants.dart';
import 'controllers/profile_edit_controller.dart';

// NEW WIDGETS
import 'widgets/edit_profile/ep_avatar_section.dart';
import 'widgets/edit_profile/ep_group_card.dart';
import 'widgets/edit_profile/ep_input_field.dart';
import 'widgets/edit_profile/ep_social_row.dart';
import 'widgets/edit_profile/ep_save_button.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileEditController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: AppTextStyles.headline,
        ),
      ),

      // ================= BODY =================
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // AVATAR
              // =====================================================
              const Center(child: EpAvatarSection()),

              const SizedBox(height: AppSpacing.xl),

              // =====================================================
              // PERSONAL INFO
              // =====================================================
              EpGroupCard(
                title: "PERSONAL INFO",
                children: [
                  EpInputField(
                    label: "First Name",
                    initialValue: c.name.value,
                    onChanged: (v) => c.name.value = v,
                  ),
                  EpInputField(
                    label: "Last Name",
                    initialValue: c.surname.value,
                    onChanged: (v) => c.surname.value = v,
                  ),
                  EpInputField(
                    label: "Username",
                    initialValue: c.username.value,
                    onChanged: (v) => c.username.value = v,
                  ),
                  EpInputField(
                    label: "Email",
                    initialValue: c.email.value,
                    onChanged: (v) => c.email.value = v,
                  ),
                  EpInputField(
                    label: "Phone",
                    initialValue: c.phoneNumber.value,
                    onChanged: (v) => c.phoneNumber.value = v,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // =====================================================
              // ABOUT YOU
              // =====================================================
              EpGroupCard(
                title: "ABOUT YOU",
                children: [
                  EpInputField(
                    label: "Role",
                    initialValue: c.role.value,
                    onChanged: (v) => c.role.value = v,
                  ),
                  EpInputField(
                    label: "Location",
                    initialValue: "${c.city.value}, ${c.country.value}".trim(),
                    onChanged: (_) {},
                  ),
                  EpInputField(
                    label: "Company / School",
                    initialValue: c.company.value.isNotEmpty
                        ? c.company.value
                        : c.school.value,
                    onChanged: (v) => c.company.value = v,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // =====================================================
              // SOCIAL LINKS
              // =====================================================
              EpGroupCard(
                title: "SOCIAL LINKS",
                children: [
                  EpSocialRow(
                    label: "GitHub",
                    value: c.githubUrl.value,
                    icon: PhosphorIcons.githubLogo(),
                  ),
                  EpSocialRow(
                    label: "LinkedIn",
                    value: c.linkedinUrl.value,
                    icon: PhosphorIcons.linkedinLogo(),
                  ),
                  EpSocialRow(
                    label: "Website",
                    value: c.website.value,
                    icon: PhosphorIcons.globe(),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // =====================================================
              // SAVE BUTTON
              // =====================================================
              EpSaveButton(
                onTap: () async {
                  await c.saveProfileChanges();
                  Get.back();
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
