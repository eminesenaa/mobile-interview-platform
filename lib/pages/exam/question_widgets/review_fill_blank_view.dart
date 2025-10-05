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

    // 🔹 blanks verisi varsa onu kullan, yoksa description’daki boşluklardan türet
    final blanks = question.blanks ??
        _extractBlanksFromDescription(question.description ?? '');

    // 🔹 Kullanıcının cevaplarını al
    final userAnswers = c.answers[question.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // 🔹 Her boşluk için read-only TextField oluştur
        ...List.generate(blanks.length, (i) {
          String answerText = '';

          if (userAnswers is Map) {
            final byInt = userAnswers[i];
            final byStr = userAnswers[i.toString()];
            if (byInt is String) {
              answerText = byInt;
            } else if (byStr is String) {
              answerText = byStr;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: TextEditingController(text: answerText),
              readOnly: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Blank ${i + 1}: No answer provided.',
                fillColor: Colors.grey.shade100,
                filled: true,
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
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

  /// 🔹 Description içinden alt çizgi (___) sayısına göre blanks üret
  List<String> _extractBlanksFromDescription(String text) {
    final regex = RegExp(r'_{3,}');
    final count = regex.allMatches(text).length;
    return List.generate(count, (i) => 'blank$i');
  }
}
