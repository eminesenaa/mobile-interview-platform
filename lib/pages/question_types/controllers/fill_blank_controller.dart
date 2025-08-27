// lib/pages/question_types/controllers/fill_blank_controller.dart
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';

class FillBlankController extends GetxController {
  final Question question;
  FillBlankController(this.question);

  /// 🔹 Kullanıcının doldurduğu cevaplar (her boşluk için bir eleman)
  final answers = <String>[].obs;

  /// 🔹 Ekranda gösterdiğin metinsel sonuç (mevcut UI ile uyumlu)
  final aiResult = ''.obs;

  /// 🔹 (Yeni) AI çağrısı yükleniyor mu?
  final isEvaluating = false.obs;

  /// 🔹 (Yeni-opsiyonel) AI’dan gelen ham meta (correct/score/explanation vs.)
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);

  /// 🔹 AI servisi (main.dart’ta Get.put(AiService(), permanent: true) ile enjekte)
  final AiService _ai = Get.find<AiService>();

  @override
  void onInit() {
    super.onInit();

    // Boşluk sayısını bul → her "___" için boş bir string ekle
    final blanks = (question.description?.split("___").length ?? 1) - 1;
    answers.assignAll(List.filled(blanks, ""));
  }

  /// Kullanıcı bir boşluğu doldurduğunda güncelle
  void updateAnswer(int index, String value) {
    if (index >= 0 && index < answers.length) {
      answers[index] = value;
    }
  }

  /// 🔹 AI değerlendirmesi (ShortAnswer mantığına benzer)
  /// Mevcut davranışı bozmayalım: Başarısızlıkta eski simülasyona düşer.
  Future<void> submitAnswersWithAI() async {
    final userAns = answers.map((e) => e.trim()).toList();
    final joined = userAns.join(" | ").trim();

    if (joined.isEmpty || userAns.any((e) => e.isEmpty)) {
      aiResult.value = "Please fill in all blanks before submitting.";
      return;
    }

    await _evaluateWithAi(userAns);
  }

  // -------------------- PRIVATE HELPERS --------------------

  /// Gerçek AI çağrısı; hata olursa eski fake cevaba düşer
  Future<void> _evaluateWithAi(List<String> blanks) async {
    isEvaluating.value = true;
    try {
      // List<String> olarak gönderiyoruz; tek boşluk varsa tek elemanlı olur
      final res = await _ai.evaluate(
        question: question,
          userAnswer: blanks.join(' | '),
      );
      aiMeta.value = res;

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";
      aiResult.value = "$verdict$explain";
    } catch (e, st) {
      print('AI error: $e\n$st');   // 👈 gerçek sebep burada
      final helper = question.aiPromptHelper ?? "";
      final joined = blanks.join(" | ");
      aiResult.value =
      "AI evaluated your fill-in answers.\nYour input: $joined\nHelper: $helper\n\n(Note: fallback response due to AI error)";
    }  finally {
      isEvaluating.value = false;
    }
  }
}
