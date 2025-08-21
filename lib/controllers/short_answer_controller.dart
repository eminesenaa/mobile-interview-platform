import 'package:get/get.dart';
import '../models/question.dart';
// (opsiyonel) solved güncellemek istersen:
// import 'practice_controller.dart';

class ShortAnswerController extends GetxController {
  ShortAnswerController(this.question);
  final Question question;

  final text = ''.obs;                 // kullanıcının yazdığı cevap
  final attemptedWrongOnce = false.obs;
  final revealAnswer = false.obs;
  final isCorrect = false.obs;

  void onChanged(String v) => text.value = v;

  void submit() {
    final input = text.value.trim();
    if (input.isEmpty) {
      Get.snackbar('Oops', 'Lütfen bir cevap yaz 🙈',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      return;
    }

    final ok = _norm(input) == _norm(question.correctAnswer ?? '');
    if (ok) {
      isCorrect.value = true;
      // try { Get.find<QuestionController>().updateStatus(question.id, Status.solved); } catch (_) {}
      Get.snackbar('Tebrikler 🎉', 'Doğru cevap!',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    } else {
      if (!attemptedWrongOnce.value) {
        attemptedWrongOnce.value = true;
        text.value = ''; // ilk yanlışta temizle
        Get.snackbar('Tekrar dene ✍️', 'Ufak bir yazım hatası yapmış olabilirsin.',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Yanlış', 'İstersen "Show answer" ile doğru cevabı görebilirsin.',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      }
    }
  }

  void reset() {
    text.value = '';
    attemptedWrongOnce.value = false;
    revealAnswer.value = false;
    isCorrect.value = false;
  }

  String _norm(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
