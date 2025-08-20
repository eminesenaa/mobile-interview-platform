import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/question.dart';
// (opsiyonel) solved/statü için:
// import '../../controllers/question_controller.dart';

/// Single-blank Fill in the Blank page
/// - Soru metninde boşluk *** (üç yıldız) ile işaretlenir:  "Flutter is a ***."
/// - Doğru cevap question.correctAnswer'dır (String).
/// - Alt kısımda seçenek kutuları: question.options varsa onu kullanır; yoksa sadece doğru cevabı gösterir.
/// - Tıklayarak ya da sürükle-bırak ile boşluğa yerleştirme.
/// - Karşılaştırma case-insensitive + whitespace normalize (yazım hatası toleransı yok).
class FillInBlankPage extends StatefulWidget {
  final Question question;
  const FillInBlankPage({super.key, required this.question});

  @override
  State<FillInBlankPage> createState() => _FillInBlankPageState();
}

class _FillInBlankPageState extends State<FillInBlankPage> {
  late final _SingleParsed _parsed; // segments[0] + BLANK + segments[1]
  String? _filled;                  // kullanıcı seçimi
  late List<String> _choices;       // alt seçim havuzu
  bool _attemptedWrongOnce = false; // ilk yanlış yapıldı mı
  bool _showAnswer = false;         // doğru cevabı göster
  bool _isCorrect = false;          // doğru mu

  @override
  void initState() {
    super.initState();

    // Metni title > description önceliğiyle al (description'ı kullanıyorsan burayı değiştir)
    final text = (widget.question.description?.isNotEmpty ?? false)
        ? widget.question.description!
        : widget.question.title;

    _parsed = _parseSingleBlank(text);

    // Choices: varsa options, yoksa sadece doğru cevap
    final base = (widget.question.options != null && widget.question.options!.isNotEmpty)
        ? widget.question.options!
        : [widget.question.correctAnswer ?? ''];
    _choices = base.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    _choices.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill in the Blank'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                q.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              if ((q.description ?? '').isNotEmpty && q.description != q.title) ...[
                const SizedBox(height: 8),
                Text(q.description!, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),

              // Soru metni: segmentA + BLANK + segmentB
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                children: [
                  Text(_parsed.left, style: Theme.of(context).textTheme.titleMedium),
                  _BlankSlot(
                    value: _filled,
                    onTap: _pickFromBottomSheet,
                    onAccept: (w) => _place(w),
                  ),
                  Text(_parsed.right, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),

              const SizedBox(height: 16),

              // Choices (drag kaynakları + tap)
              _ChoicesBoard(
                choices: _choices,
                onTapChoice: (w) => _place(w),
              ),

              const SizedBox(height: 12),

              // Aksiyonlar
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _check,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Check'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                  const Spacer(),
                  if (_attemptedWrongOnce && !_isCorrect && !_showAnswer)
                    TextButton.icon(
                      onPressed: () => setState(() => _showAnswer = true),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Show answer'),
                    ),
                ],
              ),

              if (_showAnswer) ...[
                const SizedBox(height: 10),
                _AnswersReveal(answers: [widget.question.correctAnswer ?? '—']),
              ],

