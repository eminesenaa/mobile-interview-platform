// ===================== File: ap_resume_section.dart =====================
// Purpose:
// Resume upload UI (Premium version)
//
// Features:
// - Full width container
// - Soft gray background
// - Dashed border
// - Centered content
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../../../constants/constants.dart';

class ApResumeSection extends StatelessWidget {
  final VoidCallback onTap;

  const ApResumeSection({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(AppRadius.lg),
          dashPattern: const [6, 4],
          strokeWidth: 1.5,
          color: AppColors.border,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ================= ICON =================
              Icon(
                PhosphorIcons.filePdf(),
                size: 40,
                color: AppColors.textMuted,
              ),

              const SizedBox(height: AppSpacing.sm),

              // ================= TITLE =================
              Text(
                "Upload your résumé",
                style: AppTextStyles.bodyStrong,
              ),

              const SizedBox(height: AppSpacing.xs),

              // ================= SUBTEXT =================
              Text(
                "PDF · Max 10 MB",
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
