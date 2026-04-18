import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

class UDCandidatesPreview extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;
  final VoidCallback onSeeAll;

  const UDCandidatesPreview({
    super.key,
    required this.candidates,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final previewList =
    candidates.length > 3 ? candidates.take(3).toList() : candidates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= HEADER =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "CANDIDATES",
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                "Edit & See All",
                style: AppTextStyles.textButton,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ================= LIST =================
        Column(
          children: previewList.map((c) {
            return _CandidateTile(candidate: c);
          }).toList(),
        ),
      ],
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final Map<String, dynamic> candidate;

  const _CandidateTile({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final name = candidate["name"];
    final email = candidate["email"];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.low,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(name[0]),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.bodyStrong),
              Text(
                email,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}