// lib/pages/question_types/controllers/mcq_controller.dart
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';

/// Çoktan Seçmeli (MCQ) controller
/// - Kullanıcı seçimi
/// - Submit sonrası hem local kontrol (doğru/yanlış renklendirme)
/// - Hem de LLM yorumlaması (aiPromptHelper ile)
class McqController extends GetxController {
  McqController(this.question, {this.shuffleOptions = false});

  final Question question;
  final bool shuffleOptions;

  /// Ekranda gösterilecek (şu anki sıralamasıyla) şıklar
  final options = <String>[].obs;

  /// Kullanıcının seçtiği index (-1 = seçilmedi)
  final selectedIndex = (-1).obs;

  /// Submit sonrası UI state
  final isSubmitted = false.obs;
  final isCorrect = false.obs;

  /// Ekranda göstereceğimiz AI metni
  final aiFeedback = "".obs;

  /// (Yeni) AI ayrıntıları ve yüklenme durumu
  final AiService _ai = Get.find<AiService>();
  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiResult = Rx<AiEvaluateResult?>(null);

  int? _correctIndex;

  @override
  void onInit() {
    super.onInit();

    // Orijinal seçenekleri al (trimleyip)
    final base = (question.options ?? <String>[]).map((e) => e.trim()).toList();
    if (shuffleOptions) base.shuffle();
    options.assignAll(base);

    // Doğru şıkkın indexini bul (Firestore’dan gelen doğru cevap metnine göre)
    final ans = (question.correctAnswer ?? '').trim();
    if (ans.isNotEmpty) {
      final idx = options.indexWhere(
            (o) => o.trim().toLowerCase() == ans.toLowerCase(),
      );
      _correctIndex = idx == -1 ? null : idx;
    }

    // debug
    // print("Options: $options");
    // print("Correct Answer (from Firestore): ${question.correctAnswer}");
    // print("Correct Index: $_correctIndex");
    // print("AI Helper Prompt: ${question.aiPromptHelper}");
  }

  void select(int index) {
    if (isSubmitted.value) return;
    selectedIndex.value = index;
  }

  Future<void> submit() async {
    if (selectedIndex.value == -1) {
      Get.snackbar(
        'Seçim yok',
        'Lütfen bir seçenek seç.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // ✅ Lokal doğru/yanlış kontrolü (UI renklendirme için)
    final chosen = options[selectedIndex.value];
    final correct = (question.correctAnswer ?? '').trim();
    isCorrect.value = chosen.trim().toLowerCase() == correct.toLowerCase();

    isSubmitted.value = true;

    // 🔹 AI yorumlama (açıklama + doğru/yanlış)
    await _evaluateWithAi(chosen);
  }

  /// UI renklendirme için
  bool isOptionCorrect(int index) {
    if (_correctIndex == null) return false;
    return index == _correctIndex;
  }

  int? get correctIndex => _correctIndex;

  // ------------------- AI -------------------

  /// Gerçek AI çağrısı; hata olursa mevcut fake/mesaj davranışını korur
  Future<void> _evaluateWithAi(String chosen) async {
    isEvaluating.value = true;
    try {
      // Seçenekler shuffle edilmiş olabileceği için **metni** gönderiyoruz.
      final res = await _ai.evaluate(
        question: question,
        userAnswer: chosen,
      );
      aiResult.value = res;

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain =
      (res.explanation.isNotEmpty) ? "\n${res.explanation}" : "";

      // 👉 ESKİ DAVRANIŞ: ekranda görünen alan aiFeedback
      aiFeedback.value = "$verdict$explain";
    } catch (e, st) {
      // debug’da gerçek hatayı görebil
      // ignore: avoid_print
      print("AI error (mcq): $e\n$st");

      // Fallback – önceki fake davranışı bozmadan:
      final helper = question.aiPromptHelper ??
          "Evaluate the selected answer logically. Explain if it is correct or not.";
      aiFeedback.value = "❌ Yanlış.\n$helper";
    } finally {
      isEvaluating.value = false;
    }
  }
}
