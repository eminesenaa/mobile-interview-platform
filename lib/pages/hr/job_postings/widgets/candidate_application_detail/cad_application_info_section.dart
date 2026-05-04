// ===================== FILE: cad_application_info_section.dart =====================
// Purpose:
// Displays candidate application info (clean & minimal)
//
// Uses:
// - JobApplication + User snapshot data
//
// Shows:
// - Position
// - University
// - Department
// - Grade (optional)
//
// Design:
// - Icon + label + value
// - Soft divider between rows
// ================================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

class CADApplicationInfoSection extends StatelessWidget {
  final String position;
  final String university;
  final String department;
  final String? grade;

  const CADApplicationInfoSection({
    super.key,
    required this.position,
    required this.university,
    required this.department,
    this.grade,
  });

  @override
  Widget build(BuildContext context) {
    return _card(
      Column(
        children: [
          _row(
            PhosphorIcons.briefcase(),
            "Position",
            position,
          ),

          _divider(),

          _row(
            PhosphorIcons.graduationCap(),
            "University",
            university,
          ),

          _divider(),

          _row(
            PhosphorIcons.bookOpen(),
            "Department",
            department,
          ),

          /// 🔥 optional
          if (grade != null) ...[
            _divider(),
            _row(
              PhosphorIcons.star(),
              "Grade",
              grade!,
            ),
          ],
        ],
      ),
    );
  }

  /// ================= ROW =================
  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          /// ICON BOX (soft background)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyStrong,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= DIVIDER =================
  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border.withOpacity(0.5),
    );
  }

  /// ================= CARD =================
  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
