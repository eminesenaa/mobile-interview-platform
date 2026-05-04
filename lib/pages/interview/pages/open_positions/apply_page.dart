// ===================== File: apply_page.dart =====================
// Purpose:
// Candidate applies to a job posting
//
// Features:
// - AppBar (standard)
// - Contact section
// - Application Info section
// - Skills section
// - Links (optional)
// - Resume upload
// - Submit button
//
// IMPORTANT:
// - Uses OpenPositionsController
// - Fully backend-ready
// - Uses modular widgets
// =================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../controllers/open_positions_controller.dart';

// ================= WIDGETS =================
import '../../widgets/open_positions/apply/ap_contact_section.dart';
import '../../widgets/open_positions/apply/ap_application_info_section.dart';
import '../../widgets/open_positions/apply/ap_section_title.dart';
import '../../widgets/open_positions/apply/ap_skills_section.dart';
import '../../widgets/open_positions/apply/ap_links_section.dart';
import '../../widgets/open_positions/apply/ap_resume_section.dart';
import '../../widgets/open_positions/apply/ap_submit_button.dart';

class ApplyPage extends StatelessWidget {
  const ApplyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OpenPositionsController());

    if (Get.arguments != null) {
      controller.setSelectedJob(Get.arguments);
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Apply",
          style: AppTextStyles.title,
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // CONTACT
            // =====================================================
            ApContactSection(
              emailCtrl: controller.emailCtrl,
              phoneCtrl: controller.phoneCtrl,
              locationCtrl: controller.locationCtrl,
            ),

            const SizedBox(height: AppSpacing.xl),

            // =====================================================
            // APPLICATION INFO
            // =====================================================
            ApApplicationInfoSection(
              universityCtrl: controller.universityCtrl,
              departmentCtrl: controller.departmentCtrl,
            ),

            const SizedBox(height: AppSpacing.xl),

            // =====================================================
            // SKILLS
            // =====================================================
            Obx(() => ApSkillsSection(
              skills: controller.skills.toList(),
              skillCtrl: controller.skillCtrl,
              onAdd: controller.addSkill,
              onRemove: controller.removeSkill,
            )),

            const SizedBox(height: AppSpacing.xl),

            // =====================================================
            // LINKS
            // =====================================================
            ApLinksSection(
              portfolioCtrl: controller.portfolioCtrl,
              githubCtrl: controller.githubCtrl,
              linkedinCtrl: controller.linkedinCtrl,
            ),

            const SizedBox(height: AppSpacing.xl),

            // =====================================================
            // RESUME
            // =====================================================
            const ApSectionTitle(title: "Resume / CV"),
            const SizedBox(height: AppSpacing.md),
            ApResumeSection(
              onTap: controller.pickResume,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // =====================================================
            // SUBMIT BUTTON
            // =====================================================
            ApSubmitButton(
              onTap: controller.submitApplication,
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
