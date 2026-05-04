import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class ResultsCompletedInterviews extends StatelessWidget {
  final List<Map<String, dynamic>> interviews;
  final Function(Map<String, dynamic>) onTap;

  const ResultsCompletedInterviews({
    super.key,
    required this.interviews,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visible =
        interviews.length > 5 ? interviews.take(5).toList() : interviews;
    return Column(
      children: visible.map((i) {
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.briefcase()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i["title"], style: AppTextStyles.bodyStrong),
                      Text("${i["date"]} · ${i["count"]} candidates",
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Text("${i["avg"]}", style: AppTextStyles.bodyStrong),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
