import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../constants/colors.dart';
import '../controllers/exam_controller.dart';

class ExamFillBlankView extends StatefulWidget {
  final Question question;
  final void Function(Map<int, String>) onAnswerChanged;
  final String examId;

  const ExamFillBlankView({
    super.key,
    required this.question,
    required this.onAnswerChanged,
    required this.examId,
  });

  @override
  State<ExamFillBlankView> createState() => _ExamFillBlankViewState();
}

class _ExamFillBlankViewState extends State<ExamFillBlankView> {
  final Map<int, TextEditingController> _controllers = {};
  late ExamController c;
  late List<String> _blanks;

  @override
  void initState() {
    super.initState();
    c = Get.find<ExamController>(tag: widget.examId);
    _setupControllers();
  }

  @override
  void didUpdateWidget(covariant ExamFillBlankView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Soru değiştiğinde controller'ları yenile
    if (oldWidget.question.id != widget.question.id) {
      _disposeControllers();
      _setupControllers();
    } else {
      // Aynı soru ama state dışarıdan güncellendiyse metinleri tazele
      _restoreTextsFromSaved();
    }
  }

  void _setupControllers() {
    // 1) blanks kaynağı: varsa modelden, yoksa ___ sayısından türet
    _blanks = widget.question.blanks ??
        _extractBlanksFromDescription(widget.question.description ?? '');

    // 2) önceki cevaplar
    final prevAnswers = c.answers[widget.question.id];

    for (int i = 0; i < _blanks.length; i++) {
      // int veya string key olabilir; ikisini de dene
      String initial = '';
      if (prevAnswers is Map) {
        final byInt = prevAnswers[i];
        final byStr = prevAnswers[i.toString()];
        if (byInt is String) {
          initial = byInt;
        } else if (byStr is String) {
          initial = byStr;
        }
      }

      final controller = TextEditingController(text: initial);
      _controllers[i] = controller;

      controller.addListener(() {
        _notifyParent();
        // Kaydı hep string key ile tutalım
        final currentAnswers = {
          for (var e in _controllers.entries) e.key.toString(): e.value.text,
        };
        c.saveAnswer(widget.question.id, currentAnswers);
      });
    }
  }

  void _restoreTextsFromSaved() {
    final prevAnswers = c.answers[widget.question.id];
    if (prevAnswers is! Map) return;
    for (int i = 0; i < _controllers.length; i++) {
      final byInt = prevAnswers[i];
      final byStr = prevAnswers[i.toString()];
      final newVal = (byInt is String) ? byInt : (byStr is String ? byStr : '');
      final ctrl = _controllers[i];
      if (ctrl != null && ctrl.text != newVal) {
        ctrl.text = newVal;
      }
    }
  }

  void _disposeControllers() {
    // Bazı durumlarda widget dispose olurken listener hâlâ tetiklenebiliyor.
    // Bu yüzden önce listener’ları iptal edip sonra dispose ediyoruz.
    final oldControllers = Map<int, TextEditingController>.from(_controllers);
    _controllers.clear();
    for (final ctrl in oldControllers.values) {
      try {
        ctrl.removeListener(() {}); // güvenlik amaçlı
        ctrl.dispose();
      } catch (_) {}
    }
  }

// blanks tanımlı değilse description'daki ___ sayısına göre türet
  List<String> _extractBlanksFromDescription(String description) {
    final regex = RegExp(r'_{3,}'); // 3+ alt çizgi
    final count = regex.allMatches(description).length;
    return List.generate(count, (i) => 'blank$i');
  }

// // 3️⃣ Eğer blanks tanımlı değilse, açıklama metninden otomatik çıkar
// List<String> _extractBlanksFromDescription(String description) {
//   final regex = RegExp(r'_{3,}'); // 3 veya daha fazla alt çizgi
//   final matches = regex.allMatches(description);
//   return List.generate(matches.length, (i) => 'blank$i');
// }

  void _notifyParent() {
    final answers = <int, String>{};
    for (final entry in _controllers.entries) {
      answers[entry.key] = entry.value.text;
    }
    widget.onAnswerChanged(answers);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _disposeControllers();
    super.dispose();
  }

  void _notifyAnswerChanged() {
    final answers = <int, String>{};
    _controllers.forEach((i, c) {
      answers[i] = c.text;
    });
    widget.onAnswerChanged(answers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Blank alanları
        ..._controllers.entries.map((entry) {
          final idx = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controller,
              onChanged: (_) => _notifyAnswerChanged(),
              decoration: const InputDecoration(
                hintText: 'Type your answer...', // fill in the blank
                border: OutlineInputBorder(),
              ),
            ),
          );
        }),

        const SizedBox(height: 6),

        // Flag & Clear (MCQ ile aynı)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => c.toggleFlag(widget.question.id),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text("Flag"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () {
                for (final c in _controllers.values) {
                  c.clear();
                }
                _notifyAnswerChanged();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Clear"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
