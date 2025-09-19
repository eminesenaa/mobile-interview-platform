// lib/pages/question_types/widgets/short_answer_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/question.dart';
import '../../../utils/markdown_heuristics.dart';
import '../controllers/short_answer_controller.dart';
import '../../../constants/constants.dart'; // AppTextStyles vb. varsa

import '../../../widgets/content/markdown_content.dart';

/// Presentational widget:
/// - Sadece UI + kullanıcının serbest metin cevabı
/// - SEND butonu içermez (Runner alt barda)
/// - Submit sonrası feedback görünümünü controller state'inden okur
/// - Metin değişince üst bileşene haber verir (Runner canSubmit için)
class ShortAnswerView extends StatefulWidget {
  final Question question;

  /// Runner, "Send" butonunu enable/disable etmek için dinler.
  /// Dışarıdan validasyon: text.trim().isNotEmpty -> canSubmit
  final void Function(String text)? onChanged;

  /// Submit sonrası kilitlemek için dışarıdan da “locked” verilebilir.
  final bool locked;

  const ShortAnswerView({
    super.key,
    required this.question,
    this.onChanged,
    this.locked = false,
  });

  @override
  State<ShortAnswerView> createState() => _ShortAnswerViewState();
}

class _ShortAnswerViewState extends State<ShortAnswerView> {
  late final TextEditingController _textCtrl;
  late final ShortAnswerController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.put(ShortAnswerController(widget.question), tag: widget.question.id);
    _textCtrl = TextEditingController();

    // Eğer controller mevcut cevabı tutuyorsa buraya set edebilirsin:
    // _textCtrl.text = _c.currentText.value;  // kontrolöründe böyle bir alan varsa
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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



    return GetX<ShortAnswerController>(
      tag: widget.question.id,
      builder: (_) {
        // Controller submit ettiyse veya dışarıdan kilit geldiyse input pasif
        final isSubmitted = _c.isSubmitted.value;
        final effectiveLocked = widget.locked || isSubmitted;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soru
            header,
            const SizedBox(height: 16),

            // Cevap alanı
            TextField(
              controller: _textCtrl,
              readOnly: effectiveLocked,
              minLines: 4,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Type your answer...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.6),
                ),
                filled: true,
                fillColor: effectiveLocked ? Colors.grey.shade100 : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onChanged: (text) {
                // Controller'da cevabı güncelle:
                // NOT: Senin controller'daki setter farklıysa (örn. updateAnswer/onChanged),
                // sadece şu satırı kendi fonksiyon adına göre değiştir.
                _c.updateAnswer(text); // <-- kontrolöründeki mevcut setter’ı kullan

                // Runner’a validasyon sinyali gönder
                widget.onChanged?.call(text);
              },
            ),

            // Submit sonrası feedback
            if (isSubmitted) ...[
              const SizedBox(height: 20),
              Text('AI Feedback:', style: AppTextStyles.headline),
              const SizedBox(height: 8),

              if (_c.isEvaluating.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),

              if (!_c.isEvaluating.value) ...[
                if (_c.aiFeedback.value.isNotEmpty)
                  Text(
                    _c.aiFeedback.value,
                    style: AppTextStyles.subtitle,
                  ),
                const SizedBox(height: 12),

                // Opsiyonel skor/doğruluk rozetleri (controller'ında varsa)
                if (_c.aiMeta.value != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          _c.aiMeta.value!.correct ? 'Correct' : 'Incorrect',
                        ),
                      ),
                      if (_c.aiMeta.value!.score != null)
                        Chip(
                          label: Text(
                            'Score: ${_c.aiMeta.value!.score!.toStringAsFixed(1)}/5',
                          ),
                        ),
                    ],
                  ),
              ],
            ],
          ],
        );
      },
    );
  }
}
