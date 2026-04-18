// ===================== File: hr_upcoming_interview_detail_page.dart =====================
// Purpose:
// Upcoming Interview Detail Page (EDITABLE)
//
// Features:
// - Info card
// - Editable schedule
// - Editable candidates
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/ud_candidates_edit_page.dart';
import 'package:interview_project/pages/hr/widgets/ci_text_edit_dialog.dart';
import 'package:interview_project/pages/hr/widgets/hr_detail_header.dart';
import 'package:interview_project/pages/hr/widgets/ud_candidates_preview.dart';
import 'package:interview_project/pages/hr/widgets/upcoming_detail/ud_info_card.dart';
import 'package:interview_project/pages/hr/widgets/upcoming_detail/ud_interview_details_card.dart';

import '../../../constants/constants.dart';
import 'controllers/hr_upcoming_detail_controller.dart';

class HRUpcomingInterviewDetailPage extends StatelessWidget {
  final Map<String, dynamic> interview;

  const HRUpcomingInterviewDetailPage({
    super.key,
    required this.interview,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(HRUpcomingDetailController(interview: interview));

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
        title: const Text("Interview"),
      ),

      // ================= BODY =================
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              HRDetailHeader(
                title: controller.title.value,
                status: "upcoming",
              ),

              const SizedBox(height: AppSpacing.md),

              // ================= INFO CARD =================
              UpcomingInfoCard(
                position: controller.position.value,
                team: controller.team.value,
                candidateInfo: controller.candidateCountText.value,
                candidateSub: controller.candidateSubText.value,
                date: controller.date.value,
                day: controller.day.value,
                timeRange: controller.timeRange.value,
                duration: controller.duration.value,
                interviewId: controller.interviewId.value,
              ),

              const SizedBox(height: AppSpacing.lg),

              UDInterviewDetailsCard(
                title: controller.title.value,
                position: controller.position.value,
                date: controller.date.value,
                timeRange: controller.timeRange.value,
                onEditTitle: () {
                  Get.dialog(
                    CITextEditDialog(
                      title: "Edit Title",
                      initialValue: controller.title.value,
                      hint: "Enter interview title",
                      onSave: (val) => controller.updateTitle(val),
                    ),
                  );
                },
                onEditPosition: () {
                  Get.dialog(
                    CITextEditDialog(
                      title: "Edit Position",
                      initialValue: controller.position.value,
                      hint: "Enter position",
                      onSave: (val) => controller.updatePosition(val),
                    ),
                  );
                },
                onEditDate: () => controller.updateDate(context),
                onEditTime: () => controller.updateTime(context),
              ),

              const SizedBox(height: AppSpacing.lg),

              UDCandidatesPreview(
                candidates: controller.candidates,
                onSeeAll: () {
                  Get.to(() => UDCandidatesEditPage(
                    candidates: controller.candidates,
                  ));
                },
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),
    );
  }
}
