// lib/pages/exam/question_widgets/review_coding_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';
import 'review_coding_editor_page.dart';

class ReviewCodingView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewCodingView({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamReviewController>(tag: examId);
    final savedAnswer = c.answers[question.id] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              savedAnswer.toString().isEmpty
                  ? "// No code written."
                  : savedAnswer.toString(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                // Future AI açıklaması burada açılacak
              },
              child: const Text(
                "See AI Explanation",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () {
                Get.to(() => ReviewCodingEditorPage(
                  question: question,
                  code: savedAnswer.toString(),
                ));
              },
              icon: const Icon(Icons.code_rounded, size: 18),
              label: const Text("Open Code Editor"),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
