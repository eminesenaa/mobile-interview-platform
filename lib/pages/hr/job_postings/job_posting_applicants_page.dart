// ===================== File: job_posting_applicants_page.dart =====================
// Purpose:
// Displays all applicants for a job posting
//
// Features:
// - Filter (All / Accepted / Rejected / Pending)
// - Search (UI ready)
// - Grouped view (Pending first)
// - Reusable ApplicantCard
//
// IMPORTANT:
// - Uses HrJobPostingsController
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../controllers/hr_job_postings_controller.dart';
import 'widgets/job_posting_applicants/jp_applicants_filter_bar.dart';
import 'widgets/job_posting_applicants/jp_applicants_list_section.dart';
import 'widgets/job_posting_applicants/jp_applicants_search.dart';

// Widgets


class JobPostingApplicantsPage extends StatefulWidget {
  final Map<String, dynamic> posting;

  const JobPostingApplicantsPage({
    super.key,
    required this.posting,
  });

  @override
  State<JobPostingApplicantsPage> createState() =>
      _JobPostingApplicantsPageState();
}

class _JobPostingApplicantsPageState extends State<JobPostingApplicantsPage> {
  final c = Get.find<HrJobPostingsController>();

  String selectedFilter = "all";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final rawApplicants = widget.posting["applicants"];

    final allApplicants = rawApplicants is List
        ? List<Map<String, dynamic>>.from(rawApplicants)
        : <Map<String, dynamic>>[];

    /// ================= FILTERING =================

    final filteredApplicants = c.searchApplicants(allApplicants, searchQuery);

    final pending =
        filteredApplicants.where((a) => a["status"] == "pending").toList();

    final accepted =
        filteredApplicants.where((a) => a["status"] == "accepted").toList();

    final rejected =
        filteredApplicants.where((a) => a["status"] == "rejected").toList();

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
        title: const Text("All Applicants"),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= FILTER =================
            JPApplicantsFilterBar(
              selected: selectedFilter,
              onChanged: (v) {
                setState(() => selectedFilter = v);
              },
              allCount: filteredApplicants.length,
              acceptedCount: accepted.length,
              rejectedCount: rejected.length,
              pendingCount: pending.length,
            ),

            const SizedBox(height: AppSpacing.md),

            /// ================= SEARCH =================
            JPApplicantsSearch(
              value: searchQuery,
              onChanged: (v) {
                setState(() => searchQuery = v);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            /// ================= CONTENT =================
            _buildContent(
              pending: pending,
              accepted: accepted,
              rejected: rejected,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= CONTENT BUILDER =================
  Widget _buildContent({
    required List<Map<String, dynamic>> pending,
    required List<Map<String, dynamic>> accepted,
    required List<Map<String, dynamic>> rejected,
  }) {
    /// 🔥 ALL VIEW (default)
    if (selectedFilter == "all") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pending.isNotEmpty)
            JPApplicantsListSection(
              postingId: widget.posting["id"],
              title: "Pending Review",
              applicants: pending,
            ),
          const SizedBox(height: AppSpacing.xl),
          if (accepted.isNotEmpty)
            JPApplicantsListSection(
              postingId: widget.posting["id"],
              title: "Accepted",
              applicants: accepted,
            ),
          const SizedBox(height: AppSpacing.xl),
          if (rejected.isNotEmpty)
            JPApplicantsListSection(
              postingId: widget.posting["id"],
              title: "Rejected",
              applicants: rejected,
            ),
        ],
      );
    }

    /// 🔥 FILTERED VIEW
    List<Map<String, dynamic>> list;

    switch (selectedFilter) {
      case "accepted":
        list = accepted;
        break;
      case "rejected":
        list = rejected;
        break;
      case "pending":
        list = pending;
        break;
      default:
        list = pending;
    }

    return JPApplicantsListSection(
      postingId: widget.posting["id"],
      title: selectedFilter,
      applicants: list,
    );
  }
}
