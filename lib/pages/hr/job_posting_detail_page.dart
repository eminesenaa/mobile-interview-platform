// ===================== File: job_posting_detail_page.dart =====================
// Purpose:
// Detailed page for a single Job Posting (Application)
//
// Supports:
// - Active postings
// - Closed postings (future)
//
// Features:
// - Header (title + meta + status)
// - Stats (4 metrics)
// - Job info
// - Description + requirements
// - Applicants preview (max 3)
// - Close posting action (only if active)
//
// IMPORTANT:
// - Uses HrJobPostingsController (single source of truth)
// - Navigation-ready (card -> this page)
//
// TODO (Backend):
// - Fetch posting by ID
// - Fetch applicants
// - Update applicant status
// - Close posting API
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/constants.dart';
import 'controllers/hr_job_postings_controller.dart';

// Widgets
import 'widgets/job_posting_detail/jp_detail_header.dart';
import 'widgets/job_posting_detail/jp_detail_stats.dart';
import 'widgets/job_posting_detail/jp_detail_info_section.dart';
import 'widgets/job_posting_detail/jp_detail_description.dart';
import 'widgets/job_posting_detail/jp_detail_applicants_preview.dart';
import 'widgets/job_posting_detail/jp_close_posting_section.dart';

class JobPostingDetailPage extends StatelessWidget {
  final Map<String, dynamic> posting;

  const JobPostingDetailPage({
    super.key,
    required this.posting,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HrJobPostingsController>();

    final isActive = posting["status"] == "active";

    return Scaffold(
      backgroundColor: AppColors.background,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: const Text("Posting Details"),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, // left
          AppSpacing.md, // top
          AppSpacing.lg, // right
          0, // bottom
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            JPDetailHeader(
              title: posting["title"],
              meta: "Posted Apr 1 · ID: ${posting["id"] ?? "JP-0001"}",
              isActive: isActive,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ================= STATS =================
            JPDetailStats(
              applicants: posting["applicants"] ?? 0,
              accepted: posting["accepted"] ?? 0,
              rejected: posting["rejected"] ?? 0,
              pending: posting["pending"] ?? 0,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ================= JOB INFO =================
            Text("JOB INFO", style: AppTextStyles.label.copyWith(fontSize: 13)),
            const SizedBox(height: AppSpacing.md),

            JPDetailInfoSection(
              info: {
                "Position": posting["position"] ?? "-",
                "Work Type": posting["workType"] ?? "-",
                "Location": posting["location"] ?? "-",
                if (posting["salary"] != null) "Salary": posting["salary"],
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // ================= DESCRIPTION =================
            JPDetailDescription(
              description: posting["description"] ?? "No description provided.",
              requirements: List<String>.from(
                posting["requirements"] ?? [],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ================= APPLICANTS =================
            JPDetailApplicantsPreview(
              applicants: List<Map<String, dynamic>>.from(
                posting["applicantsPreview"] ?? [],
              ),
              onSeeAll: () {
                Get.snackbar("TODO", "Open full applicant list");
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // ================= CLOSE POSTING =================
            if (isActive)
              JPClosePostingSection(
                onClose: () {
                  /// 🔥 Controller action
                  c.closePosting(posting["id"]);

                  Get.back();
                },
              ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
