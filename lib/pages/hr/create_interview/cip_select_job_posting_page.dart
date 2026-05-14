// ===================== File: cip_select_job_posting_page.dart =====================
// Purpose:
// Page for selecting a READY job posting before creating an interview.
//
// FLOW:
// - Shows only READY postings
// - User selects one → (navigation handled elsewhere)
//
// Structure:
// - Header (title + description)
// - Search bar
// - List header (count + sort)
// - List of postings
// - Empty state
//
// IMPORTANT:
// - No mock data here
// - No navigation logic here
// - Data comes from controller (GetX)
//
// TODO (Controller):
// - Provide readyPostings list
// - Provide search filtering
// - Provide stats (applicants / accepted / rejected)
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../constants/constants.dart';
import '../../../models/job_posting.dart';

import '../controllers/create_interview_controller.dart';
import 'create_interview_page.dart';
import 'widgets/create_interview_select_posting/cip_empty_state.dart';
import 'widgets/create_interview_select_posting/cip_job_posting_card.dart';
import 'widgets/create_interview_select_posting/cip_list_header.dart';
import 'widgets/create_interview_select_posting/cip_search_bar.dart';

class CipSelectJobPostingPage extends StatelessWidget {
  const CipSelectJobPostingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateInterviewController>();

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
          "Create Interview",
          style: AppTextStyles.title,
        ),
      ),

      // ===================== BODY =====================
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SEARCH =================
              CipSearchBar(
                onChanged: controller.setSearchQuery,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ================= LIST =================
              Expanded(
                child: Obx(() {
                  final List<JobPosting> postings = controller.filteredPostings;

                  // ================= EMPTY STATE =================
                  if (postings.isEmpty) {
                    return const CipEmptyState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= LIST HEADER =================
                      CipListHeader(
                        count: postings.length,
                        onSortTap: () {
                          // TODO: sort logic (controller)
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ================= LIST VIEW =================
                      Expanded(
                        child: ListView.separated(
                          itemCount: postings.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final posting = postings[index];

                            return CipJobPostingCard(
                              posting: posting,

                              // ================= STATS =================
                              // TODO: replace with real computed values
                              applicants:
                                  controller.getApplicantsCount(posting.id),
                              accepted: controller.getAcceptedCount(posting.id),
                              rejected: controller.getRejectedCount(posting.id),

                              // ================= ACTION =================
                              onTap: () {
                                Get.to(
                                  () => const CreateInterviewPage(),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
