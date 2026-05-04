import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';
import '/../../../../models/interview_result.dart';
import 'rd_candidate_card.dart';

class RdTopCandidatesSection extends StatelessWidget {
  final List<InterviewResult> candidates;
  final Function(InterviewResult) onTap;

  const RdTopCandidatesSection({
    super.key,
    required this.candidates,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// 🔥 Only show top 5
    final visibleCandidates =
        candidates.length > 5 ? candidates.take(5).toList() : candidates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= LABEL =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "TOP CANDIDATES",
              style: AppTextStyles.label.copyWith(fontSize: 12),
            ),
            Text(
              "Top ${visibleCandidates.length} by score",
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        /// ================= EMPTY STATE =================
        if (candidates.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Text(
                "No candidates available",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          )
        else

          /// ================= LIST =================
          Column(
            children: List.generate(visibleCandidates.length, (index) {
              final c = visibleCandidates[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: RdCandidateCard(
                  rank: index + 1,
                  name: c.displayName,
                  initials: c.initials,
                  score: c.score,
                  decision: c.decision.name,
                  onTap: () => onTap(c),
                ),
              );
            }),
          ),
      ],
    );
  }
}
