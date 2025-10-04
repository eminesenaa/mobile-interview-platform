import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';

class ReviewFillBlankView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewFillBlankView({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamReviewController>(tag: examId);
    final answers = c.answers[question.id];

    // Kullanıcı cevaplarını Map olarak çözümle
    final Map<int, String> parsedAnswers = {};
    if (answers is Map) {
      for (final entry in answers.entries) {
        final key = int.tryParse(entry.key.toString());
        if (key != null) parsedAnswers[key] = entry.value.toString();
      }
    }

    // blanks listesi ya da description’dan tahmin et
    final blanks = question.blanks ??
        _extractBlanksFromDescription(question.description ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(blanks.length, (i) {
          final userInput = parsedAnswers[i] ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: headlineColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Text(
              userInput.isNotEmpty
                  ? userInput
                  : 'No answer provided.',
              style: TextStyle(
                fontSize: 16,
                color: userInput.isNotEmpty
                    ? Colors.black87
                    : Colors.grey[600],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // AI açıklaması linki
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: AI explanation popup / modal (later)
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

  // Description’dan ___ sayısına göre blanks tahmini
  List<String> _extractBlanksFromDescription(String description) {
    final regex = RegExp(r'_{3,}');
    final count = regex.allMatches(description).length;
    return List.generate(count, (i) => 'blank$i');
  }
}
