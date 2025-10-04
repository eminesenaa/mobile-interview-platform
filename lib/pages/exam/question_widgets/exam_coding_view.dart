import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';
import '../controllers/exam_coding_controller.dart';
import '../controllers/exam_controller.dart';
import '../widgets/question_header.dart';
import 'exam_coding_editor_page.dart';

class ExamCodingView extends StatelessWidget {
  final Question question;
  final void Function(String code) onAnswerChanged;
  final VoidCallback onToggleFlag;
  final String examId;

  const ExamCodingView({
    super.key,
    required this.question,
    required this.onAnswerChanged,
    required this.onToggleFlag,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(ExamCodingController(), tag: question.id, permanent: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Flag & Clear (same style as MCQ)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                final examCtrl = Get.find<ExamController>(tag: examId);
                examCtrl.toggleFlag(question.id);
              },
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text("Flag"),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () {
                controller.clearCode();
                onAnswerChanged('');
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Clear"),
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
