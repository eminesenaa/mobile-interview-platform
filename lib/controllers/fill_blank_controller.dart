import 'package:get/get.dart';
import '../models/question.dart';

class FillBlankController extends GetxController {
  final Question question;
  FillBlankController(this.question);

  /// 🔹 Kullanıcının doldurduğu cevaplar
  final answers = <String>[].obs;

  /// 🔹 AI değerlendirme sonucu
  final aiResult = ''.obs;

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

  /// AI değerlendirmesi (ShortAnswer mantığıyla aynı)
  Future<void> submitAnswersWithAI() async {
    final userAns = answers.join(" | ").trim();
    if (userAns.isEmpty) {
      aiResult.value = "Please fill in all blanks before submitting.";
      return;
    }

    final helper = question.aiPromptHelper ?? "";
    final prompt = """
Question: ${question.title}
Blanks: $userAns
AI Prompt Helper: $helper
""";

    // TODO: Burada OpenAI/Gemini/LLM çağrısı yapılacak
    // Simülasyon:
    aiResult.value =
        "AI evaluated your fill-in answers.\nYour input: $userAns\nHelper: $helper";
  }
}
