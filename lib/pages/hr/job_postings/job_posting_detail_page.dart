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


import '../../../constants/constants.dart';
import '../controllers/hr_job_postings_controller.dart';
import 'widgets/job_posting_detail/jp_close_posting_section.dart';
import 'widgets/job_posting_detail/jp_detail_applicants_preview.dart';
import 'widgets/job_posting_detail/jp_detail_description.dart';
import 'widgets/job_posting_detail/jp_detail_header.dart';
import 'widgets/job_posting_detail/jp_detail_info_section.dart';
import 'widgets/job_posting_detail/jp_detail_stats.dart';
import 'widgets/job_posting_detail/jp_finalize_posting_section.dart';

// Widgets


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
    final isClosed = posting["status"] == "closed";

    return Scaffold(
      backgroundColor: AppColors.background,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Posting Details"),
      ),

      /// ================= BODY =================
      body: Obx(() {
        final p = c.getPostingById(posting["id"]) ?? posting;
        final isActive = p["status"] == "active";
        final isClosed = p["status"] == "closed";
        final isFinalized = p["status"] == "finalized";

        return SingleChildScrollView(
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
                title: p["title"],
                meta: "Posted Apr 1 · ID: ${p["id"] ?? "JP-0001"}",
                status: p["status"] ?? "active",
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================= STATS =================
              JPDetailStats(
                applicants: p["applicantCount"] ?? 0,
                accepted: p["accepted"] ?? 0,
                rejected: p["rejected"] ?? 0,
                pending: p["pending"] ?? 0,
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================= JOB INFO =================
              Text("JOB INFO", style: AppTextStyles.label.copyWith(fontSize: 13)),
              const SizedBox(height: AppSpacing.md),

              JPDetailInfoSection(
                info: {
                  "Position": p["position"] ?? "-",
                  "Work Type": p["workType"] ?? "-",
                  "Location": p["location"] ?? "-",
                  if (p["salary"] != null) "Salary": p["salary"],
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================= DESCRIPTION =================
              JPDetailDescription(
                description: p["description"] ?? "No description provided.",
                requirements: List<String>.from(
                  p["requirements"] ?? [],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================= APPLICANTS =================
              JPDetailApplicantsPreview(
                postingId: p["id"],
                applicants: List<Map<String, dynamic>>.from(
                  p["applicants"] ?? [],
                ),
                onSeeAll: () => c.openApplicants(p),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================= ACTION =================
              if (isActive)
                JPClosePostingSection(
                  onClose: () async {
                    final success = await c.closePosting(p["id"]);
                    if (success) {
                      Navigator.of(context).pop();
                    }
                  },
                )
              else if (isClosed)
                JPFinalizePostingSection(
                  onFinalize: () async {
                    final success = await c.finalizePosting(p["id"]);
                    if (success) {
                      Navigator.of(context).pop();
                    }
                  },
                )
              else if (isFinalized)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Evaluation Finalized",
                          style: AppTextStyles.bodyStrong.copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),
    );
  }
}
