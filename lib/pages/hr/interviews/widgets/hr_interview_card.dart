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
import 'package:interview_project/models/interview.dart';
import 'package:interview_project/pages/hr/interviews/widgets/status_badge.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../constants/constants.dart';

class HRInterviewCard extends StatelessWidget {
  final Interview interview;
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
    final status = interview.status;
    final reviewStatus = interview.reviewStatus;

    return GestureDetector(
      onTap: onTap,
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
                            interview.title,
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
                      interview.position,
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
                              ? "${DateFormat('HH:mm').format(interview.startTime)} - ${DateFormat('HH:mm').format(interview.endTime)}"
                              : DateFormat('MMM dd').format(interview.startTime),
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
                          "${interview.candidateIds.length} candidates",
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
