// lib/pages/exam/widgets/review_action_bar.dart

import 'package:flutter/material.dart';
import '../../../../constants/colors.dart';

class ReviewActionBar extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onNavigator;

  const ReviewActionBar({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onNavigator, required String examId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            label: const Text('Previous'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            label: const Text('Next'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
