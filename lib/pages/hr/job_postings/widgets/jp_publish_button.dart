// ===================== File: jp_publish_button.dart =====================
// Purpose:
// Submit button for posting job
//
// Design:
// - Full width
// - Rounded
// - Strong CTA
// ========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class JPPublishButton extends StatelessWidget {
  final VoidCallback onTap;

  const JPPublishButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(
          child: Text(
            "Publish",
            style: AppTextStyles.bodyStrong.copyWith(
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
