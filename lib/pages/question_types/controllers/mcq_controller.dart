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
  }

  void select(int index) {
    if (isSubmitted.value) return;
    selectedIndex.value = index;
  }

  Future<void> submit() async {
    if (selectedIndex.value == -1) {
      Get.snackbar(
        'No selection',
        'Please select an option.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // ✅ Lokal doğru/yanlış kontrolü (UI renklendirme için)
    final chosen = options[selectedIndex.value];
    final correct = (question.correctAnswer ?? '').trim();
    isCorrect.value =
        chosen.trim().toLowerCase() == correct.trim().toLowerCase();

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

  /// Gerçek AI çağrısı; hata olursa lokal sonucu korur
  Future<void> _evaluateWithAi(String chosen) async {
    isEvaluating.value = true;
    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: chosen,
      );
      aiResult.value = res;

      // Eğer AI'dan gelen sonuç varsa onu kullan
      final verdict = isCorrect.value ? "✅ Correct." : "❌ Incorrect.";
      final explain =
          (res.explanation.isNotEmpty) ? "\n${res.explanation}" : "";
      aiFeedback.value = "$verdict$explain";
    } catch (e, st) {
      // debug’da gerçek hatayı görebil
      print("AI error (mcq): $e\n$st");

      // Fallback – lokal kontrol sonucunu göster
      final verdict = isCorrect.value ? "✅ Correct." : "❌ Incorrect.";
      final helper = question.aiPromptHelper ??
          "Evaluate the selected answer logically. Explain if it is correct or not.";
      aiFeedback.value = "$verdict\n$helper";
    } finally {
      isEvaluating.value = false;
    }
  }
}
