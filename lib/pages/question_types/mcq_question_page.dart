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
import '../../../controllers/mcq_controller.dart';

class McqQuestionPage extends StatelessWidget {
  final Question question;

  const McqQuestionPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    // Controller'ı sayfa özel tag ile kayıt et (aynı sorudan birden fazlası açılırsa çakışmasın)
    final c = Get.put(McqController(question /*, shuffleOptions: true*/), tag: question.id);

    final textToShow = (question.description?.isNotEmpty ?? false)
        ? question.description!   // <- ileride soru metnini description'a taşıyacağın için burası öncelikli
        : question.title;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question', style: AppTextStyles.headline.copyWith(color: Colors.white)),
        backgroundColor: pastelBlue,
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

              // Seçenek listesi (overflow güvenli)
              Expanded(
                child: ListView.separated(
                  itemCount: c.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final option = c.options[i];
                    final isSelected = c.selectedIndex.value == i;
                    final isCorrect = c.isOptionCorrect(i);
                    final isWrong = c.isSubmitted.value && isSelected && !isCorrect;

                    final Color bgColor = isSelected
                        ? (c.isSubmitted.value
                        ? (isCorrect ? Colors.green.shade100 : Colors.red.shade100)
                        : Colors.blue.shade50)
                        : Colors.grey.shade100;

                    final Color borderColor = c.isSubmitted.value
                        ? (isCorrect
                        ? Colors.green
                        : (isWrong ? Colors.red : Colors.grey))
                        : Colors.grey;

                    final Color textColor = c.isSubmitted.value && isCorrect
                        ? Colors.green.shade700
                        : (isWrong ? Colors.red.shade700 : Colors.black);

                    return GestureDetector(
                      onTap: c.isSubmitted.value ? null : () => c.select(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                              onChanged: c.isSubmitted.value ? null : (_) => c.select(i),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: isSelected ? FontWeight.w600 : null,
                                ),
                              ),
                            ),
                            if (c.isSubmitted.value)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: isCorrect
                                    ? const Icon(Icons.check_circle_outline, color: Colors.green)
                                    : (isWrong
                                    ? const Icon(Icons.cancel_outlined, color: Colors.red)
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
                    onPressed: c.selectedIndex.value == null ? null : c.submit,
                    child: const Text('Send'),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.isCorrect.value ? 'Correct! 🎉' : 'Wrong ❌',
                      style: AppTextStyles.headline.copyWith(
                        color: c.isCorrect.value ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Correct answer: ${_resolveCorrectText(c, question)}',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 8),
                    // İstersen tekrar dene butonu:
                    OutlinedButton.icon(
                      onPressed: c.reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Doğru cevabı ekrana yazarken controller'ın doğru index'ini tercih et,
  /// o yoksa modeldeki correctAnswer stringini kullan.
  String _resolveCorrectText(McqController c, Question q) {
    final idx = c.correctIndex;
    if (idx != null && idx >= 0 && idx < c.options.length) {
      return c.options[idx];
    }
    return q.correctAnswer ?? '-';
  }
}
