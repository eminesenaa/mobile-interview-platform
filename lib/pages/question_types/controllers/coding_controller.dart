import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:get/get.dart';

import 'package:interview_project/models/question.dart';
import 'package:interview_project/services/ai/ai_service.dart';

import '../services/xp_service.dart';
import '../services/solve_service.dart';

import '../../runner/controller/question_runner_controller.dart';
import 'package:interview_project/utils/code_template_sanitizer.dart';
import 'package:interview_project/utils/language_mapper.dart';

class CodingController extends GetxController {
  final Question question;

  late CodeController codeController;
  final currentCode = ''.obs;
  final hasEdited = false.obs;
  late final String _initialCode;

  final AiService _ai = Get.find<AiService>();

  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);
  final aiFeedback = ''.obs;
  final earnedXp = 0.obs;

  final solveState = SolveState.idle.obs;

  CodingController(this.question);

  @override
  void onInit() {
    super.onInit();

    if (solveState.value == SolveState.solvedWrong ||
        solveState.value == SolveState.solvedCorrect) {
      aiMeta.value = null;
      earnedXp.value = 0;
      solveState.value = SolveState.idle;
    }

    final starterRaw = question.codeTemplate ?? '';
    final starter = CodeTemplateSanitizer.sanitize(starterRaw);
    _initialCode = starter;

    codeController = CodeController(
      text: starter,
      language: mapTopicToMode(question.topic),
    );

    currentCode.value = starter;
    hasEdited.value = false;

    codeController.addListener(() {
      final txt = codeController.text;
      currentCode.value = txt;
      hasEdited.value = (txt != _initialCode);

      solveState.value =
          hasEdited.value ? SolveState.canSubmit : SolveState.idle;

      if (Get.isRegistered<QuestionRunnerController>()) {
        Get.find<QuestionRunnerController>().setCanSubmit(hasEdited.value);
      }
    });
  }

  String getCode() => currentCode.value;

  bool get edited => hasEdited.value;

  void setCode(String code) {
    codeController.text = code;
    currentCode.value = code;
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  // -------------------------------
  // AI değerlendirme + XP + Firestore
  // -------------------------------
  Future<void> evaluateWithAi() async {
    solveState.value = SolveState.submitting;
    isEvaluating.value = true;

    final code = currentCode.value.trim();

    if (code.isEmpty) {
      solveState.value = SolveState.idle;
      Get.snackbar('Empty code', 'Please write some code before sending.');
      return;
    }

    isEvaluating.value = true;

    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: code,
      );

      aiMeta.value = res;

      // XP hesaplama
      final score = (res.score ?? 0).toInt();
      final xp = XpService.computeXp(
        baseXp: question.xp,
        score: score,
      );
      earnedXp.value = xp;

      final verdict = res.correct ? "✅ Correct." : "❌ Incorrect.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";

      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      // Firestore + streak kaydı (tek satır)
      await SolveService.savePracticeResult(
        question: question,
        score: score,
        earnedXp: xp,
      );
      solveState.value =
          res.correct ? SolveState.solvedCorrect : SolveState.solvedWrong;
    } catch (e, st) {
      solveState.value = SolveState.solvedWrong;
      print("❌ AI error (coding): $e\n$st");
      Get.snackbar("AI error", "Something went wrong. Try again.");
    } finally {
      isEvaluating.value = false;
    }
  }

  void resetCode() {
    codeController.text = _initialCode;
    currentCode.value = _initialCode;
    hasEdited.value = false;

    aiMeta.value = null;
    earnedXp.value = 0;
    isEvaluating.value = false;

    solveState.value = SolveState.idle;

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(false);
    }
  }
}
