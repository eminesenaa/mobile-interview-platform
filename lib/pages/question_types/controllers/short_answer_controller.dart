// lib/pages/question_types/controllers/short_answer_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';
import '../../runner/controller/question_runner_controller.dart';

class ShortAnswerController extends GetxController {
  final Question question;

  ShortAnswerController(this.question);

  /// Kullanıcının yazdığı cevap (UI'da TextField onChanged ile güncellenir)
  final answer = ''.obs;

  /// (varsa) local kontrol sonucu / UI durumların
  final isSubmitted = false.obs;

  // ---------- AI entegrasyonu (yeni) ----------
  final AiService _ai = Get.find<AiService>(); // main.dart’ta put edildi
  final isEvaluating = false.obs; // "Send" loading
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);
  final aiFeedback = ''.obs; // ekranda göstereceğimiz metin

  /// Kullanıcının kazandığı XP
  final earnedXp = 0.obs;

  void updateAnswer(String v) {
    answer.value = v;

    // kullanıcı yazmaya başladıysa → send aktif olsun
    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(v.trim().isNotEmpty);
    }
  }

  /// Kullanıcı cevabı gönderir
  Future<void> submit() async {
    final userText = answer.value.trim();
    if (userText.isEmpty) {
      Get.snackbar('Answer required', 'Please type your answer');
      return;
    }

    // (varsa) local kontrol / isSubmitted set
    isSubmitted.value = true;

    // AI değerlendirmesi
    await _evaluateWithAi(userText);
  }

  // ---------- PRIVATE: AI çağrısı ----------
  Future<void> _evaluateWithAi(String userText) async {
    isEvaluating.value = true;
    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: userText, // short-answer → düz metin
      );
      aiMeta.value = res;

      // 🔹 XP hesaplama
      final baseXp = question.xp;
      final normalized = (res.score ?? 0) / 5.0;
      final xp = (normalized * baseXp).round();
      earnedXp.value = xp;

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";

      // Kullanıcıya XP bilgisini de göster
      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      // Firestore güncelle
      await _saveResultToFirestore(res, xp);
    } catch (e, st) {
      // debug için logla; istersen kaldırabilirsin
      // ignore: avoid_print
      print('AI error (short): $e\n$st');

      // fallback — mevcut davranışını bozma
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
    } catch (e, st) {
      print("❌ Firestore save error (short): $e\n$st");
    }
  }
}
