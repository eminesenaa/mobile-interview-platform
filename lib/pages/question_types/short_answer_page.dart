// ========== File: lib/pages/question_types/short_answer_page.dart ==========
// Short Answer çözüm ekranı
// - Harf duyarsız, boşluk normalize edilerek kontrol
// - İlk yanlışta input temizlenir + "Show answer" seçeneği görünür
// - Doğru bilirse tebrik + (opsiyonel) solved işaretleme
// ===========================================================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// İstersen projedeki stil sabitlerini de kullanabilirsin:
// import '../../constants/constants.dart';
import '../../models/question.dart';
// (Opsiyonel) solved güncellemek istersen:
import '../../controllers/question_controller.dart';

class ShortAnswerPage extends StatefulWidget {
  final Question question;
  const ShortAnswerPage({super.key, required this.question});

  @override
  State<ShortAnswerPage> createState() => _ShortAnswerPageState();
}

class _ShortAnswerPageState extends State<ShortAnswerPage> {
  final TextEditingController _controller = TextEditingController();

  bool _hasAttemptedWrongOnce = false; // ilk yanlış yapıldı mı
  bool _revealAnswer = false;          // doğru cevabı göster
  bool _isCorrect = false;             // doğru bildi mi

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Cevap kontrolü: harf duyarsız + whitespace normalize
  bool _isUserAnswerCorrect(String userInput) {
    final correct = widget.question.correctAnswer ?? '';
    return _normalize(userInput) == _normalize(correct);
  }

  String _normalize(String s) =>
      s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  void _submit() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      Get.snackbar('Oops', 'Lütfen bir cevap yaz 🙈',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      return;
    }

    if (_isUserAnswerCorrect(text)) {
      setState(() {
        _isCorrect = true;
      });

      // (Opsiyonel) solved işaretle
      try {
        final qc = Get.find<QuestionController>();
        // Eğer böyle bir metodun varsa kullan; yoksa yorumlayabilirsin.
        // qc.updateStatus(widget.question.id, Status.solved);
      } catch (_) {/* controller yoksa sorun etmeyelim */}

      Get.snackbar('Tebrikler 🎉', 'Doğru cevap!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } else {
      if (!_hasAttemptedWrongOnce) {
        setState(() => _hasAttemptedWrongOnce = true);
        // kısa gecikme ile temizleyelim ki kullanıcı feedback’i görsün
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _controller.clear();
        });
        Get.snackbar('Tekrar dene ✍️',
            'Ufak bir yazım hatası yapmış olabilirsin.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Yanlış', 'Bir kez daha denemek ister misin?',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Short Answer'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Soru başlığı
              Text(
                q.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              // (Varsa) açıklama/hint
              if ((q.description ?? '').isNotEmpty) ...[
                Text(q.description!,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
              ],

              // Meta: topic (String) + difficulty (enum)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(label: q.topic),                 // topic String
                  _Badge(label: q.difficulty.name),       // enum -> .name
                ],
              ),

              const SizedBox(height: 20),

              // Cevap alanı + Gönder
              _AnswerInput(
                controller: _controller,
                onSubmit: _submit,
                enabled: !_isCorrect,
              ),

              const SizedBox(height: 8),

              // İlk yanlış sonrası bilgi ve "Show answer"
              if (!_isCorrect && _hasAttemptedWrongOnce && !_revealAnswer) ...[
                Text(
                  'Bir kez daha dene ya da aşağıdaki "Show answer" ile doğru cevabı görebilirsin.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => setState(() => _revealAnswer = true),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Show answer'),
                ),
              ],

              // Doğru cevabı göster
              if (_revealAnswer) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                    Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Correct Answer',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        q.correctAnswer ?? '—',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],

              if (_isCorrect) ...[
                const SizedBox(height: 16),
                _SuccessCard(
                  onNext: () {
                    // Şimdilik geri dönelim; istersen sonraki soruya geçişi kurgularız
                    Get.back();
                  },
                ),
              ],

              const Spacer(),

              Text(
                'Not: Kontrol harf duyarsızdır; yazım hatasına tolerans yoktur.',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool enabled;
  const _AnswerInput({
    required this.controller,
    required this.onSubmit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: 'Cevabını yaz...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: enabled ? onSubmit : null,
          icon: const Icon(Icons.send_outlined, size: 18),
          label: const Text('Send'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.primary.withOpacity(.1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final VoidCallback onNext;
  const _SuccessCard({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onNext,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Harika! Bu soruyu doğru cevapladın. Bir sonrakine geçmek için dokun.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
