import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

/// ===================== CLOSE POSTING =====================
/// Redesigned:
/// - Subtle warning (icon + muted text)
/// - Footer-style layout
/// - Filled soft-danger button
/// =========================================================

class JPClosePostingSection extends StatelessWidget {
  final VoidCallback onClose;

  const JPClosePostingSection({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= BUTTON (FOOTER STYLE) =================
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08), // 🔥 soft red fill
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.error.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.lock(PhosphorIconsStyle.fill),
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  "Close Posting",
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// ================= WARNING TEXT =================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Closing this posting will stop new applications. You can still review existing candidates.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
