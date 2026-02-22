import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/models/question.dart';
import 'package:interview_project/services/ai/ai_service.dart';

import '../services/xp_service.dart';
import '../services/solve_service.dart';

import '../../runner/controller/question_runner_controller.dart';
import 'package:interview_project/services/sfx/sound_service.dart';

enum SolveState {
  idle,
  canSubmit,
  submitting,
  solvedCorrect,
  solvedWrong,
}

class ShortAnswerController extends GetxController {
  final Question question;

  ShortAnswerController(this.question);

  final answer = ''.obs;
  final isSubmitted = false.obs;

  final solveState = SolveState.idle.obs;

  final textController = TextEditingController();

  final AiService _ai = Get.find<AiService>();

  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);
  final aiFeedback = ''.obs;

  final earnedXp = 0.obs;

  // ---------------------------------
  // INPUT CHANGE
  // ---------------------------------
  void updateAnswer(String v) {
    answer.value = v;

    if (v.trim().isNotEmpty) {
      solveState.value = SolveState.canSubmit;
    } else {
      solveState.value = SolveState.idle;
    }

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(v.trim().isNotEmpty);
    }
  }

  // ---------------------------------
  // SUBMIT
  // ---------------------------------
  Future<void> submit() async {
    final userText = answer.value.trim();

    if (userText.isEmpty) {
      Get.snackbar('Answer required', 'Please type your answer');
      return;
    }

    solveState.value = SolveState.submitting;
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

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";

      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      await SolveService.savePracticeResult(
        question: question,
        score: score,
        earnedXp: xp,
      );

      // 🔥 SOLVE STATE
      if (res.correct) {
        solveState.value = SolveState.solvedCorrect;
      } else {
        solveState.value = SolveState.solvedWrong;
      }
    } catch (e, st) {
      print('AI error (short): $e\n$st');
      aiFeedback.value =
          "AI error occurred. Try again.\n${question.aiPromptHelper ?? ''}";
      solveState.value = SolveState.solvedWrong;
    } finally {
      isEvaluating.value = false;
    }
  }

  // ---------------------------------
  // RESET (TRY AGAIN)
  // ---------------------------------
  void resetAnswer() {
    answer.value = '';
    textController.clear();
    isSubmitted.value = false;
    aiMeta.value = null;
    aiFeedback.value = '';
    earnedXp.value = 0;
    solveState.value = SolveState.idle;

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(false);
    }
  }
}
