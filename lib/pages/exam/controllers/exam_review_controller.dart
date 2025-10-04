import 'package:get/get.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';

/// 🔸 Review sırasında kullanılacak durum enum'u
enum ReviewStatus { correct, wrong, unanswered }

class ExamReviewController extends GetxController {
  final Exam exam;

  ExamReviewController(this.exam);

  /// Şu an görüntülenen soru indexi
  final currentIndex = 0.obs;

  /// Kullanıcının sınav sırasında verdiği yanıtlar (Result page’den alınacak)
  final Map<String, dynamic> answers = {};

  /// Doğru - yanlış - boş istatistikleri (şimdilik statik değerler)
  final correctIds = <String>[].obs;
  final wrongIds = <String>[].obs;

  /// Geçerli soru
  Question get currentQuestion => exam.questions[currentIndex.value];

  /// Toplam soru sayısı
  int get total => exam.questions.length;

  /// Şu anki soru numarası (1-based)
  int get currentNumber => currentIndex.value + 1;

  /// 🔹 Soruya git
  void goToQuestion(int index) {
    if (index >= 0 && index < exam.questions.length) {
      currentIndex.value = index;
    }
  }

  /// 🔹 Sonraki soru
  void next() {
    if (currentIndex.value < exam.questions.length - 1) {
      currentIndex.value++;
    }
  }

  /// 🔹 Önceki soru
  void prev() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  /// 🔹 Bir sorunun cevabı var mı?
  bool isAnswered(String questionId) => answers.containsKey(questionId);

  /// 🔹 Sorunun review durumunu döndür (şimdilik dummy, AI geldiğinde güncellenecek)
  ReviewStatus getQuestionStatus(String questionId) {
    if (correctIds.contains(questionId)) return ReviewStatus.correct;
    if (wrongIds.contains(questionId)) return ReviewStatus.wrong;
    return ReviewStatus.unanswered;
  }

  /// 🔹 (İleride) doğru cevap kontrolü
  bool isCorrect(String questionId) => correctIds.contains(questionId);

  /// 🔹 Sayısal özetler
  int get correctCount => correctIds.length;
  int get wrongCount => wrongIds.length;
  int get unansweredCount => total - (correctCount + wrongCount);
}
