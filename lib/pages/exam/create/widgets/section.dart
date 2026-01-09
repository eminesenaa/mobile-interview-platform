import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';

class Section extends StatelessWidget {
  final String title;
  final Widget child;
  final String? note;

  const Section({
    super.key,
    required this.title,
    required this.child,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 TITLE
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary,
            ),
          ),

          // 🔹 NOTE (OPTIONAL)
          if (note != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              note!,
              style: AppTextStyles.bodySmall,
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // 🔹 CONTENT
          child,
        ],
      ),
    );
  }
}
