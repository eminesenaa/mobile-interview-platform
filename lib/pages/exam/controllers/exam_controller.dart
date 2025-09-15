// lib/pages/exam/controllers/exam_controller.dart
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/exam/exam_result_page.dart';

class ExamController extends GetxController {
  final Exam exam;
  ExamController(this.exam);

  final _db = FirebaseFirestore.instance;

  late Rx<ExamStateModel> state;
  Timer? _ticker;

  Question get currentQuestion => exam.questions[state.value.currentIndex];

  int get total => exam.questions.length;
  int get answeredCount => state.value.answers.length;
  int get flaggedCount => state.value.flagged.length;
  int get unansweredCount => total - answeredCount;
  int get currentNumber => state.value.currentIndex + 1;

  @override
  void onInit() {
    super.onInit();
    state = ExamStateModel(
      examId: exam.id,
      secondsLeft: exam.duration.inSeconds,
    ).obs;
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.value.submitted) return;
      final left = state.value.secondsLeft - 1;
      if (left <= 0) {
        submit(auto: true);
      } else {
        state.value = state.value.copyWith(secondsLeft: left);
        state.refresh();
      }
    });
  }

  void answerCurrent(dynamic value) {
    final q = currentQuestion;
    final newAnswers = Map<String, dynamic>.from(state.value.answers);

    if (value == null) {
      newAnswers.remove(q.id);
    } else {
      newAnswers[q.id] = value;
    }

    state.value = state.value.copyWith(answers: newAnswers);
    state.refresh();
  }

  void toggleFlag() {
    final id = currentQuestion.id;
    final f = Set<String>.from(state.value.flagged);
    f.contains(id) ? f.remove(id) : f.add(id);
    state.value = state.value.copyWith(flagged: f);
    state.refresh();
  }

  void clearCurrent() {
    final q = currentQuestion;
    final newAnswers = Map<String, dynamic>.from(state.value.answers);
    newAnswers.remove(q.id);
    state.value = state.value.copyWith(answers: newAnswers);
    state.refresh();
  }

  void next() {
    if (state.value.currentIndex < exam.questions.length - 1) {
      state.value =
          state.value.copyWith(currentIndex: state.value.currentIndex + 1);
      state.refresh();
    }
  }

  void prev() {
    if (state.value.currentIndex > 0) {
      state.value =
          state.value.copyWith(currentIndex: state.value.currentIndex - 1);
      state.refresh();
    }
  }

  Future<void> submit({bool auto = false}) async {
    _ticker?.cancel();
    state.value = state.value.copyWith(submitted: true);
    state.refresh();

    // 🔹 Firestore’a kaydet
    await _db.collection("examResults").add({
      "examId": exam.id,
      "submittedAt": Timestamp.now(),
      "auto": auto,
      "answers": state.value.answers,
      "score": null, // ileride hesaplanacak
      "feedback": null,
    });

    // 🔹 Sonuç sayfasına yönlendir
    Get.offAll(() => const ExamResultPage());
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
