import 'package:get/get.dart';
import '../models/question.dart';

/// Çoktan Seçmeli (MCQ) controller
/// - Kullanıcı seçimi
/// - Submit sonrası hem local kontrol (doğru/yanlış renklendirme)
/// - Hem de LLM yorumlaması (aiPromptHelper ile)
class McqController extends GetxController {
  McqController(this.question, {this.shuffleOptions = false});

  final Question question;
  final bool shuffleOptions;

  final options = <String>[].obs;
  final selectedIndex = (-1).obs;

  final isSubmitted = false.obs;
  final isCorrect = false.obs;

  final aiFeedback = "".obs;

  int? _correctIndex;

  @override
  void onInit() {
    super.onInit();

    final base = (question.options ?? <String>[]).map((e) => e.trim()).toList();
    if (shuffleOptions) base.shuffle();
    options.assignAll(base);

    // Doğru şıkkın indexini bul
    final ans = (question.correctAnswer ?? '').trim();
    if (ans.isNotEmpty) {
      final idx = options.indexWhere(
          (o) => o.trim().toLowerCase() == ans.toLowerCase());
      _correctIndex = idx == -1 ? null : idx;
    }

    print("Options: $options");
    print("Correct Answer (from Firestore): ${question.correctAnswer}");
    print("Correct Index: $_correctIndex");
    print("AI Helper Prompt: ${question.aiPromptHelper}");
  }

  void select(int index) {
    if (isSubmitted.value) return;
    selectedIndex.value = index;
  }

  Future<void> submit() async {
    if (selectedIndex.value == -1) {
      Get.snackbar('Seçim yok', 'Lütfen bir seçenek seç.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      return;
    }

    // ✅ local doğru/yanlış kontrolü
    final chosen = options[selectedIndex.value];
    final correct = question.correctAnswer ?? '';
    isCorrect.value =
        chosen.trim().toLowerCase() == correct.trim().toLowerCase();

    isSubmitted.value = true;

    // 🔹 AI yorumlama
    final helper = question.aiPromptHelper ??
        "Evaluate the selected answer logically. Explain if it is correct or not.";
    final prompt =
        "Question: ${question.title}\nOptions: ${options.join(", ")}\nUser Answer: $chosen\nHelper: $helper";

    final response = await _fakeLLMResponse(chosen, helper);
    aiFeedback.value = response;
  }

  /// UI renklendirme için
  bool isOptionCorrect(int index) {
    if (_correctIndex == null) return false;
    return index == _correctIndex;
  }

  int? get correctIndex => _correctIndex;

  Future<String> _fakeLLMResponse(String chosen, String helper) async {
    await Future.delayed(const Duration(seconds: 1));
    final correct = question.correctAnswer ?? "";
    if (chosen.toLowerCase().trim() == correct.toLowerCase().trim()) {
      return "✅ Doğru! $helper";
    } else {
      return "❌ Yanlış. Doğru cevap: $correct\n$helper";
    }
  }
}
