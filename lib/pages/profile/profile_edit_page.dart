import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/profile/widgets/common_phone_field.dart';
import 'package:interview_project/pages/profile/widgets/profile_additional_field.dart';
import 'package:interview_project/pages/profile/widgets/profile_social_input_tile.dart';
import 'package:interview_project/pages/profile/widgets/profile_text_input_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/constants.dart';

import 'controllers/profile_edit_controller.dart';
import 'widgets/profile_edit_avatar.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileEditController());

    final RxString currentPass = ''.obs;
    final RxString newPass = ''.obs;
    final RxString confirmPass = ''.obs;

    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -------------------------------
              // 🔹 PERSONAL INFORMATION SECTION
              // -------------------------------
              const ProfileEditAvatar(),
              const SizedBox(height: AppSpacing.lg),

              // ---- PERSONAL INFO HEADER ----
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Personal Information",
                  style: AppTextStyles.headline,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              ProfileTextInputField(
                label: "Name",
                icon: PhosphorIcons.user(),
                rxValue: c.name,
              ),
              const SizedBox(height: AppSpacing.md),

              ProfileTextInputField(
                label: "Surname",
                icon: PhosphorIcons.identificationBadge(),
                rxValue: c.surname,
              ),
              const SizedBox(height: AppSpacing.md),

              ProfileTextInputField(
                label: "Username",
                icon: PhosphorIcons.at(),
                rxValue: c.username,
              ),
              const SizedBox(height: AppSpacing.md),

              ProfileTextInputField(
                label: "Email",
                icon: PhosphorIcons.envelopeSimple(),
                rxValue: c.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.xl),

              CommonPhoneField(
                iso: c.phoneCountryIso.value,
                dialCode: c.phoneCountryCode.value,
                raw: c.phoneNumber.value,
                onChanged: ({required iso, required dialCode, required raw}) {
                  c.phoneCountryIso.value = iso;
                  c.phoneCountryCode.value = dialCode;
                  c.phoneNumber.value = raw;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // -------------------------------
              // 🔸 ADDITIONAL INFORMATION SECTION
              // -------------------------------
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Additional Information",
                  style: AppTextStyles.headline,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ROLE (dropdown)
              ProfileAdditionalField(
                label: "Role",
                type: AdditionalFieldType.dropdown,
                initialValue: c.role.value,
                options: c.roleOptions,
                onChanged: (v) => c.role.value = v,
                hint: "Select your role",
              ),

              const SizedBox(height: AppSpacing.md),

              // LOCATION (country + city)
              ProfileAdditionalField(
                label: "Location",
                type: AdditionalFieldType.location,
                initialValue: c.country.value,
                initialValue2: c.city.value,
                onChangedLocation: (country, city) {
                  c.country.value = country;
                  c.city.value = city;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // SCHOOL / UNIVERSITY
              ProfileAdditionalField(
                label: "School / University",
                type: AdditionalFieldType.text,
                initialValue: c.school.value,
                onChanged: (v) => c.school.value = v,
                hint: "e.g., METU",
              ),

              const SizedBox(height: AppSpacing.md),

              // CURRENT COMPANY
              ProfileAdditionalField(
                label: "Company (optional)",
                type: AdditionalFieldType.text,
                initialValue: c.company.value,
                onChanged: (v) => c.company.value = v,
                hint: "e.g., Google, Trendyol",
              ),

              const SizedBox(height: AppSpacing.xxl),

              // -------------------------------
              // 🔗 SOCIAL LINKS SECTION
              // -------------------------------
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Social Links",
                  style: AppTextStyles.headline,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              ProfileSocialInputTile(
                label: "GitHub",
                icon: PhosphorIcons.githubLogo(),
                rxValue: c.githubUrl,
              ),
              const SizedBox(height: AppSpacing.md),
              ProfileSocialInputTile(
                label: "LinkedIn",
                icon: PhosphorIcons.linkedinLogo(),
                rxValue: c.linkedinUrl,
              ),
              const SizedBox(height: AppSpacing.md),
              ProfileSocialInputTile(
                label: "Website",
                icon: PhosphorIcons.globe(),
                rxValue: c.website,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // -------------------------------
              // SAVE BUTTON
              // -------------------------------
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  onPressed: () async {
                    if (currentPass.value.isNotEmpty ||
                        newPass.value.isNotEmpty ||
                        confirmPass.value.isNotEmpty) {
                      if (newPass.value != confirmPass.value) {
                        Get.snackbar("Error", "New passwords do not match");
                        return;
                      }
                      await c.changePassword(currentPass.value, newPass.value);
                    }

                    await c.saveProfileChanges();

                    Get.back();
                  },
                  child: Text(
                    "Save Changes",
                    style:
                        AppTextStyles.bodyStrong.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
