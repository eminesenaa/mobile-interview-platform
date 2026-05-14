// ===================== File: application_detail_page.dart =====================
// Purpose:
// Displays detailed view of a candidate's application
//
// Features:
// - AppBar (standard)
// - Job Info section (reused)
// - Description section (reused)
// - Dynamic Status Card
// - Conditional HR Message
// - Conditional Invite Code
//
// IMPORTANT:
// - Receives application via Get.arguments
// - Fully backend-ready
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';

// ================= REUSED =================
import '../../controllers/applications_controller.dart';
import '../../widgets/open_positions/job_detail/jd_job_info_section.dart';
import '../../widgets/open_positions/job_detail/jd_description_section.dart';

// ================= NEW WIDGETS =================
import '../../widgets/applications/detail/ad_status_card.dart';
import '../../widgets/applications/detail/ad_hr_message_card.dart';
import '../../widgets/applications/detail/ad_invite_code_card.dart';

class ApplicationDetailPage extends StatelessWidget {
  const ApplicationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // =====================================================
    // GET DATA
    // =====================================================
    final Map<String, dynamic> application =
        Get.arguments as Map<String, dynamic>;

    final status = application["status"] ?? "pending";

    final controller = Get.put(ApplicationsController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Application Details",
          style: AppTextStyles.title,
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================
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
            // JOB INFO (REUSE)
            // =====================================================
            JdJobInfoSection(job: application),

            const SizedBox(height: AppSpacing.xl),

            // =====================================================
            // DESCRIPTION (REUSE)
            // =====================================================
            JdDescriptionSection(job: application),

            const SizedBox(height: AppSpacing.xl),

            // =====================================================
            // STATUS CARD
            // =====================================================
            AdStatusCard(
              status: status,
              date: application["startTime"] != null
                  ? controller.formatDate(application["startTime"])
                  : null,
              timeRange: application["startTime"] != null &&
                  application["endTime"] != null
                  ? controller.formatTimeRange(
                application["startTime"],
                application["endTime"],
              )
                  : null,
            ),

            const SizedBox(height: AppSpacing.lg),

            // =====================================================
            // HR MESSAGE (ACCEPTED / REJECTED)
            // =====================================================
            if (status == "accepted" || status == "rejected") ...[
              AdHrMessageCard(
                title: status == "accepted"
                    ? "Message from HR"
                    : "Feedback from HR",
                message: application["hrMessage"] ?? "No message provided.",
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // =====================================================
            // INVITE CODE (ONLY ACCEPTED)
            // =====================================================
            if (status == "accepted") ...[
              const SizedBox(height: AppSpacing.md),
              AdInviteCodeCard(
                code: application["inviteCode"] ?? "N/A",
              ),
            ],
          ],
        ),
      ),
    );
  }
}
