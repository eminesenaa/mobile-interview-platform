import 'package:flutter/material.dart';
import 'package:interview_project/pages/hr/interviews/widgets/status_badge.dart';
import '../../../../../constants/text_styles.dart';

class HRDetailHeader extends StatelessWidget {
  final String title;
  final String status;
  final String reviewStatus;

  const HRDetailHeader({
    super.key,
    required this.title,
    required this.status,
    this.reviewStatus = "pending", // default fallback
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.title,
          ),
        ),
        StatusBadge.from(
          status: status,
          reviewStatus: reviewStatus,
        ),
      ],
    );
  }
}
