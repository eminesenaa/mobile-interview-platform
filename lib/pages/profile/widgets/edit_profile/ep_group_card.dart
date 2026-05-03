// ===================== File: ep_group_card.dart =====================
// Purpose:
// Reusable grouped card with title + divider items
//
// Features:
// - Section title
// - Auto divider between children
// - Clean grouped layout
// =====================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class EpGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const EpGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= TITLE =================
        Text(
          title,
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
            letterSpacing: 1,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ================= CARD =================
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: children[index],
                  ),

                  // Divider (except last)
                  if (index != children.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.border.withOpacity(0.7),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
