// ===================== File: ci_questions_actions.dart =====================
// Purpose:
// Question selection actions (NO TOGGLE)
//
// UI:
// - Label (QUESTIONS)
// - Two action buttons
//
// Behavior:
// - Shows snackbar (mock)
// - Backend will replace logic later
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../select_questions_page.dart';
import '/../../../../constants/constants.dart';

class CIQuestionsActions extends StatelessWidget {
  const CIQuestionsActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= LABEL =================
        Text(
          "QUESTIONS",
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ================= BUTTON ROW =================
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                title: "From Database",
                isPrimary: true,
                onTap: () async {
                  final selectedIds = await Get.to(() => const SelectQuestionsPage());

                  if (selectedIds != null) {
                    // TODO: burada selectedIds’i interview state’ine ekle
                    print(selectedIds);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ActionButton(
                title: "Manual Add",
                isPrimary: false,
                onTap: () {
                  Get.snackbar(
                    "Coming Soon",
                    "Manual question creation will be added",
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ===============================
/// SINGLE BUTTON
/// ===============================
class _ActionButton extends StatelessWidget {
  final String title;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyStrong.copyWith(
            color: isPrimary ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
