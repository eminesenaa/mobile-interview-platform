// ===================== File: jd_description_section.dart =====================
// Purpose:
// Displays job description content
//
// Features:
// - Section title
// - Description text
// - Optional bullet points
// ==========================================================================

import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';

class JdDescriptionSection extends StatelessWidget {
  final Map<String, dynamic> job;

  const JdDescriptionSection({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> requirements =
        List<String>.from(job["requirements"] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= TITLE =================
        Text(
          "Description".toUpperCase(),
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ================= MAIN TEXT =================
        if (job["description"] != null)
          Text(
            job["description"],
            style: AppTextStyles.body,
          ),

        const SizedBox(height: AppSpacing.sm),

        // ================= REQUIREMENTS TITLE =================
        if (requirements.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),

          Text(
            "REQUIREMENTS",
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
        ],

        // ================= BULLET LIST =================
        ...requirements.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• "),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
