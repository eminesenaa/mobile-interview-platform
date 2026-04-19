import 'package:flutter/material.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/text_styles.dart';
import 'od_candidate_tile.dart';

class OngoingCandidateSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> candidates;

  const OngoingCandidateSection({
    super.key,
    required this.title,
    required this.candidates,
  });

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              candidates.length.toString(),
              style: AppTextStyles.bodySmall,
            )
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Column(
          children: candidates.map((c) {
            return OngoingCandidateTile(candidate: c);
          }).toList(),
        )
      ],
    );
  }
}