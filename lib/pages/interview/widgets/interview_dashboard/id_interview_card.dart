// ===================== File: id_interview_card.dart =====================
// Purpose:
// Premium upcoming interview card (FINAL FIXED)
//
// Fixes:
// - Full-bleed background (no inner padding for shapes)
// - Content wrapped with padding separately
// - Join button aligned LEFT
// - Darker CTA color
// ========================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/interview_dashboard_controller.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class IdInterviewCard extends StatelessWidget {
  final Map<String, dynamic> interview;
  final TextEditingController codeCtrl = TextEditingController();

   IdInterviewCard({
    super.key,
    required this.interview,
  });

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<InterviewDashboardController>();
    
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }

    final start = parseDateTime(interview["startTime"]);
    final end = parseDateTime(interview["endTime"]);

    final dateText = controller.formatDate(start);
    final timeText = controller.formatTimeRange(start, end);


    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF020617),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      // 🔥 CLIP so shapes don't overflow
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            // ================= DECORATIVE SHAPES (FULL BLEED) =================
            Positioned(
              top: -40,
              right: -40,
              child: _circleDecoration(140),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: _circleDecoration(90),
            ),

            // ================= CONTENT =================
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= LABEL =================
                  Text(
                    "YOU'RE INVITED",
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ================= TITLE =================
                  Text(
                    interview["title"] ?? "",
                    style: AppTextStyles.headline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ================= DATE + TIME =================
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.calendar(),
                        size: AppIconSizes.sm,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        dateText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        PhosphorIcons.clock(),
                        size: AppIconSizes.sm,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        timeText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ================= INPUT =================
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: TextField(
                      controller: codeCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "ENTER - CODE",
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white54,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ================= HELPER TEXT =================
                  Text(
                    "Enter your invite code to access the interview room.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white54,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ================= JOIN BUTTON (LEFT) =================
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        final code = codeCtrl.text.trim();

                        // =======================================================
                        // 🔥 MOCK FLOW (TEMPORARY)
                        // =======================================================
                        // TODO (Backend):
                        // - Validate invite code via API
                        // - Fetch interview session
                        // - Replace this with real response

                        controller.joinInterview(code);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.topicDeepTwilight,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Join", style: AppTextStyles.button),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                            size: AppIconSizes.sm,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DECORATIVE CIRCLE =================
  Widget _circleDecoration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }
}
