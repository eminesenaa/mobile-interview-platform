import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../../../constants/constants.dart';

class QuestionProgressIndicator extends StatelessWidget {
  final int total;
  final int current; // 1-based index (Question 1 / 10)
  final int answered; // kaç soru cevaplandı

  const QuestionProgressIndicator({
    super.key,
    required this.total,
    required this.current,
    required this.answered,
  });

  @override
  Widget build(BuildContext context) {
    final safeAnswered = answered.clamp(0, total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepProgressIndicator(
          totalSteps: total,
          currentStep: safeAnswered,
          // ✅ SADECE ÇÖZÜLENLER

          size: 6,
          padding: 2,
          roundedEdges: const Radius.circular(3),

          // ✅ ÇÖZÜLEN SORULAR
          selectedColor: AppColors.primary,

          // ✅ HENÜZ ÇÖZÜLMEMİŞ
          unselectedColor: AppColors.border,
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            'Question $current / $total',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
