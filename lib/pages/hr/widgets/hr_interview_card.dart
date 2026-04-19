// ===================== File: hr_interview_card.dart =====================
// Purpose:
// Reusable Interview Card for HR Interviews Page
//
// Features:
// - Status badge (Upcoming / Ongoing / Needs Review / Reviewed)
// - Left accent color
// - Time + candidate count
// - Clean, modern UI
//
// ======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/hr_needs_review_detail_page.dart';
import 'package:interview_project/pages/hr/hr_upcoming_interview_detail_page.dart';
import 'package:interview_project/pages/hr/widgets/status_badge.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../constants/constants.dart';
import '../hr_ongoing_interview_detail_page.dart';

class HRInterviewCard extends StatelessWidget {
  final Map<String, dynamic> interview;
  final VoidCallback onTap;
  final bool isToday;

  const HRInterviewCard({
    super.key,
    required this.interview,
    required this.onTap,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final status = interview["status"];
    final reviewStatus = interview["reviewStatus"];

    return GestureDetector(
      onTap: () {
        final status = interview["status"];
        final reviewStatus = interview["reviewStatus"];

        // ===============================
        // ONGOING
        // ===============================
        if (status == "ongoing") {
          Get.to(() => HROngoingInterviewDetailPage(
                interview: interview,
              ));
          return;
        }

        // ===============================
        // UPCOMING
        // ===============================
        if (status == "upcoming") {
          Get.to(() => HRUpcomingInterviewDetailPage(
                interview: interview,
              ));
          return;
        }

        // ===============================
        // NEEDS REVIEW
        // ===============================
        if (status == "completed" && reviewStatus == "pending") {
          Get.to(() => HrNeedsReviewDetailPage(
                interview: interview,
              ));
          return;
        }

        // ===============================
        // REVIEWED
        // ===============================
        if (status == "completed" && reviewStatus == "reviewed") {
          Get.snackbar("TODO", "Reviewed detail page");
          return;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.low,
        ),
        child: Row(
          children: [
            // ===============================
            // LEFT ACCENT BAR
            // ===============================
            Container(
              width: 4,
              height: 90,
              decoration: BoxDecoration(
                color: StatusMapper.map(
                  status: status,
                  reviewStatus: reviewStatus,
                ).color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // ===============================
            // CONTENT
            // ===============================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // TITLE + BADGE
                    // =========================
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            interview["title"],
                            style: AppTextStyles.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatusBadge.from(
                          status: status,
                          reviewStatus: reviewStatus,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // =========================
                    // POSITION
                    // =========================
                    Text(
                      interview["position"],
                      style: AppTextStyles.bodySmall,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // =========================
                    // FOOTER (TIME + CANDIDATES)
                    // =========================
                    Row(
                      children: [
                        Icon(
                          isToday
                              ? PhosphorIcons.clock()
                              : PhosphorIcons.calendar(),
                          size: AppIconSizes.sm,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          isToday
                              ? "${interview["time"]} - ${interview["endTime"]}"
                              : _formatDate(interview["date"]),
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          PhosphorIcons.users(),
                          size: AppIconSizes.sm,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "${interview["candidateCount"]} candidates",
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(String date) {
  final d = DateTime.parse(date);

  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  return "${months[d.month - 1]} ${d.day}";
}
