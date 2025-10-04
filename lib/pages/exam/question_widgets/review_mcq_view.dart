import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';

class ReviewMcqView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewMcqView({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamReviewController>(tag: examId);

    // Kullanıcının verdiği yanıt
    final selected = c.answers[question.id] as String?;

    final options = List<String>.from(question.options ?? []);
    final questionText =
        question.title ?? question.description ?? 'Question';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Seçenekler (read-only)
        ...List.generate(options.length, (i) {
          final label = options[i];
          final isSelected = label == selected;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.2)
                  : headlineColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RadioListTile<String>(
              value: label,
              groupValue: selected,
              onChanged: null, // 🔒 Read-only
              title: Text(label),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              activeColor: primaryColor,
            ),
          );
        }),

        const SizedBox(height: 12),

        // AI açıklaması butonu
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: AI açıklama popup (ileride eklenecek)
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: const Text(
              "See AI Explanation",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
