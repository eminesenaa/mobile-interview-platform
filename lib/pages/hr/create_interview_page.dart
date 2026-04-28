// ===================== File: create_interview_page.dart =====================
// Purpose:
// HR creates a new interview session (FINAL VERSION)
//
// Architecture:
// - Stateless + GetX
// - Fully modular widgets
// - Backend-ready
//
// Notes:
// - Uses Phosphor icons
// - Clean spacing system
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/widgets/create_interview/ci_questions_actions.dart';

import '../../constants/constants.dart';

// CONTROLLER
import 'controllers/create_interview_controller.dart';

// WIDGETS
import 'widgets/create_interview/ci_text_field.dart';
import 'widgets/create_interview/ci_date_time_row.dart';
import 'widgets/create_interview/ci_invite_code_card.dart';
import 'widgets/create_interview/ci_create_button.dart';

class CreateInterviewPage extends StatelessWidget {
  const CreateInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateInterviewController());

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
          "Create Interview",
          style: AppTextStyles.title,
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TITLE =================
            CITextField(
              label: "Interview Title",
              controller: controller.titleCtrl,
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= POSITION =================
            CITextField(
              label: "Position",
              controller: controller.positionCtrl,
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= DATE + TIME =================
            const CIDateTimeRow(),

            const SizedBox(height: AppSpacing.lg),

            // ================= QUESTIONS =================
            const CIQuestionsActions(),

            const SizedBox(height: AppSpacing.xxl),

            // ================= INVITE CODE =================
            const CIInviteCodeCard(),

            const SizedBox(height: AppSpacing.xxl),

            // ================= CREATE BUTTON =================
            const CICreateButton(),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
