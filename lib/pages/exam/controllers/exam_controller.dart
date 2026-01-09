// ===================== File: lib/pages/exam/controllers/exam_controller.dart =====================
// Purpose: Sınav başlatma, yanıt yönetimi, zamanlayıcı ve sonuç ekranına geçiş.
//          Firestore'dan filtreye göre dinamik olarak alınan soru listesini destekler.
// =================================================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/ai_exam_result.dart';
import '../../../models/exam.dart';
import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';
import 'create_exam_controller.dart'; // ✅ düzeltildi
import '../result/exam_result_page.dart'; // ✅ bir üst klasörde
import '../services/exam_xp_service.dart';

class ExamController extends GetxController {
  final Exam exam;

  ExamController(this.exam);

  final _db = FirebaseFirestore.instance;

  late Rx<ExamStateModel> state;
  Timer? _ticker;
  bool _paused = false;

  Question get currentQuestion => exam.questions[state.value.currentIndex];

  int get total => exam.questions.length;

  int get answeredCount => state.value.answers.length;

  int get flaggedCount => flaggedQuestions.length;

  int get unansweredCount => total - answeredCount;

  int get currentNumber => state.value.currentIndex + 1;

  final Map<String, dynamic> answers = {};
  final Map<String, TextEditingController> shortControllers = {};
  final RxSet<String> flaggedIds = <String>{}.obs;
  final RxSet<String> flaggedQuestions = <String>{}.obs;
  final clearTick = 0.obs;


  @override
  void onInit() {
    super.onInit();
    state = ExamStateModel(
      examId: exam.id,
      secondsLeft: exam.duration.inSeconds,
    ).obs;

    _startTicker();

    Future.microtask(() async {
      await _loadSavedAnswers();
      state.refresh();
    });
  }

  // ===========================
  // 🔹 EXAM BAŞLATMA (Yeni yapı)
  // ===========================
  static Future<ExamController> createFromFilters() async {
    final createExamController = Get.find<CreateExamController>();
    final questions = await createExamController.generateExamQuestions();

    // ✅ Exam modelinde createdAt zorunlu olduğu için eklendi
    final exam = Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Custom Exam',
      questions: questions,
      duration: Duration(minutes: questions.length),
      // 1 dk/soru
      createdAt: DateTime.now(),
    );

