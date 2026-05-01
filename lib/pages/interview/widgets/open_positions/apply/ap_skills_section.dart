// ===================== File: ap_skills_section.dart =====================
// Purpose:
// Skills input + chip list
//
// Features:
// - Dynamic skill chips
// - Box-style input field (premium UI)
// - Add button (custom styled)
// - Enter key support
// ========================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';
import 'ap_section_title.dart';
import 'ap_skill_chip.dart';

class ApSkillsSection extends StatelessWidget {
  final List<String> skills;
  final TextEditingController skillCtrl;
  final VoidCallback onAdd;
  final Function(String) onRemove;

  const ApSkillsSection({
    super.key,
    required this.skills,
    required this.skillCtrl,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= TITLE =================
        const ApSectionTitle(title: "Skills"),
        const SizedBox(height: AppSpacing.md),

        // ================= CHIPS =================
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ...skills.map(
              (s) => ApSkillChip(
                skill: s,
                onRemove: () => onRemove(s),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ================= INPUT BOX =================
        Row(
          children: [
            // ================= INPUT BOX =================
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: skillCtrl,
                  onSubmitted: (_) => onAdd(),
                  style: AppTextStyles.bodyStrong,
                  decoration: InputDecoration(
                    hintText: "Type a skill...",
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // ================= ADD BUTTON =================
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onAdd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    "Add",
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        // ================= HELPER TEXT =================
        Text(
          "Press Enter or click Add to add a skill",
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
