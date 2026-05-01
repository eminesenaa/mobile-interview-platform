// ===================== File: ad_hr_message_card.dart =====================
// Purpose:
// Displays HR message or feedback
// ========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class AdHrMessageCard extends StatelessWidget {
  final String title;
  final String message;

  const AdHrMessageCard({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.chatText(), size: 20, color: AppColors.textMuted,),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTextStyles.label.copyWith(
                fontSize: 13,
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