    final controller = ExamController(exam);
    Get.put(controller);
    return controller;
  }

  // ===========================
  // 🔹 Timer, navigation, progress vb.
  // ===========================
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.value.submitted) return;
      if (_paused) return; // ⬅️ paused ise zaman akmasın
      final left = state.value.secondsLeft - 1;
      if (left <= 0) {
        submit(auto: true);
      } else {
        state.value = state.value.copyWith(secondsLeft: left);
        state.refresh();
      }
    });
  }

  void pauseTimer() {
    _paused = true;
  }

  void resumeTimer() {
    if (!state.value.submitted) {
      _paused = false;
    }
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

  Future<void> _loadSavedAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'answers_${exam.id}';
    final saved = prefs.getString(key);
    if (saved == null) return;

    try {
      final decoded = jsonDecode(saved);
      if (decoded is Map<String, dynamic>) {
        answers.clear();
        decoded.forEach((key, value) {
          answers[key] = value;
        });

        state.value = state.value.copyWith(
          answers: Map<String, dynamic>.from(answers),
        );
        state.refresh();
        updateProgress();
      }
    } catch (e) {
      debugPrint('Failed to load saved answers: $e');
    }
  }

  Future<void> _persistAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'exam_${exam.id}_answers';

    final safeMap = <String, dynamic>{};
    answers.forEach((key, value) {
      if (value is Map) {
        safeMap[key] =
            value.map((k, v) => MapEntry(k.toString(), v.toString()));
      } else if (value is List) {
        safeMap[key] = value.map((e) => e.toString()).toList();
      } else {
        safeMap[key] = value.toString();
      }
    });

    await prefs.setString(key, jsonEncode(safeMap));
  }

  void saveAnswer(String questionId, dynamic answer) {
    final newAnswers = Map<String, dynamic>.from(state.value.answers);

    if (answer == null || (answer is String && answer.trim().isEmpty)) {
      answers.remove(questionId);
      newAnswers.remove(questionId);
    } else {
      answers[questionId] = answer;
      newAnswers[questionId] = answer;
    }

    state.value = state.value.copyWith(answers: newAnswers);
    state.refresh();
    updateProgress();
    _persistAnswers();
  }

  void toggleFlag(String questionId) {
    if (flaggedQuestions.contains(questionId)) {
      flaggedQuestions.remove(questionId);
    } else {
      flaggedQuestions.add(questionId);
    }
    state.refresh();
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= exam.questions.length) return;
    state.value = state.value.copyWith(currentIndex: index);
    state.refresh();
  }

  bool isAnswered(String questionId) => answers.containsKey(questionId);

  bool isFlagged(String questionId) => flaggedQuestions.contains(questionId);

  void clearAnswer(String questionId) {
    // 🔹 1. Local cache
    answers.remove(questionId);

    // 🔹 2. State answers'tan da sil
    final newAnswers = Map<String, dynamic>.from(state.value.answers);
    newAnswers.remove(questionId);

    state.value = state.value.copyWith(
      answers: newAnswers,
    );
    state.refresh();

    // 🔹 3. MCQ key-reset için
    clearTick.value++;

    // 🔹 4. Progress yeniden hesapla
    updateProgress();
  }


  void updateProgress() {
    final total = exam.questions.length;
    final answered = answers.length;
    final unanswered = total - answered;
    final newState = state.value.copyWith(
      answered: answered,
      unanswered: unanswered,
    );
    state.value = newState;
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

    final snapshotAnswers = Map<String, dynamic>.from(state.value.answers);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exam_${exam.id}_answers');

    // 1️⃣ Kullanıcının cevaplarını ekleyerek yeni exam oluştur
    final resultExam = exam.copyWith(answers: snapshotAnswers);

    try {
      // 2️⃣ AI değerlendirmesi
      final aiService = Get.find<AiService>();
      final aiEval = await aiService.evaluateExam(
        exam: resultExam,
        userAnswers: snapshotAnswers,
      );


      //print("AI değerlendirmesi tamamlandı soru başına dönen CORRECTANSWERLAR:");
      //for (final qEval in aiEval.questionEvaluations)
      //  print(qEval.correctAnswer);

      final aiResult = AiExamResult.fromEvaluateResult(aiEval);

      final Map<String, dynamic> aiFeedbackMap = {
        for (final qEval in aiEval.questionEvaluations)
          qEval.questionGeneralIndex: qEval.explanation,
      };

      // 3️⃣ Exam istatistiklerini güncelle
      final updatedExam = resultExam.copyWith(
        aiFeedback: aiFeedbackMap,
        stats: {
          'correct': aiResult.correctCount,
          'wrong': aiResult.wrongCount,
          'unanswered': aiResult.unansweredCount,
        },
        aiResult: aiEval,
      );

      // 🔥🔥 4️⃣ EXAM XP KAYDI (FIRESTORE'A YAZILAN YER)
      await ExamXpService.saveExamResult(
        exam: updatedExam,
        aiResult: aiResult,
      );

      // 5️⃣ Sonuç sayfasına yönlendir
      Get.offAll(
        () => const ExamResultPage(),
        arguments: {
          'exam': updatedExam,
          'aiResult': aiResult,
        },
      );
    } catch (e, st) {
      debugPrint("⚠️ AI evaluation failed: $e\n$st");

      Get.offAll(
        () => const ExamResultPage(),
        arguments: {
          'exam': resultExam,
        },
      );
    }
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