              if (_isCorrect) ...[
                const SizedBox(height: 16),
                _SuccessCard(onNext: () => Get.back()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- Logic ---

  void _place(String word) {
    setState(() {
      // Eğer boşlukta daha önce kelime varsa onu choices'a geri koy
      if (_filled != null) _choices.add(_filled!);

      // Seçilen kelimeyi choices'tan çıkar
      final idx = _choices.indexWhere((c) => _normalize(c) == _normalize(word));
      if (idx != -1) _choices.removeAt(idx);

      _filled = word;
    });
  }

  void _reset() {
    setState(() {
      if (_filled != null) _choices.add(_filled!);
      _filled = null;
      _choices = _choices.toSet().toList();
      _attemptedWrongOnce = false;
      _showAnswer = false;
      _isCorrect = false;
    });
  }

  void _check() {
    if (_filled == null || _filled!.trim().isEmpty) {
      Get.snackbar('Eksik', 'Boşluğu doldur lütfen.',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      return;
    }

    final correct = widget.question.correctAnswer ?? '';
    final ok = _normalize(_filled!) == _normalize(correct);

    if (ok) {
      setState(() => _isCorrect = true);

      // (opsiyonel) solved/statü:
      // try { Get.find<QuestionController>().updateStatus(widget.question.id, Status.solved); } catch (_) {}

      Get.snackbar('Tebrikler 🎉', 'Doğru cevap!',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    } else {
      if (!_attemptedWrongOnce) {
        setState(() {
          _attemptedWrongOnce = true;
          // İlk yanlışta alanı temizle ve kelimeyi choices'a geri ver
          if (_filled != null) _choices.add(_filled!);
          _filled = null;
        });
        Get.snackbar('Tekrar dene ✍️', 'Ufak bir yazım hatası/yanlış seçim olabilir.',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Yanlış', 'İstersen "Show answer" ile doğru cevabı görebilirsin.',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      }
    }
  }

  Future<void> _pickFromBottomSheet() async {
    if (_choices.isEmpty) {
      Get.snackbar('Seçenek yok', 'Kullanılabilir seçenek kalmadı.',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: _choices.map((w) {
            return ListTile(
              title: Text(w),
              onTap: () => Navigator.pop(context, w),
            );
          }).toList(),
        ),
      ),
    );
    if (picked != null) _place(picked);
  }

  String _normalize(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  _SingleParsed _parseSingleBlank(String text) {
    // İlk *** görünümünü BLANK olarak kabul et
    const token = '***';
    final i = text.indexOf(token);
    if (i == -1) {
      // *** yoksa metni aynen ver, boşluk sona eklenir
      return _SingleParsed(left: text, right: '');
    }
    final left = text.substring(0, i);
    final right = text.substring(i + token.length);
    return _SingleParsed(left: left, right: right);
  }
}

class _SingleParsed {
  final String left;
  final String right;
  _SingleParsed({required this.left, required this.right});
}

// --- UI parçaları ---

class _BlankSlot extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;
  final void Function(String) onAccept;

  const _BlankSlot({
    required this.value,
    required this.onTap,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value == null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            width: 1.6,
          ),
          color: value == null
              ? Theme.of(context).colorScheme.primary.withOpacity(.06)
              : Theme.of(context).colorScheme.secondaryContainer.withOpacity(.6),
        ),
        child: Text(
          value ?? '____',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );

    return DragTarget<String>(
      builder: (_, __, ___) => child,
      onAccept: onAccept,
    );
  }
}

class _ChoicesBoard extends StatelessWidget {
  final List<String> choices;
  final void Function(String) onTapChoice;

  const _ChoicesBoard({
    required this.choices,
    required this.onTapChoice,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: choices.map((w) {
        return LongPressDraggable<String>(
          data: w,
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(999),
            child: _ChoiceChip(word: w, elevated: true),
          ),
          childWhenDragging: Opacity(opacity: 0.4, child: _ChoiceChip(word: w)),
          child: InkWell(
            onTap: () => onTapChoice(w),
            borderRadius: BorderRadius.circular(999),
            child: _ChoiceChip(word: w),
          ),
        );
      }).toList(),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String word;
  final bool elevated;
  const _ChoiceChip({required this.word, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceVariant,
        boxShadow: elevated
            ? [BoxShadow(blurRadius: 6, spreadRadius: 1, offset: const Offset(0, 2), color: Colors.black12)]
            : null,
      ),
      child: Text(
        word,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AnswersReveal extends StatelessWidget {
  final List<String> answers;
  const _AnswersReveal({required this.answers});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Correct Answer', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: answers.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                ),
                child: Text(
                  a,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
                  'Harika! Boşluğu doğru doldurdun. Bir sonrakine geçmek için dokun.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
