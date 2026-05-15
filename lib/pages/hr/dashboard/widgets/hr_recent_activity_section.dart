// ===================== File: hr_recent_activity_section.dart =====================
// Purpose:
// Displays recent interview activities (INTERVIEW-BASED)
//
// IMPORTANT CHANGE:
// - Now based on interviews (NOT candidates)
// - Backend-ready structure
//
// Activity Types:
// - Pending → waiting for review
// - Upcoming → scheduled interview
//
// TODO:
// Replace mock data with backend (Firestore / API)
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/interviews/widgets/status_badge.dart';
import '../../../../constants/constants.dart';
import '../../controllers/hr_dashboard_controller.dart';
import '../../interviews/needs_review/hr_needs_review_detail_page.dart';
import '../../interviews/ongoing/hr_ongoing_interview_detail_page.dart';
import '../../interviews/upcoming/hr_upcoming_interview_detail_page.dart';

class HRRecentActivitySection extends StatelessWidget {
  const HRRecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HRDashboardController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================
        // TITLE
        // ===============================
        Text(
          "RECENT ACTIVITY",
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ===============================
        // CONTAINER (REACTIVE)
        // ===============================
        Obx(() {
          if (controller.activities.isEmpty) {
            return _EmptyActivityState();
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.low,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Column(
                children: [
                  ...controller.activities.map((activity) {
                    final isLast = activity == controller.activities.last;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleNavigation(activity),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: _ActivityItem(
                                type: activity["type"]!,
                                title: activity["title"]!,
                                subtitle: activity["subtitle"]!,
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                indent: AppSpacing.md,
                                endIndent: AppSpacing.md,
                                color: AppColors.border.withOpacity(0.5),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _handleNavigation(Map<String, dynamic> activity) {
    final data = Map<String, dynamic>.from(activity["data"]);
    data["id"] = activity["id"]; // Ensure ID is present

    final status = data["status"] ?? "scheduled";

    if (status == "active" || status == "ongoing") {
      Get.to(() => HROngoingInterviewDetailPage(interview: data));
    } else if (status == "completed") {
      Get.to(() => HrNeedsReviewDetailPage(interview: data));
    } else {
      Get.to(() => HRUpcomingInterviewDetailPage(interview: data));
    }
  }
}

/// ===============================
/// EMPTY STATE
/// ===============================
class _EmptyActivityState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.low,
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            color: AppColors.textMuted.withOpacity(0.3),
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "No recent activity",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// SINGLE ACTIVITY ITEM
/// ===============================
class _ActivityItem extends StatelessWidget {
  final String type; // pending | upcoming
  final String title;
  final String subtitle;

  const _ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ===============================
        // TEXT
        // ===============================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyStrong,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // ===============================
        // STATUS CHIP
        // ===============================
        StatusBadge.from(
          status: type == "upcoming" ? "upcoming" : "completed",
          reviewStatus: type == "pending" ? "pending" : "reviewed",
        ),

        const SizedBox(width: AppSpacing.xs),

        Icon(
          Icons.chevron_right,
          size: 16,
          color: AppColors.textMuted.withOpacity(0.5),
        ),
      ],
    );
  }
}

