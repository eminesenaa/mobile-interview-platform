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
    final savedAnswer =
        c.userAnswerTextFor(question.id); // tek blank için fallback

    // ✅ Doğruluk durumunu controller’dan al
    final status = c.fillBlankStatusFor(question.id);

    // ✅ Karşılaştırma için normalize helper
    String norm(String? s) =>
        (s ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // 🔹 Her boşluk için read-only TextField oluştur
        ...List.generate(blanks.length, (i) {
          // 🔹 Her blank için kullanıcı cevabını çıkar
          String answerText = '';
          if (userAnswers is Map) {
            final byInt = userAnswers[i];
            final byStr = userAnswers[i.toString()];
            if (byInt is String) {
              answerText = byInt;
            } else if (byStr is String) {
              answerText = byStr;
            }
          } else if (userAnswers is List) {
            final v = (i < userAnswers.length) ? userAnswers[i] : null;
            if (v is String) answerText = v;
          } else if (blanks.length == 1) {
            // Tek blank senaryosu → savedAnswer fallback
            answerText = savedAnswer;
          }

          // ✅ Bu blank için durum: unanswered / correct / wrong
          final bool isUnanswered = answerText.trim().isEmpty;
          bool isCorrect = false;
          if (!isUnanswered && i < (question.blanks?.length ?? 0)) {
            isCorrect = norm(answerText) == norm(question.blanks![i]);
          }
          final bool isWrong = !isUnanswered && !isCorrect;

// ✅ Renkleri duruma göre seç
          final Color border =
              isCorrect ? Colors.green : (isWrong ? Colors.red : Colors.grey);
          final Color? fill = isCorrect
              ? Colors.green.withValues(alpha: 0.10)
              : (isWrong
                  ? Colors.red.withValues(alpha: 0.10)
                  : Colors.grey.withValues(alpha: 0.12));

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: TextEditingController(text: answerText),
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: fill,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: border, width: 1.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: border, width: 1.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: border, width: 1.2),
                  borderRadius: BorderRadius.circular(10),
                ),

                hintText: 'Blank ${i + 1}: No answer provided.',
                // fillColor: Colors.grey.shade100,
                // filled: true,
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () {
              c.showAiExplanation(
                questionId: question.id,
                title: 'Explanation: ${question.title}',
              );
            },
            child: const Text(
              "See AI Explanation",
              style: TextStyle(
                color: AppColors.primary,
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
