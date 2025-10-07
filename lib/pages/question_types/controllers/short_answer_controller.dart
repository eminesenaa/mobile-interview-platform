// lib/pages/question_types/controllers/short_answer_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';
import '../../runner/controller/question_runner_controller.dart';
import '../../../models/streak.dart';
import '../../../controllers/auth_controller.dart';

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

  Future<void> _evaluateWithAi(String userText) async {
    isEvaluating.value = true;
    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: userText,
      );
      aiMeta.value = res;

      // 🔹 XP hesaplama
      final baseXp = question.xp;
      final normalized = (res.score ?? 0) / 5.0;
      final xp = (normalized * baseXp).round();
      earnedXp.value = xp;

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";

      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      await _saveResultToFirestore(res, xp);
    } catch (e, st) {
      print('AI error (short): $e\n$st');
      final helper = question.aiPromptHelper ?? '';
      aiFeedback.value =
          "AI evaluated your answer.\nYour input: $userText\nHelper: $helper\n\n(Note: fallback response due to AI error)";
    } finally {
      isEvaluating.value = false;
    }
  }

  Future<void> _saveResultToFirestore(
      AiEvaluateResult res, int earnedXp) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final solvedRef = userRef.collection('solved').doc(question.id);

      final snap = await solvedRef.get();
      final newScore = (res.score ?? 0).toDouble();

      if (snap.exists) {
        final data = snap.data() ?? {};
        final prevScore = (data['score'] as num?)?.toDouble() ?? 0.0;
        final prevXp = (data['xpEarned'] as num?)?.toInt() ?? 0;

        if (newScore > prevScore) {
          final xpDiff = earnedXp - prevXp;
          if (xpDiff > 0) {
            await userRef.update({'totalXp': FieldValue.increment(xpDiff)});
          }

          await solvedRef.update({
            'score': newScore,
            'xpEarned': earnedXp,
            'lastAttempt': FieldValue.serverTimestamp(),
          });
        } else {
          await solvedRef.update({
            'lastAttempt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        await userRef.update({'totalXp': FieldValue.increment(earnedXp)});
        await solvedRef.set({
          'status': 'solved',
          'score': newScore,
          'xpEarned': earnedXp,
          'solvedAt': FieldValue.serverTimestamp(),
        });
      }

      // 🔥 STREAK GÜNCELLEME 🔥
      try {
        final auth = Get.find<AuthController>();
        final currentUser = auth.user;
        final uidToUse =
            currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;

        if (uidToUse != null) {
          await Streak.updateStreak(uidToUse);
          print("🔥 [ShortAnswer] Streak updated successfully for user=$uidToUse");
        } else {
          print("⚠️ [ShortAnswer] Streak update skipped (no uid)");
        }
      } catch (e, st) {
        print("❌ [ShortAnswer] Streak update error: $e\n$st");
      }
    } catch (e, st) {
      print("❌ Firestore save error (short): $e\n$st");
    }
  }
}
