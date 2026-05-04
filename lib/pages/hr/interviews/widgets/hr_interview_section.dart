// ===================== File: hr_interview_section.dart =====================
// Purpose:
// Reusable section for HR Interviews Page
//
// Features:
// - Section title (e.g. TODAY, NEEDS REVIEW, REVIEWED)
// - Optional "See All"
// - Shows max 3 items
// - Uses HRInterviewCard
//
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../controllers/hr_interviews_controller.dart';
import '../hr_interview_list_page.dart';
import 'hr_interview_card.dart';

class HRInterviewSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> interviews;

  /// Section key for navigation (today / review / reviewed)
  final String sectionKey;

  const HRInterviewSection({
    super.key,
    required this.title,
    required this.interviews,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HRInterviewsController>();

    if (interviews.isEmpty) return const SizedBox();

    final visibleList =
        interviews.length > 3 ? interviews.take(3).toList() : interviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================
        // HEADER (TITLE + SEE ALL)
        // ===============================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1,
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => HRInterviewListPage(
                  sectionKey: sectionKey,
                ));
              },
              child: Text(
                "See all",
                style: AppTextStyles.textButton,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ===============================
        // LIST
        // ===============================
        Column(
          children: visibleList.map((interview) {
            return HRInterviewCard(
              interview: interview,
              isToday: sectionKey == "today",
              onTap: () => controller.openInterviewDetail(interview),
            );
          }).toList(),
        ),
      ],
    );
  }
}
