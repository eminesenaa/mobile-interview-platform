import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../utils/ai_feedback_widget.dart';
import '../controllers/coding_controller.dart';

class CodingQuestionView extends StatelessWidget {
  final Question question;
  final bool locked;
  final VoidCallback onOpenEditor;

  const CodingQuestionView({
    super.key,
    required this.question,
    required this.locked,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
    // Her coding sorusu için unique tag ile controller oluştur / bul
    final c = Get.put(CodingController(question), tag: question.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.description != null && question.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              question.description!,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        const SizedBox(height: 16),
        Obx(() {
          if (c.aiMeta.value == null) return const SizedBox.shrink();
          return AiFeedbackWidget(
            correct: c.aiMeta.value!.correct,
            score: c.aiMeta.value!.score,
            explanation: c.aiMeta.value!.explanation,
            earnedXp: c.earnedXp.value,
          );
        }),
      ],
    );
  }
}
