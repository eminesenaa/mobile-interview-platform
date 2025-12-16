import 'package:get/get.dart';

import 'package:interview_project/models/question.dart';
import 'package:interview_project/services/ai/ai_service.dart';

import '../services/xp_service.dart';
import '../services/solve_service.dart';

import '../../runner/controller/question_runner_controller.dart';

class ShortAnswerController extends GetxController {
  final Question question;

  ShortAnswerController(this.question);

  final answer = ''.obs;
  final isSubmitted = false.obs;

  final AiService _ai = Get.find<AiService>();

  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);
  final aiFeedback = ''.obs;

  final earnedXp = 0.obs;

  void updateAnswer(String v) {
    answer.value = v;

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(v.trim().isNotEmpty);
    }
  }

  Future<void> submit() async {
    final userText = answer.value.trim();

    if (userText.isEmpty) {
      Get.snackbar('Answer required', 'Please type your answer');
      return;
    }

    isSubmitted.value = true;
    await _evaluateWithAi(userText);
  }

  // ---------------------------------
  // AI değerlendirme + XP + Firestore
  // ---------------------------------
  Future<void> _evaluateWithAi(String userText) async {
    isEvaluating.value = true;

    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: userText,
      );
      aiMeta.value = res;

      // XP hesaplama (XPSERVICE)
      final score = (res.score ?? 0).toInt();
      final xp = XpService.computeXp(
        baseXp: question.xp,
        score: score,
      );
      earnedXp.value = xp;

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";

      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      // Kayıt SolveService üzerinden (tek satır)
      await SolveService.savePracticeResult(
        question: question,
        score: score,
        earnedXp: xp,
      );
    } catch (e, st) {
      print('AI error (short): $e\n$st');
      aiFeedback.value = "AI error occurred. Try again.\n${question.aiPromptHelper ?? ''}";
    } finally {
      isEvaluating.value = false;
    }
  }
}
