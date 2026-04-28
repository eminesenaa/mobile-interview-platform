import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/constants.dart';
import '../../controllers/hr_job_postings_controller.dart';
import 'jp_applicant_card.dart';

/// ===================== APPLICANTS PREVIEW =====================
/// Shows max 3 candidates + See All
/// ===============================================================

class JPDetailApplicantsPreview extends StatelessWidget {
  final String postingId;
  final List<Map<String, dynamic>> applicants;
  final VoidCallback onSeeAll;

  const JPDetailApplicantsPreview({
    super.key,
    required this.postingId,
    required this.applicants,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrJobPostingsController>();
    final preview = applicants.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "APPLICANTS",
              style: AppTextStyles.label.copyWith(fontSize: 13),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text("See all",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                  )),
            )
          ],
        ),
        const SizedBox(height: 10),
        ...preview.map((a) {
          final user = controller.getUserByName(a["name"]);

          final subtitle = user != null
              ? "${user.university ?? ''} · ${user.department ?? ''}"
              : "";

          return GestureDetector(
            onTap: () {
              controller.openCandidateDetail(
                postingId,
                a["userId"] ?? "",
              );
            },
            child: JPApplicantCard(
              name: a["name"] ?? "",
              subtitle: subtitle,
              status: a["status"] ?? "pending",
            ),
          );
        }),
      ],
    );
  }
}
