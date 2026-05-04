// ===================== File: exam_home_header.dart =====================
// Purpose:
// Top header section for Exam Home Page
//
// Features:
// - Title (strong entry point)
// - Subtitle (guidance text)
// - Clean spacing (Apple-like)
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class ExamHomeHeader extends StatelessWidget {
  const ExamHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= TITLE =================
          Text(
            "Ready to test yourself?",
            style: AppTextStyles.headline.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // ================= SUBTITLE =================
          Text(
            "Choose how you want to practice today.",
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
