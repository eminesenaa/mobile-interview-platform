// ===================== File: hr_interview_list_page.dart =====================
// Purpose:
// Generic page for "See All" sections
//
// Behavior:
// - Receives section type (today / needsReview / reviewed)
// - Dynamically updates AppBar title
// - Displays full list using same interview cards
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/widgets/hr_interview_card.dart';

import '../../../constants/constants.dart';
import 'controllers/hr_interviews_controller.dart';

class HRInterviewListPage extends StatelessWidget {
  final String sectionKey;

  const HRInterviewListPage({
    super.key,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HRInterviewsController>();

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
        title: Text(
          _getTitle(),
          style: AppTextStyles.title,
        ),
      ),

      // ================= BODY =================
      body: Obx(() {
        final list = _getList(controller);

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final interview = list[index];

            return HRInterviewCard(
              interview: interview,
              isToday: sectionKey == "today",
              onTap: () => controller.openInterviewDetail(interview),
            );
          },
        );
      }),
    );
  }

  // ===============================
  // GET LIST BASED ON SECTION
  // ===============================
  RxList<Map<String, dynamic>> _getList(HRInterviewsController controller) {
    switch (sectionKey) {
      case "today":
        return controller.todayInterviews;

      case "review":
        return controller.needsReviewInterviews;

      case "reviewed":
        return controller.reviewedInterviews;

      default:
        return <Map<String, dynamic>>[].obs;
    }
  }

  // ===============================
  // DYNAMIC TITLE
  // ===============================
  String _getTitle() {
    final key = sectionKey.toLowerCase();

    switch (key) {
      case "today":
        return "Today's Interviews";

      case "review":
        return "Needs Review";

      case "reviewed":
        return "Reviewed Interviews";

      default:
        return "Interviews";
    }
  }
}
