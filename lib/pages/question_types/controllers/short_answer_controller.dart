// lib/pages/question_types/controllers/short_answer_controller.dart
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';

class ShortAnswerController extends GetxController {
  final Question question;
  ShortAnswerController(this.question);

  /// Kullanıcının yazdığı cevap (UI'da TextField onChanged ile güncellenir)
  final answer = ''.obs;

  /// (varsa) local kontrol sonucu / UI durumların
  final isSubmitted = false.obs;

  // ---------- AI entegrasyonu (yeni) ----------
  final AiService _ai = Get.find<AiService>();     // main.dart’ta put edildi
  final isEvaluating = false.obs;                  // "Send" loading
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);
  final aiFeedback = ''.obs;                       // ekranda göstereceğimiz metin

  void updateAnswer(String v) => answer.value = v;

  /// Kullanıcı cevabı gönderir
  Future<void> submit() async {
    final userText = answer.value.trim();
    if (userText.isEmpty) {
      Get.snackbar('Answer required', 'Please type your answer');
      return;
    }

    // (varsa) local kontrol / isSubmitted set
    isSubmitted.value = true;

    // AI değerlendirmesi
    await _evaluateWithAi(userText);
  }

  // ---------- PRIVATE: AI çağrısı ----------
  Future<void> _evaluateWithAi(String userText) async {
    isEvaluating.value = true;
    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: userText, // short-answer → düz metin
      );
      aiMeta.value = res;

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";
      aiFeedback.value = "$verdict$explain";
    } catch (e, st) {
      // debug için logla; istersen kaldırabilirsin
      // ignore: avoid_print
      print('AI error (short): $e\n$st');

      // fallback — mevcut davranışını bozma
      final helper = question.aiPromptHelper ?? '';
      aiFeedback.value =
      "AI evaluated your answer.\nYour input: $userText\nHelper: $helper\n\n(Note: fallback response due to AI error)";
    } finally {
      isEvaluating.value = false;
    }
  }
}
