import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/pages/profile/widgets/edit_text_tile.dart';
import 'package:interview_project/pages/profile/widgets/picker_tile.dart';
import 'package:interview_project/pages/profile/widgets/section_title.dart';
import 'package:interview_project/pages/profile/widgets/settings_action_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:interview_project/pages/auth/login_page.dart';

import 'controllers/profile_settings_controller.dart';


class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileSettingsController());
    const headerColor = AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SectionTitle('Profile'),
                  const SizedBox(height: 16),
                  Obx(() => EditTextTile(
                    icon: Icons.badge_rounded,
                    title: 'Name',
                    valueText: c.name.value,
                    dialogLabel: 'Name',
                    initialValue: c.name.value,
                    validator: (v) => c.validateNotEmpty(v, 'Name'),
                    onSubmit: c.setName,
                  )),
                  Obx(() => EditTextTile(
                    icon: Icons.badge_outlined,
                    title: 'Surname',
                    valueText: c.surname.value,
                    dialogLabel: 'Surname',
                    initialValue: c.surname.value,
                    validator: (v) => c.validateNotEmpty(v, 'Surname'),
                    onSubmit: c.setSurname,
                  )),
                  Obx(() => EditTextTile(
                    icon: Icons.alternate_email_rounded,
                    title: 'Username',
                    valueText: c.username.value,
                    dialogLabel: 'Username',
                    initialValue: c.username.value,
                    validator: (v) => c.validateNotEmpty(v, 'Username'),
                    onSubmit: c.setUsername,
                  )),
                  Obx(() => EditTextTile(
                    icon: Icons.mail_rounded,
                    title: 'Email',
                    valueText: c.email.value,
                    dialogLabel: 'Email',
                    initialValue: c.email.value,
                    validator: c.validateEmail,
                    onSubmit: c.setEmail,
                  )),

                  const SizedBox(height: 16),
                  const SectionTitle('Preferences'),
                  const SizedBox(height: 16),
                  Obx(() => PickerTile(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    valueText: c.language.value,
                    options: const ['English', 'Türkçe', 'Deutsch'],
                    onSelected: c.setLanguage,
                  )),

                  const SizedBox(height: 16),
                  const SectionTitle('Security'),
                  const SizedBox(height: 16),
                  SettingsActionTile(
                    icon: Icons.lock_reset_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () => _showChangePasswordDialog(context, c),
                  ),
               SettingsActionTile(
  icon: Icons.logout_rounded,
  title: 'Sign Out',
  subtitle: 'Sign out from this device',
  onTap: () async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes, Sign Out"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => LoginPage());
      Get.snackbar('Signed out', 'You have been logged out.');
    }
  },
),



                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- helpers ----
Future<void> _showChangePasswordDialog(
    BuildContext context, ProfileSettingsController c) async {
  final currentCtrl = TextEditingController();
  final nextCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) =>
              (v == null || v.length < 6) ? 'At least 6 chars' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nextCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
              validator: (v) =>
              (v == null || v.length < 6) ? 'At least 6 chars' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            await c.changePassword(
              currentCtrl.text.trim(),
              nextCtrl.text.trim(),
            );
            Get.back();
          },
          child: const Text('Update'),
        ),
      ],
    ),
  );
}
