import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../../constants/constants.dart';
import '../../../../models/interview_result.dart';
import '../../controllers/hr_reviewed_detail_controller.dart';
import 'widgets/rd_candidate_card.dart';
import 'widgets/rd_candidates_filter_bar.dart';
import 'widgets/rd_candidates_group_label.dart';
import 'widgets/rd_candidates_header.dart';

class HrAllCandidatesPage extends StatelessWidget {
  const HrAllCandidatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// 🔥 SAME CONTROLLER (IMPORTANT)
    final c = Get.find<HrReviewedDetailController>();

    return Scaffold(
      backgroundColor: AppColors.background,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: const Text("All Candidates"),
      ),

      /// ================= BODY =================
      body: Obx(() {
        final all = c.results;
        final filtered = c.filteredResults;

        final accepted =
        filtered.where((e) => e.decision == InterviewDecisionStatus.accepted).toList();

        final rejected =
        filtered.where((e) => e.decision == InterviewDecisionStatus.rejected).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= FILTER =================
              RdCandidatesFilterBar(
                selected: c.selectedFilter.value,
                total: all.length,
                accepted: c.acceptedCount.value,
                rejected: c.rejectedCount.value,
                onChanged: c.changeFilter,
              ),

              const SizedBox(height: AppSpacing.md),

              /// ================= HEADER =================
              RdCandidatesHeader(
                showing: filtered.length,
                total: all.length,
                onSort: c.sortByScoreDesc,
              ),

              const SizedBox(height: AppSpacing.md),

              /// ================= LIST =================
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      "No candidates found",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else ...[
                /// ================= ACCEPTED =================
                if (accepted.isNotEmpty) ...[
                  const RdCandidatesGroupLabel(
                    title: "Accepted",
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Column(
                    children: List.generate(accepted.length, (index) {
                      final cnd = accepted[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: RdCandidateCard(
                          rank: index + 1,
                          name: cnd.displayName,
                          initials: cnd.initials,
                          score: cnd.score,
                          decision: cnd.decision.name,
                          onTap: () => c.openCandidateDetail(cnd),
                        ),
                      );
                    }),
                  ),
                ],

                /// ================= REJECTED =================
                if (rejected.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const RdCandidatesGroupLabel(
                    title: "Rejected",
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Column(
                    children: List.generate(rejected.length, (index) {
                      final cnd = rejected[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: RdCandidateCard(
                          rank: accepted.length + index + 1,
                          name: cnd.displayName,
                          initials: cnd.initials,
                          score: cnd.score,
                          decision: cnd.decision.name,
                          onTap: () => c.openCandidateDetail(cnd),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ],
          ),
        );
      }),
    );
  }
}
