import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';

class ReviewShortAnswerView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewShortAnswerView({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamReviewController>(tag: examId);
    final userAnswer = c.answers[question.id] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kullanıcının cevabını göster
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: headlineColor.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Text(
            userAnswer.isNotEmpty
                ? userAnswer
                : 'No answer provided.',
            style: TextStyle(
              fontSize: 16,
              color: userAnswer.isNotEmpty
                  ? Colors.black87
                  : Colors.grey[600],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // AI açıklaması linki
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: AI explanation popup / modal (ileride eklenecek)
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: const Text(
              "See AI Explanation",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
