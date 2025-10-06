import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/exam/question_widgets/review_coding_editor_page.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';

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
    final savedAnswer = c.answers[question.id]?.toString() ?? '';
    final codeTemplate = question.codeTemplate ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 12),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.grey.shade100,
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.grey.shade300),
        //   ),
        //   child: SingleChildScrollView(
        //     scrollDirection: Axis.horizontal,
        //     child: Text(
        //       savedAnswer.isEmpty ? "// No code written." : savedAnswer,
        //       style: const TextStyle(
        //         fontFamily: 'monospace',
        //         fontSize: 14,
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              Get.to(() => ReviewCodingEditorPage(
                    question: question,
                    examId: examId,
                  ));
            },
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
