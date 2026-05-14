// ===================== File: hr_interviews_page.dart =====================
// Purpose:
// Main HR Interviews Page
//
// Structure:
// - AppBar (simple, centered title)
// - Stats row (total / ongoing / done)
// - Sections:
//    • TODAY
//    • NEEDS REVIEW
//    • REVIEWED
//
// Uses:
// - HRInterviewsController
// - HRInterviewSection
// - HRInterviewCard
//
// ========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../controllers/hr_interviews_controller.dart';

// widgets
import 'widgets/hr_interview_section.dart';

class HRInterviewsPage extends StatelessWidget {
  const HRInterviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HRInterviewsController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ===============================
      // APP BAR
      // ===============================
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
          "Interviews",
          style: AppTextStyles.title,
        ),
      ),

      // ===============================
      // BODY
      // ===============================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================
              // STATS ROW
              // ===============================
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: "ALL",
                          value: controller.totalCount.value.toString(),
                          borderColor: AppColors.skyReflection,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(
                          label: "ONGOING",
                          value: controller.ongoingCount.value.toString(),
                          borderColor: AppColors.strawberryRed,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(
                          label: "DONE",
                          value: controller.completedCount.value.toString(),
                          borderColor: AppColors.darkCyan,
                        ),
                      ),
                    ],
                  )),

              const SizedBox(height: AppSpacing.xl),

              // ===============================
              // TODAY
              // ===============================
              Obx(() => HRInterviewSection(
                    title: "Today",
                    sectionKey: "today",
                    interviews: controller.todayInterviews.toList(),
                  )),

              const SizedBox(height: AppSpacing.xl),

              // ===============================
              // NEEDS REVIEW
              // ===============================
              Obx(() => HRInterviewSection(
                    title: "Needs Review",
                    sectionKey: "review",
                    interviews: controller.needsReviewInterviews.toList(),
                  )),

              const SizedBox(height: AppSpacing.xl),

              // ===============================
              // REVIEWED
              // ===============================
              Obx(() => HRInterviewSection(
                    title: "Reviewed",
                    sectionKey: "reviewed",
                    interviews: controller.reviewedInterviews.toList(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================
// SMALL STAT CARD (TOP)
// ===============================
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color borderColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor.withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: borderColor.withOpacity(0.6), // 🔥 soft tone
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 22,
              color: borderColor, // 🔥 main strong color
            ),
          ),
        ],
      ),
    );
  }
}
