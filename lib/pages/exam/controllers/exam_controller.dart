// lib/pages/exam/controllers/exam_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/exam/exam_result_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamController extends GetxController {
  final Exam exam;

  ExamController(this.exam);

  final _db = FirebaseFirestore.instance;

  late Rx<ExamStateModel> state;
  Timer? _ticker;

  Question get currentQuestion => exam.questions[state.value.currentIndex];

  int get total => exam.questions.length;

  int get answeredCount => state.value.answers.length;

  int get flaggedCount => flaggedQuestions.length;

  int get unansweredCount => total - answeredCount;

  int get currentNumber => state.value.currentIndex + 1;

  /// Kullanıcının verdiği yanıtları tutar (questionId -> answer)
  final Map<String, dynamic> answers = {};

  /// Short answer geçici TextEditingController cache (questionId -> controller)
  final Map<String, TextEditingController> shortControllers = {};

  /// Kullanıcının işaretlediği (flag) sorular
  final RxSet<String> flaggedIds = <String>{}.obs;

  /// 🔹 Flag’lenmiş sorular (ID seti)
  final RxSet<String> flaggedQuestions = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // ✅ 1. state her zaman senkron olarak initialize edilmeli
    state = ExamStateModel(
      examId: exam.id,
      secondsLeft: exam.duration.inSeconds,
    ).obs;

    // ✅ 2. Timer başlat, ardından async yükleme çalışsın (UI crash yapmaz)
    _startTicker();

    // ✅ 3. SharedPreferences'tan eski cevapları asenkron yükle
    Future.microtask(() async {
      await _loadSavedAnswers();
      state.refresh();
    });
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

  /// SharedPreferences'tan kaydedilmiş cevapları yükler
  Future<void> _loadSavedAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'answers_${exam.id}';
    final saved = prefs.getString(key);
    if (saved == null) return;

    try {
      final decoded = jsonDecode(saved);

      if (decoded is Map<String, dynamic>) {
        // 1️⃣ Kaydedilmiş cevapları belleğe al
        answers.clear();
        decoded.forEach((key, value) {
          answers[key] = value;
        });

        // 2️⃣ state’i güncelle (UI tarafı yeniden inşa edilsin)
        state.value = state.value.copyWith(
          answers: Map<String, dynamic>.from(answers),
        );
        state.refresh();

        // 3️⃣ progress değerlerini yenile
        updateProgress();
      }
    } catch (e) {
      debugPrint('Failed to load saved answers: $e');
    }
  }

  /// SharedPreferences'a güncel cevapları kaydeder
  Future<void> _persistAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'exam_${exam.id}_answers';

    // 🔹 JSON'a çevrilebilir bir map oluştur
    final safeMap = <String, dynamic>{};
    answers.forEach((key, value) {
      if (value is Map) {
        // iç içe Map varsa stringe çevir
        safeMap[key] =
            value.map((k, v) => MapEntry(k.toString(), v.toString()));
      } else if (value is List) {
        // listeleri stringe dönüştür
        safeMap[key] = value.map((e) => e.toString()).toList();
      } else {
        safeMap[key] = value.toString();
      }
    });

    await prefs.setString(key, jsonEncode(safeMap));
  }

  /// Bir sorunun yanıtını kaydeder ve state ile senkron tutar
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
    _persistAnswers(); // Her cevap sonrası Shared'e kaydet
  }

  /// Sorunun işaretlenme durumunu değiştirir
  void toggleFlag(String questionId) {
    if (flaggedQuestions.contains(questionId)) {
      flaggedQuestions.remove(questionId);
    } else {
      flaggedQuestions.add(questionId);
    }
    state.refresh();
  }

  /// 🔹 Belirli bir index’e git
  void goToQuestion(int index) {
    if (index < 0 || index >= exam.questions.length) return;
    // currentIndex’i doğrudan güncelliyoruz
    state.value = state.value.copyWith(currentIndex: index);
    state.refresh();
  }

  /// Bir sorunun yanıtlanıp yanıtlanmadığını kontrol eder
  bool isAnswered(String questionId) => answers.containsKey(questionId);

  /// Bir sorunun flag’li olup olmadığını kontrol eder
  bool isFlagged(String questionId) => flaggedIds.contains(questionId);

  /// Navigator veya istatistikler için ilerleme bilgilerini günceller
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

    // Controller kapanmadan önce cevapların snapshot'ını al
    final snapshotAnswers = Map<String, dynamic>.from(state.value.answers);

    // ❌ Firestore’a kaydetme işlemi kaldırıldı

    // 🔹 SharedPreferences temizle
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exam_${exam.id}_answers');

    // 🔹 Sonuç sayfasına cevaplarla birlikte yönlendir
    final resultExam = exam.copyWith(answers: snapshotAnswers);
    Get.offAll(() => const ExamResultPage(), arguments: resultExam);
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
