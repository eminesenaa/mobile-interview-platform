// ===================== File: jp_publish_button.dart =====================
// Purpose:
// Submit button for posting job
// ========================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class JPPublishButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isEnabled;

  const JPPublishButton({
    super.key,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.primary : AppColors.textMuted.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Center(
            child: Text(
              "Publish",
              style: AppTextStyles.bodyStrong.copyWith(
                color: isEnabled ? Colors.white : Colors.white.withOpacity(0.6),
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
