// ===================== File: ir_hr_message_section.dart =====================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class IrHrMessageSection extends StatelessWidget {
  final String title;
  final String message;
  final String sender;

  const IrHrMessageSection({
    super.key,
    required this.title,
    required this.message,
    required this.sender,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================
        // HEADER
        // =====================================================
        Row(
          children: [
            Icon(
              PhosphorIcons.chatCircleText(),
              size: 22,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // =====================================================
        // TOP DIVIDER
        // =====================================================
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.border.withOpacity(0.6),
        ),

        const SizedBox(height: AppSpacing.md),

        // =====================================================
        // MESSAGE
        // =====================================================
        Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // =====================================================
        // BOTTOM DIVIDER
        // =====================================================
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.border.withOpacity(0.4),
        ),

        const SizedBox(height: AppSpacing.md),

        // =====================================================
        // FOOTER
        // =====================================================
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                _getInitials(sender),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              "Sent by $sender",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(" ");
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
