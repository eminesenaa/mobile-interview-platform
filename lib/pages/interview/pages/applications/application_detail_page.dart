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
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../main_view.dart';

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

    // 🔹 For data visibility: If application document is missing full job info,
    // we can try to use a placeholder or better, let the UI handle it via fallbacks.
    // However, the best way for detail page is to ensure JdJobInfoSection gets what it needs.

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .doc(application["id"])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final appData = snapshot.data!.data() as Map<String, dynamic>?;
          if (appData == null) return const Center(child: Text("Application not found"));
          
          final currentStatus = appData["status"] ?? "pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JdJobInfoSection(job: appData),
                const SizedBox(height: AppSpacing.xl),
                JdDescriptionSection(job: appData),
                const SizedBox(height: AppSpacing.xl),
                AdStatusCard(
                  status: currentStatus,
                  date: appData["startTime"] != null
                      ? controller.formatDate(appData["startTime"])
                      : null,
                  timeRange: appData["startTime"] != null &&
                          appData["endTime"] != null
                      ? controller.formatTimeRange(
                          appData["startTime"],
                          appData["endTime"],
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (currentStatus == "accepted" || currentStatus == "rejected") ...[
                  AdHrMessageCard(
                    title: currentStatus == "accepted"
                        ? "Message from HR"
                        : "Feedback from HR",
                    message: appData["hrMessage"] ?? "No message provided.",
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (currentStatus == "accepted") ...[
                  const SizedBox(height: AppSpacing.md),
                  AdInviteCodeCard(
                    code: appData["inviteCode"] ?? "N/A",
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.offAll(
                          () => const MainView(initialIndex: 1),
                          arguments: {
                            "targetJob": appData["jobTitle"],
                            "skills": appData["skills"],
                          },
                        );
                      },
                      icon: const Icon(Icons.school_outlined),
                      label: const Text("Start Preparation Training"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
