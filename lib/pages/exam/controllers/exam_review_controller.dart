import 'package:get/get.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import 'exam_controller.dart';

/// 🔹 Review aşamasında soruların durumunu belirtmek için enum
enum ReviewStatus { correct, wrong, unanswered }

class ExamReviewController extends GetxController {
  final Exam exam;
  final currentIndex = 0.obs;

  /// Kullanıcının sınavda verdiği cevaplar
  final Map<String, dynamic> answers = {};

  /// AI tarafından sağlanan açıklamalar
  final Map<String, dynamic> aiFeedback = {};

  /// İstatistik verileri
  int correctCount = 0;
  int wrongCount = 0;
  int unansweredCount = 0;

  ExamReviewController(this.exam) {
    // Eğer aynı exam ID'li aktif bir ExamController varsa, cevapları oradan al
    if (Get.isRegistered<ExamController>(tag: exam.id)) {
      final examController = Get.find<ExamController>(tag: exam.id);
      answers.addAll(examController.answers);
    } else if (exam.answers != null) {
      // Eğer Exam modeline gömülü cevaplar varsa onları da al
      answers.addAll(exam.answers!);
    }

    // AI açıklamaları
    if (exam.aiFeedback != null) {
      aiFeedback.addAll(exam.aiFeedback!);
    }

    // İstatistik verileri
    final stats = exam.stats ?? {};
    correctCount = stats['correct'] ?? 0;
    wrongCount = stats['wrong'] ?? 0;
    unansweredCount = stats['unanswered'] ?? 0;
  }

  /// Şu anda görüntülenen soru
  Question get currentQuestion => exam.questions[currentIndex.value];

  /// Toplam soru sayısı
  int get total => exam.questions.length;

  /// Şu anki soru numarası
  int get currentNumber => currentIndex.value + 1;

  /// 🔹 Belirli bir index'e git
  void goToQuestion(int index) {
    if (index >= 0 && index < exam.questions.length) {
      currentIndex.value = index;
    }
  }

  /// 🔹 Sonraki soruya geç
  void next() {
    if (currentIndex.value < exam.questions.length - 1) {
      currentIndex.value++;
    }
  }

  /// 🔹 Önceki soruya dön
  void prev() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  /// 🔹 Sorunun durumu (doğru, yanlış, boş)
  ReviewStatus getQuestionStatus(String questionId) {
    final correctIds = (exam.stats?['correctIds'] as List?) ?? [];
    final wrongIds = (exam.stats?['wrongIds'] as List?) ?? [];

    if (correctIds.contains(questionId)) {
      return ReviewStatus.correct;
    } else if (wrongIds.contains(questionId)) {
      return ReviewStatus.wrong;
    } else {
      return ReviewStatus.unanswered;
    }
  }

  /// 🔹 Sorunun cevaplanıp cevaplanmadığını kontrol eder
  bool isAnswered(String questionId) => answers.containsKey(questionId);

  /// 🔹 Sorunun cevabını döndürür (string olarak)
  String getAnswer(String questionId) {
    final value = answers[questionId];
    if (value == null) return '';

    // Eğer Map içinde tutuluyorsa (fillBlank gibi), boş döndürmesin
    if (value is Map && value.isNotEmpty) {
      return value.values.join(', ');
    }
    return value.toString();
  }


  /// 🔹 (İleride) Firestore’a kaydedilecek
  Future<void> saveToLibrary() async {
    Get.snackbar(
      "Saved",
      "Exam added to your library!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
