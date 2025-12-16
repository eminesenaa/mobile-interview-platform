import 'package:get/get.dart';

import 'package:interview_project/models/question.dart';
import 'package:interview_project/services/ai/ai_service.dart';

import '../services/xp_service.dart';
import '../services/solve_service.dart';

import '../../runner/controller/question_runner_controller.dart';

class FillBlankController extends GetxController {
  final Question question;
  FillBlankController(this.question);

  final answers = <String>[].obs;

  final aiResult = ''.obs;
  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);

  final AiService _ai = Get.find<AiService>();
  final earnedXp = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Boşluk sayısını hesapla
    final blanks = (question.description?.split("___").length ?? 1) - 1;
    answers.assignAll(List.filled(blanks, ""));
  }

  void updateAnswer(int index, String value) {
    if (index >= 0 && index < answers.length) {
      answers[index] = value;
    }

    final allFilled = answers.every((e) => e.trim().isNotEmpty);

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(allFilled);
    }
  }

  Future<void> submitAnswersWithAI() async {
    final userAns = answers.map((e) => e.trim()).toList();
    final joined = userAns.join(" | ").trim();

    if (joined.isEmpty || userAns.any((e) => e.isEmpty)) {
      aiResult.value = "Please fill in all blanks before submitting.";
      return;
    }

    await _evaluateWithAi(userAns);
  }

  Future<void> _evaluateWithAi(List<String> blanks) async {
    isEvaluating.value = true;

    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: blanks.join(' | '),
      );
      aiMeta.value = res;

      // XP hesaplama
      final score = (res.score ?? 0).toInt();
      final xp = XpService.computeXp(
        baseXp: question.xp,
        score: score,
      );
      earnedXp.value = xp;

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";

      aiResult.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      // Firestore + streak tek satır
      await SolveService.savePracticeResult(
        question: question,
        score: score,
        earnedXp: xp,
      );
    } catch (e, st) {
      print("AI error: $e\n$st");
      aiResult.value =
          "AI error occurred. Try again.\n${question.aiPromptHelper ?? ''}";
    } finally {
      isEvaluating.value = false;
    }
  }
}
