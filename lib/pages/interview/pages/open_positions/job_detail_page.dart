// ===================== File: job_detail_page.dart =====================
// Purpose:
// Displays detailed information of a selected job posting
//
// Features:
// - AppBar (standard back)
// - Job Info section
// - Description section
// - Apply button (CTA)
//
// IMPORTANT:
// - Receives job via Get.arguments
// - Uses modular widgets
// - Backend-ready structure
//
// FLOW:
// OpenPositionsPage → JobDetailPage → ApplyPage (next step)
// =====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../widgets/open_positions/job_detail/jd_apply_button.dart';
import '../../widgets/open_positions/job_detail/jd_description_section.dart';
import '../../widgets/open_positions/job_detail/jd_job_info_section.dart';
import 'apply_page.dart';

class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ===============================
    // GET DATA FROM NAVIGATION
    // ===============================
    final Map<String, dynamic> job = Get.arguments as Map<String, dynamic>;

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Job Details",
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
            // ================= JOB INFO =================
            JdJobInfoSection(job: job),

            const SizedBox(height: AppSpacing.xl),

            // ================= DESCRIPTION =================
            JdDescriptionSection(job: job),

            const SizedBox(height: AppSpacing.xxl),

            // ================= APPLY BUTTON =================
            JdApplyButton(
              onTap: () {
                Get.to(
                  () => const ApplyPage(),
                  arguments: job,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
