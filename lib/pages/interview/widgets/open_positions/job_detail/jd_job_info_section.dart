// ===================== File: jd_job_info_section.dart =====================
// Purpose:
// Displays structured job information (Position, Work Type, Location, Salary)
//
// Features:
// - Section title
// - Multiple info rows
// - Reusable row component
//
// IMPORTANT:
// - Uses Map<String, dynamic>
// - Backend-ready
// ========================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';
import 'jd_info_row.dart';

class JdJobInfoSection extends StatelessWidget {
  final Map<String, dynamic> job;

  const JdJobInfoSection({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= TITLE =================
        Text(
          "Job Info".toUpperCase(),
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ================= INFO ROWS =================
        JdInfoRow(
          icon: Icons.work_outline,
          label: "Position",
          value: job["title"] ?? job["jobTitle"] ?? "",
        ),

        JdInfoRow(
          icon: Icons.business_center_outlined,
          label: "Work Type",
          value: job["workType"] ?? "",
        ),

        JdInfoRow(
          icon: Icons.location_on_outlined,
          label: "Location",
          value: job["location"] ?? "",
        ),

        if (job["salary"] != null)
          JdInfoRow(
            icon: Icons.attach_money,
            label: "Salary",
            value: job["salary"],
          ),
      ],
    );
  }
}
