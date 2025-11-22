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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // review controller'ı al (tag'li kullanım varsa önce onu dene)
    ExamReviewController c;
    try {
      c = Get.find<ExamReviewController>(tag: examId);
    } catch (_) {
      c = Get.find<ExamReviewController>();
    }

    final String? selected = c.answers[question.id] as String?;
    // Doğru cevabı öncelikle Question’dan oku; yoksa controller helper’ına bırak
    final String? correct =
        question.correctAnswer ?? c.correctAnswerFor(question.id);

    Widget buildOption(String label) {
      // Durumu belirle
      final bool isSelected = selected == label;
      final bool isCorrect = correct == label;
      final isUnanswered = selected == null || selected.isEmpty;

      // Görsel durumları hesapla
      Color border;
      Color? fill;
      IconData? leadingIcon;
      Color? leadingColor;
      TextStyle textStyle = theme.textTheme.bodyMedium!;

      if (isSelected && isCorrect) {
        // ✅ Kullanıcı doğru cevabı seçti
        border = Colors.green;
        fill = Colors.green.withValues(alpha: 0.10);
      } else if (isSelected && !isCorrect) {
        // ❌ Kullanıcı yanlış seçti
        border = Colors.red;
        fill = Colors.red.withValues(alpha: 0.10);
      } else if (!isSelected && isCorrect && isUnanswered) {
        // ℹ️ Kullanıcı hiç seçmedi → doğru cevabı bilgi rengiyle göster
        border = Colors.blueAccent;
        fill = Colors.blueAccent.withValues(alpha: 0.10);
      } else if (!isSelected && isCorrect && !isUnanswered) {
        // ✅ Yanlış seçti ama bu doğru olan (doğruyu vurgula)
        border = Colors.green;
        fill = Colors.green.withValues(alpha: 0.08);
      } else {
        // 🔘 Normal nötr görünüm
        border = Colors.grey.shade400;
        fill = Colors.grey.withValues(alpha: 0.05);
      }


      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.4),
        ),
        // read-only: hiçbir tepki yok
        child: Row(
          children: [
            Icon(leadingIcon, color: leadingColor),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: textStyle)),
          ],
        ),
      );
    }

    final options = question.options ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...options.map(buildOption),
        const SizedBox(height: 12),
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
}
