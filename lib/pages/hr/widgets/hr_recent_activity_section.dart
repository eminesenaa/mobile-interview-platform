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
import 'package:interview_project/pages/hr/widgets/status_badge.dart';
import '../../../constants/constants.dart';
import '../controllers/hr_dashboard_controller.dart';

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
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ===============================
        // CONTAINER (LIKE DESIGN)
        // ===============================
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.low,
          ),
          child: Column(
            children: [
              ...controller.activities.map((activity) {
                return Column(
                  children: [
                    _ActivityItem(
                      type: activity["type"]!,
                      title: activity["title"]!,
                      subtitle: activity["subtitle"]!,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // divider (last hariç)
                    if (activity != controller.activities.last)
                      Column(
                        children: [
                          Divider(
                            height: 1,
                            color: AppColors.border.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
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

        // ===============================
        // STATUS CHIP
        // ===============================
        StatusBadge.from(
          status: type == "upcoming" ? "upcoming" : "completed",
          reviewStatus: type == "pending" ? "pending" : "reviewed",
        ),
      ],
    );
  }
}

