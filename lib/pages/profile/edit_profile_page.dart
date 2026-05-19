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
                    controller: c.nameCtrl,
                  ),
                  EpInputField(
                    label: "Last Name",
                    controller: c.surnameCtrl,
                  ),
                  EpInputField(
                    label: "Username",
                    controller: c.usernameCtrl,
                  ),
                  EpInputField(
                    label: "Email",
                    controller: c.emailCtrl,
                  ),
                  EpInputField(
                    label: "Phone",
                    controller: c.phoneNumberCtrl,
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
                    controller: c.roleCtrl,
                  ),
                  EpInputField(
                    label: "Country",
                    controller: c.countryCtrl,
                  ),
                  EpInputField(
                    label: "City",
                    controller: c.cityCtrl,
                  ),
                  EpInputField(
                    label: "School / University",
                    controller: c.schoolCtrl,
                  ),
                  EpInputField(
                    label: "Company",
                    controller: c.companyCtrl,
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
                  EpInputField(
                    label: "GitHub URL",
                    controller: c.githubUrlCtrl,
                  ),
                  EpInputField(
                    label: "LinkedIn URL",
                    controller: c.linkedinUrlCtrl,
                  ),
                  EpInputField(
                    label: "Website / Portfolio",
                    controller: c.websiteCtrl,
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
