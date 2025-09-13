// lib/pages/question_types/controllers/fill_blank_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';

class FillBlankController extends GetxController {
  final Question question;
  FillBlankController(this.question);

  /// 🔹 Kullanıcının doldurduğu cevaplar (her boşluk için bir eleman)
  final answers = <String>[].obs;

  /// 🔹 Ekranda gösterdiğin metinsel sonuç (mevcut UI ile uyumlu)
  final aiResult = ''.obs;

  /// 🔹 (Yeni) AI çağrısı yükleniyor mu?
  final isEvaluating = false.obs;

  /// 🔹 (Yeni-opsiyonel) AI’dan gelen ham meta (correct/score/explanation vs.)
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);

  /// 🔹 AI servisi (main.dart’ta Get.put(AiService(), permanent: true) ile enjekte)
  final AiService _ai = Get.find<AiService>();

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

  /// 🔹 AI değerlendirmesi (ShortAnswer mantığına benzer)
  Future<void> submitAnswersWithAI() async {
    final userAns = answers.map((e) => e.trim()).toList();
    final joined = userAns.join(" | ").trim();

    if (joined.isEmpty || userAns.any((e) => e.isEmpty)) {
      aiResult.value = "Please fill in all blanks before submitting.";
      return;
    }

    await _evaluateWithAi(userAns);
  }

  // -------------------- PRIVATE HELPERS --------------------
  Future<void> _evaluateWithAi(List<String> blanks) async {
    isEvaluating.value = true;
    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: blanks.join(' | '),
      );
      aiMeta.value = res;

      // 🔹 XP hesaplama
      final baseXp = question.xp;
      final normalized = (res.score ?? 0) / 5.0;
      final earnedXp = (normalized * baseXp).round();

      final verdict = res.correct ? "✅ Doğru." : "❌ Yanlış.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";

      aiResult.value = "$verdict$explain\n\n⭐ You earned: $earnedXp XP";

      // Firestore güncelle
      await _saveResultToFirestore(res, earnedXp);
    } catch (e, st) {
      print('AI error: $e\n$st');
      final helper = question.aiPromptHelper ?? "";
      final joined = blanks.join(" | ");
      aiResult.value =
      "AI evaluated your fill-in answers.\nYour input: $joined\nHelper: $helper\n\n(Note: fallback response due to AI error)";
    } finally {
      isEvaluating.value = false;
    }
  }

  Future<void> _saveResultToFirestore(AiEvaluateResult res, int earnedXp) async {
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
      print("❌ Firestore save error (fill): $e\n$st");
    }
  }
}
