import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';
import 'package:intl/intl.dart';

class RdFinalDecisionSection extends StatelessWidget {
  final String decision;
  final String date; // raw string (DateTime string geliyor varsayım)
  final String message;

  const RdFinalDecisionSection({
    super.key,
    required this.decision,
    required this.date,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = decision == "accepted";

    /// 🔥 DATE FORMAT FIX
    String formattedDate = date;
    try {
      final parsed = DateTime.parse(date);
      formattedDate = DateFormat("MMM d, yyyy 'at' h:mm a").format(parsed);
    } catch (_) {
      // fallback 그대로 bırak
    }

    final baseColor = isAccepted ? AppColors.success : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= LABEL =================
        Text(
          "FINAL DECISION",
          style: AppTextStyles.label.copyWith(fontSize: 12),
        ),

        const SizedBox(height: AppSpacing.md),

        /// ================= HEADER =================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔥 BIG ICON
            Icon(
              isAccepted
                  ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                  : PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
              color: baseColor,
              size: 34,
            ),

            const SizedBox(width: AppSpacing.md),

            /// 🔥 TEXT BLOCK
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAccepted ? "Accepted" : "Rejected",
                  style: AppTextStyles.title.copyWith(
                    color: baseColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Decision sent · $formattedDate",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        /// ================= MESSAGE BOX =================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: baseColor.withOpacity(0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 LABEL
              Text(
                "MESSAGE SENT",
                style: AppTextStyles.bodySmall.copyWith(
                  color: baseColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              /// 🔥 CONTENT
              Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
