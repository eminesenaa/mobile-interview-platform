// ===================== File: is_step_item.dart =====================
// Purpose:
// Displays single step item with number badge + rich text description
// ==================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';

class IsStepItem extends StatelessWidget {
  final int index;
  final TextSpan richText;

  const IsStepItem({
    super.key,
    required this.index,
    required this.richText, // ✅ FIX: text değil richText
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= NUMBER BADGE =================
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Text(
            "$index",
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // ================= TEXT =================
        Expanded(
          child: RichText(
            text: richText,
          ),
        ),
      ],
    );
  }
}
