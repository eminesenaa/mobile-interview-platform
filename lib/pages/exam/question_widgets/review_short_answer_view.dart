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
    final savedAnswer = (c.answers[question.id] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: TextEditingController(text: savedAnswer.isEmpty ? '' : savedAnswer),
          readOnly: true,
          maxLines: 5,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: savedAnswer.isEmpty ? 'No answer provided.' : null,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              "See AI Explanation",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
