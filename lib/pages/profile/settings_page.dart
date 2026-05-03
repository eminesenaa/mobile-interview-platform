// ===================== File: settings_page.dart =====================
// Purpose:
// Main Settings Page UI
//
// Notes:
// - Uses ProfileController (read-only)
// - No new controller created
// - Fully UI-focused
// - Navigation ready
// ===================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../constants/constants.dart';
import '../auth/login_page.dart';
import '../profile/controllers/profile_controller.dart';
import '../profile/edit_profile_page.dart';

// Widgets
import 'controllers/profile_edit_controller.dart';
import 'widgets/settings/st_header_section.dart';
import 'widgets/settings/st_action_tile.dart';
import 'widgets/settings/st_toggle_tile.dart';
import 'widgets/settings/st_select_tile.dart';
import 'widgets/settings/st_danger_tile.dart';
import 'widgets/settings/st_logout_button.dart';
import 'widgets/settings/st_change_password_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Settings",
          style: AppTextStyles.title,
        ),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Get.back(),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER
              // =====================================================
              const Center(child: StHeaderSection()),

              const SizedBox(height: AppSpacing.xl),

              // =====================================================
              // ACCOUNT
              // =====================================================
              _sectionLabel("ACCOUNT"),
              const SizedBox(height: AppSpacing.sm),

              _groupCard([
                StActionTile(
                  title: "Edit Profile",
                  subtitle: "Name, photo, bio",
                  icon: PhosphorIcons.pencilSimple(),
                  onTap: () => Get.to(() => const EditProfilePage()),
                ),
                const SizedBox(height: AppSpacing.md),
                StActionTile(
                  title: "Change Password",
                  subtitle: "Update your password",
                  icon: PhosphorIcons.lock(),
                  onTap: () {
                    Get.put(ProfileEditController());
                    Get.dialog(const StChangePasswordDialog());
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Obx(() {
                  final email = c.user.value?.email ?? "";
                  return StActionTile(
                    title: "Email Address",
                    subtitle: email,
                    icon: PhosphorIcons.envelope(),
                    onTap: null,
                  );
                }),
              ]),

              const SizedBox(height: AppSpacing.lg),

              // =====================================================
              // PREFERENCES
              // =====================================================
              _sectionLabel("PREFERENCES"),
              const SizedBox(height: AppSpacing.sm),

              _groupCard([
                StToggleTile(
                  title: "Notifications",
                  subtitle: "Interview reminders",
                  icon: PhosphorIcons.bell(),
                  value: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.md),
                StToggleTile(
                  title: "Dark Mode",
                  subtitle: "System default",
                  icon: PhosphorIcons.moon(),
                  value: false,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.md),
                StSelectTile(
                  title: "Language",
                  value: "English",
                  icon: PhosphorIcons.globe(),
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: AppSpacing.lg),

              // =====================================================
              // PRIVACY & SECURITY
              // =====================================================
              _sectionLabel("PRIVACY & SECURITY"),
              const SizedBox(height: AppSpacing.sm),

              _groupCard([
                StActionTile(
                  title: "Privacy Policy",
                  icon: PhosphorIcons.shieldCheck(),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                StActionTile(
                  title: "Terms of Service",
                  icon: PhosphorIcons.fileText(),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                const StDangerTile(
                  title: "Delete Account",
                  subtitle: "Permanent action",
                ),
              ]),

              const SizedBox(height: AppSpacing.lg),

              // =====================================================
              // SUPPORT
              // =====================================================
              _sectionLabel("SUPPORT"),
              const SizedBox(height: AppSpacing.sm),

              _groupCard([
                StActionTile(
                  title: "Help Center",
                  icon: PhosphorIcons.question(),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                StActionTile(
                  title: "Contact Support",
                  icon: PhosphorIcons.chatCircle(),
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: AppSpacing.xl),

              // =====================================================
              // LOGOUT
              // =====================================================
              StLogoutButton(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(() => const LoginPage());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // SECTION LABEL
  // =====================================================
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        letterSpacing: 1,
        fontSize: 13,
      ),
    );
  }

  // =====================================================
  // GROUP CARD
  // =====================================================
  Widget _groupCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}
