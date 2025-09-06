// ========== File: lib/pages/question_types/mcq_question_page.dart ==========
// Purpose:
// - Çoktan Seçmeli (MCQ) soru çözüm ekranı (GetX ile).
// - Question modelinden title/description + options + correctAnswer alınır.
// - Seçim -> "Send" ile kontrol -> doğru/yanlış geri bildirim akışı.
//
// Notlar:
// - UI, senin örnekteki görselle birebir uyumludur (AppTextStyles, pastelBlue).
// - Seçenekler uzun olursa overflow olmasın diye ListView (Expanded) kullanıldı.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import 'controllers/mcq_controller.dart';


class McqQuestionPage extends StatelessWidget {
  final Question question;

  const McqQuestionPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(McqController(question), tag: question.id);

    final textToShow = (question.description?.isNotEmpty ?? false)
        ? question.description!
        : question.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question',
          style: AppTextStyles.headline.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GetX<McqController>(
          init: c,
          tag: question.id,
          builder: (c) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Soru metni
              Text(textToShow, style: AppTextStyles.headline),
              const SizedBox(height: 24),

              // Seçenek listesi
              Expanded(
                child: ListView.separated(
                  itemCount: c.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final option = c.options[i];
                    final isSelected = c.selectedIndex.value == i;
                    final isCorrect = c.isOptionCorrect(i);
                    final isWrong =
                        c.isSubmitted.value && isSelected && !isCorrect;

                    // Arka plan rengi
                    final Color bgColor;
                    if (c.isSubmitted.value) {
                      if (isCorrect) {
                        bgColor = Colors.green.shade100;
                      } else if (isWrong) {
                        bgColor = Colors.red.shade100;
                      } else {
                        bgColor = Colors.grey.shade100;
                      }
                    } else {
                      bgColor = isSelected
                          ? Colors.blue.shade50
                          : Colors.grey.shade100;
                    }

                    // Çerçeve rengi
                    final Color borderColor;
                    if (c.isSubmitted.value) {
                      if (isCorrect) {
                        borderColor = Colors.green;
                      } else if (isWrong) {
                        borderColor = Colors.red;
                      } else {
                        borderColor = Colors.grey.shade400;
                      }
                    } else {
                      borderColor = isSelected
                          ? pastelBlue
                          : Colors.grey.shade400;
                    }

                    return GestureDetector(
                      onTap: c.isSubmitted.value ? null : () => c.select(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: i,
                              groupValue: c.selectedIndex.value,
                              onChanged: c.isSubmitted.value
                                  ? null
                                  : (_) => c.select(i),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                 color: c.isSubmitted.value
                                   ? (isCorrect
                                  ? Colors.green.shade700
                                      : (isWrong ? Colors.red.shade700 : Colors.black))
                                      : Colors.black,

                                ),
                              ),
                            ),
                            if (c.isSubmitted.value)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: isCorrect
                                    ? const Icon(Icons.check_circle_outline,
                                        color: Colors.green)
                                    : (isWrong
                                        ? const Icon(Icons.cancel_outlined,
                                            color: Colors.red)
                                        : const SizedBox.shrink()),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Submit / Feedback
              if (!c.isSubmitted.value)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        c.selectedIndex.value == -1 ? null : c.submit,
                    child: const Text('Send'),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Feedback:",
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.aiFeedback.value.isNotEmpty
                          ? c.aiFeedback.value
                          : "Yanıt yorumlanamadı.",
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
