import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/question.dart';
import '../../../utils/ai_feedback_widget.dart';
import '../../../utils/markdown_heuristics.dart';
import '../controllers/fill_blank_controller.dart';
import '../../../constants/constants.dart'; // AppTextStyles vb. için (varsa)

import '../../../widgets/content/markdown_content.dart';

/// Presentational widget:
/// - Sadece UI ve kullanıcı girişleri
/// - Scaffold/AppBar/Send butonu içermez (Runner alt barda)
/// - Submit sonrası feedback'i controller state'inden okur
/// - Tüm boşluklar dolunca üst bileşene valid=true sinyali verir
class FillBlankView extends StatefulWidget {
  final Question question;

  /// Runner "Send" butonunu enable/disable etmek için dinler.
  /// Parametre: güncel cevap listesi. valid = tümü dolu mu?
  final void Function(List<String> answers, bool valid)? onChanged;

  /// Submit sonrası kilitlemek için (opsiyonel)
  final bool locked;

  const FillBlankView({
    super.key,
    required this.question,
    this.onChanged,
    this.locked = false,
  });

  @override
  State<FillBlankView> createState() => _FillBlankViewState();
}

class _FillBlankViewState extends State<FillBlankView> {
  late final FillBlankController _c;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _c = Get.put(FillBlankController(widget.question), tag: widget.question.id);

    // Mevcut controller answers uzunluğuna göre text controller’ları hazırla
    final count = _c.answers.length;
    for (int i = 0; i < count; i++) {
      final tc = TextEditingController(text: _c.answers[i]);
      tc.addListener(() {
        final txt = tc.text;
        _c.updateAnswer(
            i, txt); // controller zaten runner.canSubmit güncelliyor

        // opsiyonel: parent’a da haber ver (kullanıyorsan)
        widget.onChanged?.call(
          _c.answers.toList(),
          _allFilled(_c.answers),
        );
      });
      _controllers.add(tc);
    }
  }

  bool _allFilled(List<String> list) => list.every((e) => e.trim().isNotEmpty);

  @override
  void dispose() {
    for (final t in _controllers) {
      t.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textToShow = (widget.question.description?.isNotEmpty ?? false)
        ? widget.question.description!
        : widget.question.title;

    final text = textToShow;
    final hasFence = containsFencedCode(text);
    final likelyCode = isLikelyCodeSnippet(text);
    final langFromFence = extractFenceLanguage(text);
    final langGuess = guessLanguageFromText(text);
    final fallbackLang = mapUnsupportedLang(langFromFence ?? langGuess);

    final Widget header = (hasFence || likelyCode)
        ? MarkdownContent(
            data: hasFence ? text : smartBreaks(text),
            padding: const EdgeInsets.only(bottom: 12),
            autoFenceCode: !hasFence,
            // fence yoksa otomatik CodeBlock
            smartCodeBreaks: false,
            // satırı yukarıda kırdık
            fallbackLanguage: fallbackLang,
          )
        : Text(text, style: AppTextStyles.headline);

    return GetX<FillBlankController>(
      tag: widget.question.id,
      builder: (_) {
        final isSubmitted = _c.aiMeta.value != null; // gönderim yapıldıysa true
        final effectiveLocked = widget.locked || isSubmitted;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soru metni
            header,

            const SizedBox(height: 16),

            // Boşluk alanları
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                return TextField(
                  controller: _controllers[i],
                  readOnly: effectiveLocked,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Blank ${i + 1}',
                    hintText: 'Type here…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.6,
                      ),
                    ),
                    filled: true,
                    fillColor:
                        effectiveLocked ? Colors.grey.shade100 : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                );
              },
            ),

            // AI feedback
            if (isSubmitted) ...[
              const SizedBox(height: 20),
              if (_c.isEvaluating.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                )
              else if (_c.aiMeta.value != null)
                AiFeedbackWidget(
                  correct: _c.aiMeta.value!.correct,
                  score: _c.aiMeta.value!.score,
                  explanation: _c.aiMeta.value!.explanation,
                  earnedXp: _c.earnedXp.value,
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
