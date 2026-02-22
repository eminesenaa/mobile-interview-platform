import 'package:get/get.dart';

import 'package:interview_project/models/question.dart';
import 'package:interview_project/services/ai/ai_service.dart';

import '../services/xp_service.dart';
import '../services/solve_service.dart';

import '../../runner/controller/question_runner_controller.dart';

import 'package:interview_project/services/sfx/sound_service.dart';

class McqController extends GetxController {
  McqController(this.question, {this.shuffleOptions = false});

  final Question question;
  final bool shuffleOptions;

  final solveState = SolveState.idle.obs;

  final AiService _ai = Get.find<AiService>();

  final options = <String>[].obs;
  final selectedIndex = (-1).obs;
  final isSubmitted = false.obs;
  final isCorrect = false.obs;

  final aiFeedback = "".obs;
  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiResult = Rx<AiEvaluateResult?>(null);

  final earnedXp = 0.obs;
  int? _correctIndex;

  @override
  void onInit() {
    super.onInit();

    final base = (question.options ?? <String>[]).map((e) => e.trim()).toList();
    if (shuffleOptions) base.shuffle();
    options.assignAll(base);

    final ans = (question.correctAnswer ?? '').trim();
    if (ans.isNotEmpty) {
      final idx = options.indexWhere(
        (o) => o.trim().toLowerCase() == ans.toLowerCase(),
      );
      _correctIndex = idx == -1 ? null : idx;
    }
  }

  // ---------------------------------
  // SELECT OPTION
  // ---------------------------------
  void select(int index) {
    // ❌ bunu kaldır
    // if (isSubmitted.value) return;

    // ✅ Runner kilitliyse engelle
    if (Get.isRegistered<QuestionRunnerController>()) {
      final runner = Get.find<QuestionRunnerController>();
      if (runner.isLocked.value) return;
    }

    selectedIndex.value = index;
    solveState.value = SolveState.canSubmit;

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(true);
    }
  }


  // ---------------------------------
  // SUBMIT
  // ---------------------------------
  Future<void> submit() async {
    if (selectedIndex.value == -1) {
      Get.snackbar('No selection', 'Please select an option.');
      return;
    }

    solveState.value = SolveState.submitting;
    isSubmitted.value = true;

    final chosen = options[selectedIndex.value];
    final correct = (question.correctAnswer ?? '').trim();

    isCorrect.value =
        chosen.trim().toLowerCase() == correct.trim().toLowerCase();

    await _evaluateWithAi(chosen);
  }

  bool isOptionCorrect(int index) {
    if (_correctIndex == null) return false;
    return index == _correctIndex;
  }

  int? get correctIndex => _correctIndex;

  // ---------------------------------
  // AI değerlendirmesi + solve service
  // ---------------------------------
  Future<void> _evaluateWithAi(String chosen) async {
    isEvaluating.value = true;

    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: chosen,
      );
      aiResult.value = res;

      // 🔊 Play sound based on result
      if (res.correct) {
        SoundService.play(SoundEffect.correctAnswer);
      } else {
        SoundService.play(SoundEffect.wrongAnswer);
      }

      final score = (res.score ?? 0).toInt();
      final xp = XpService.computeXp(
        baseXp: question.xp,
        score: score,
      );
      earnedXp.value = xp;

      final verdict = isCorrect.value ? "✅ Correct." : "❌ Incorrect.";
      final explain =
          (res.explanation.isNotEmpty) ? "\n${res.explanation}" : "";

      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      await SolveService.savePracticeResult(
        question: question,
        score: score,
        earnedXp: xp,
      );

      solveState.value =
          isCorrect.value ? SolveState.solvedCorrect : SolveState.solvedWrong;
    } catch (e, st) {
        print("AI error (mcq): $e\n$st");
      aiFeedback.value =
          "AI evaluation failed. Please try again.\n${question.aiPromptHelper ?? ''}";
      solveState.value = SolveState.solvedWrong;
    } finally {
      isEvaluating.value = false;
    }
  }

  // ---------------------------------
  // RESET (TRY AGAIN)
  // ---------------------------------
  void resetSelection() {
    selectedIndex.value = -1;
    isSubmitted.value = false;
    isCorrect.value = false;
    aiResult.value = null;
    aiFeedback.value = '';
    earnedXp.value = 0;
    solveState.value = SolveState.idle;

    if (Get.isRegistered<QuestionRunnerController>()) {
      final runner = Get.find<QuestionRunnerController>();
      runner.solveState.value = SolveState.idle;
      runner.isLocked.value = false;
      runner.setCanSubmit(false);
    }

  }
}
