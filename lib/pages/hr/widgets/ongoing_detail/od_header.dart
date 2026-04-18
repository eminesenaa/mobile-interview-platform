import 'package:flutter/material.dart';
import '../../../../constants/text_styles.dart';
import '../../widgets/status_badge.dart';

class OngoingDetailHeader extends StatelessWidget {
  final String title;
  final String status;

  const OngoingDetailHeader({
    super.key,
    required this.title,
    required this.status,
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
          reviewStatus: "pending", // ongoing için önemli değil ama zorunlu
        ),
      ],
    );
  }
}
