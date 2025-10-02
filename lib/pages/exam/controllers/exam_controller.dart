// lib/pages/exam/controllers/exam_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';

// AI değerlendirme ve sonuç sayfası
import 'package:interview_project/services/ai/ai_service.dart';
import 'package:interview_project/services/ai/openai_service.dart'
    show PromptType;
import 'package:interview_project/pages/exam/exam_result_page.dart';

/// Basit sınav state modeli
class ExamState {
  final int secondsLeft;
  final Map<String, dynamic>
      answers; // questionId -> userAnswer (int index ya da String)
  final Set<String> flagged;

  const ExamState({
    required this.secondsLeft,
    required this.answers,
    required this.flagged,
  });

  ExamState copyWith({
    int? secondsLeft,
    Map<String, dynamic>? answers,
    Set<String>? flagged,
  }) {
    return ExamState(
      secondsLeft: secondsLeft ?? this.secondsLeft,
      answers: answers ?? this.answers,
      flagged: flagged ?? this.flagged,
    );
  }
}

class ExamController extends GetxController {
  final Exam exam;
  ExamController(this.exam);

  /// Ekranda gösterilen soru index’i
  final RxInt _currentIndex = 0.obs;

  /// Zamanlayıcı
  Timer? _ticker;

  /// Ekranın reaktif state’i
  late final Rx<ExamState> state;

  // ---------- Getters ----------
  int get total => exam.questions.length;
  int get currentNumber => _currentIndex.value + 1;
  Question get currentQuestion => exam.questions[_currentIndex.value];

  int get answeredCount => state.value.answers.length;
  int get flaggedCount => state.value.flagged.length;
  int get unansweredCount => total - answeredCount;

  @override
  void onInit() {
    super.onInit();

    final seconds = exam.duration.inSeconds;
    state = ExamState(
      secondsLeft: seconds,
      answers: <String, dynamic>{},
      flagged: <String>{},
    ).obs;

    // 1 saniyelik sayaç
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      final s = state.value.secondsLeft;
      if (s <= 0) {
        t.cancel();
        // Süre bittiğinde otomatik submit
        submit();
      } else {
        state.value = state.value.copyWith(secondsLeft: s - 1);
      }
    });
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  // ---------- Navigasyon ----------
  void next() {
    if (_currentIndex.value < total - 1) {
      _currentIndex.value++;
    }
  }

  void prev() {
    if (_currentIndex.value > 0) {
      _currentIndex.value--;
    }
  }

  // ---------- İşaretleme ----------
  void toggleFlag() {
    final qid = currentQuestion.id;
    final flagged = Set<String>.from(state.value.flagged);
    if (flagged.contains(qid)) {
      flagged.remove(qid);
    } else {
      flagged.add(qid);
    }
    state.value = state.value.copyWith(flagged: flagged);
  }

  // ---------- Cevaplama ----------
  /// MCQ için genelde `int` index gelir; kısa cevap/bosluk doldur için `String`.
  void answerCurrent(dynamic userAnswer) {
    final qid = currentQuestion.id;
    final map = Map<String, dynamic>.from(state.value.answers);
    map[qid] = userAnswer;
    state.value = state.value.copyWith(answers: map);
  }

  // ---------- Submit (LLM batch değerlendirme + sonuç ekranına git) ----------
  Future<void> submit() async {
    // 1) Cevapları oku
    final answers = Map<String, dynamic>.from(state.value.answers);

    if (answers.isEmpty) {
      Get.snackbar('Uyarı', 'Henüz cevap yok. En az bir soru cevaplayın.');
      return;
    }

    // 2) Küçük bir loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // 3) 5'lik batch değerlendirme
      final ai = AiService();
      final eval = await ai.evaluateExam(
        exam: exam,
        userAnswers: answers,
        promptType:
            PromptType.training, // İstersen exam türüne göre seçebilirsin
      );

      // 4) Loading kapat
      if (Get.isDialogOpen ?? false) Get.back();

      // 5) Tek sonuç ekranına zorunlu parametrelerle git
      Get.offAll(() => ExamResultPage(result: eval, exam: exam));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Hata', 'Değerlendirme hatası: $e');
    }
  }
}
