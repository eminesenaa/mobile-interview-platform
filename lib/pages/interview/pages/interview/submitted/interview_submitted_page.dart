// ===================== File: interview_submitted_page.dart =====================
// Purpose:
// Displays interview submission success screen
//
// Features:
// - Success icon (center)
// - Title + description
// - Evaluation status chip
// - "What happens next?" steps card
// - CTA button (Go to Dashboard)
// - Footer text
//
// IMPORTANT:
// - No AppBar (full clean layout)
// - Static UI for now (backend-ready)
//
// TODO (Backend):
// - Replace static texts with dynamic data if needed
// - Handle navigation with real routes
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../constants/constants.dart';

// ================= WIDGETS =================
import '../../../widgets/interview/submitted/is_success_icon.dart';
import '../../../widgets/interview/submitted/is_title_section.dart';
import '../../../widgets/interview/submitted/is_status_chip.dart';
import '../../../widgets/interview/submitted/is_steps_card.dart';
import '../../../widgets/interview/submitted/is_submit_button.dart';
import '../../../widgets/interview/submitted/is_footer_text.dart';

class InterviewSubmittedPage extends StatelessWidget {
  const InterviewSubmittedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,

      // ================= BODY =================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ================= SUCCESS ICON =================
              IsSuccessIcon(),

              SizedBox(height: AppSpacing.xl),

              // ================= TITLE =================
              IsTitleSection(),

              SizedBox(height: AppSpacing.xl),

              // ================= STATUS CHIP =================
              IsStatusChip(),

              SizedBox(height: AppSpacing.xl),

              // ================= STEPS CARD =================
              IsStepsCard(),

              SizedBox(height: AppSpacing.xl),

              // ================= BUTTON =================
              IsSubmitButton(),

              SizedBox(height: AppSpacing.md),

              // ================= FOOTER =================
              IsFooterText(),
            ],
          ),
        ),
      ),
    );
  }
}
