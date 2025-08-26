// ===================== File: lib/controllers/short_answer_controller.dart =====================
// Purpose: Short Answer tipi sorular için controller.
//          Kullanıcının cevabını tutar ve AI ile değerlendirilmesini sağlar.
// ==========================================================================

import 'package:get/get.dart';
import '../models/question.dart';

class ShortAnswerController extends GetxController {
  final Question question;

  ShortAnswerController(this.question);

  // 🔹 Kullanıcının yazdığı cevap
  var answer = ''.obs;

  // 🔹 AI değerlendirme sonucu
  var aiResult = ''.obs;

  /// Kullanıcının cevabını AI Prompt Helper ile birleştirip değerlendirme yapar
  Future<void> submitAnswerWithAI() async {
    final userAns = answer.value.trim();
    if (userAns.isEmpty) return;

    // 🔹 Prompt hazırlama
    final prompt = """
Question: ${question.description}
AI Prompt Helper: ${question.aiPromptHelper}
User Answer: $userAns
""";

    // 🔹 Burada LLM API çağrısı yapılmalı (ör. OpenAI, Gemini, vs.)
    // Şimdilik mock cevap
    aiResult.value =
        "✅ AI değerlendirmesi (mock):\nCevabın: \"$userAns\"\n\nPrompt Helper ipucu: ${question.aiPromptHelper}";
  }
}
