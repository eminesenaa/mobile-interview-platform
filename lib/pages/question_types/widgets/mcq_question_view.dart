// lib/pages/question_types/widgets/mcq_question_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../../../widgets/ai_feedback_widget.dart';
import '../../../utils/markdown_heuristics.dart';
import '../controllers/mcq_controller.dart';

import '../../../widgets/content/markdown_content.dart';

/// Presentational widget:
/// - Sadece UI + kullanıcının şık seçimi
/// - SEND butonu içermez (Runner alt barda)
/// - Submit sonrası feedback görünümünü controller'ın state'inden okur
/// - Seçim değişince üst bileşene haber verir (Runner canSubmit için)
class McqQuestionView extends StatefulWidget {
  final Question question;

  /// Runner, "Send" butonunu enable/disable etmek için kullanır.
  /// selectedIndex != null ise valid = true gönderiyoruz.
  // Runner artık tüm cevapları Map<String, dynamic> olarak bekliyor.
// MCQ için {"index": <seçili_index>} formatında göndereceğiz.
  final void Function(Map<String, dynamic>? answer)? onChanged;

  /// Dışarıdan kilitlemek istersen (genellikle submit sonrası),
  /// ek önlem olarak seçenekler pasif olur. (Controller’daki isSubmitted
  /// zaten temel kilitlemeyi yapıyor; bu parametre opsiyonel.)
  final bool locked;

  const McqQuestionView({
    super.key,
    required this.question,
    this.onChanged,
    this.locked = false,
  });

  @override
  State<McqQuestionView> createState() => _McqQuestionViewState();
}

class _McqQuestionViewState extends State<McqQuestionView> {
  int? _selected;
  late final McqController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(McqController(widget.question), tag: widget.question.id);
    // (opsiyonel) controller’da seçili değer varsa al
    try {
      _selected = c.selectedIndex.value;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(McqController(widget.question), tag: widget.question.id);

    final textToShow = (widget.question.description?.isNotEmpty ?? false)
        ? widget.question.description!
        : widget.question.title;

    final text = textToShow;
    final hasFence = containsFencedCode(text);

    final Widget header = hasFence
        ? MarkdownContent(
            data: text,
            padding: const EdgeInsets.only(bottom: 12),
            autoFenceCode: false, // sadece fenced kodu işle
          )
        : Text(text, style: AppTextStyles.headline);

    return GetX<McqController>(
      tag: widget.question.id,
      builder: (_) {
        final isSubmitted = c.isSubmitted.value;
        final effectiveLocked = widget.locked || isSubmitted;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soru metni
            header,

            const SizedBox(height: 24),

            // Seçenek listesi
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: c.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final option = c.options[i];
                final isSelected = _selected == i;

                final isCorrect = c.isOptionCorrect(i);
                final isWrong = isSubmitted && isSelected && !isCorrect;

                Color bgColor = Colors.white;
                Color borderColor = Colors.grey.shade400;

                if (isSubmitted) {
                  if (isCorrect) {
                    borderColor = Colors.green;
                    bgColor = Colors.green.shade50;
                  } else if (isWrong) {
                    borderColor = Colors.red;
                    bgColor = Colors.red.shade50;
                  }
                } else if (isSelected) {
                  borderColor = pastelBlue;
                }

                return GestureDetector(
                  onTap: effectiveLocked
                      ? null
                      : () {
                          setState(() => _selected = i);
                          c.select(i); // seçimi controller’a bildir
                          widget.onChanged
                              ?.call({"index": i}); // opsiyonel callback
                        },
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
                          groupValue: _selected,
                          onChanged: effectiveLocked
                              ? null
                              : (_) {
                                  setState(() => _selected = i);
                                  c.select(i); // seçimi controller’a bildir
                                  widget.onChanged?.call(
                                      {"index": i}); // opsiyonel callback
                                },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSubmitted
                                  ? (isCorrect
                                      ? Colors.green.shade700
                                      : (isWrong
                                          ? Colors.red.shade700
                                          : Colors.black))
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // AI Feedback (submit sonrası)
            if (isSubmitted) ...[
              const SizedBox(height: 16),
              if (c.isEvaluating.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                )
              else if (c.aiResult.value != null)
                AiFeedbackWidget(
                  correct: c.aiResult.value!.correct,
                  score: c.aiResult.value!.score,
                  explanation: c.aiResult.value!.explanation,
                  earnedXp: c.earnedXp.value,
                )
              else
                const Text("Yanıt yorumlanamadı."),
            ],
          ],
        );
      },
    );
  }
}
