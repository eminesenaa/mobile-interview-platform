import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';
import '../../runner/controller/question_runner_controller.dart';
import '../../../models/streak.dart';
import '../../../controllers/auth_controller.dart';

/// Çoktan Seçmeli (MCQ) controller
/// - Kullanıcı seçimi
/// - Submit sonrası local kontrol (doğru/yanlış renklendirme)
/// - AI değerlendirmesi + Firestore güncellemesi
/// - Soru çözülünce Streak artışı
class McqController extends GetxController {
  McqController(this.question, {this.shuffleOptions = false});

  final Question question;
  final bool shuffleOptions;

  /// Ekranda gösterilecek şıklar
  final options = <String>[].obs;

  /// Kullanıcının seçtiği index (-1 = seçilmedi)
  final selectedIndex = (-1).obs;

  /// Submit sonrası durum
  final isSubmitted = false.obs;
  final isCorrect = false.obs;

  /// AI feedback
  final aiFeedback = "".obs;

  /// AI servisi
  final AiService _ai = Get.find<AiService>();
  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiResult = Rx<AiEvaluateResult?>(null);

  /// XP
  final earnedXp = 0.obs;
  int? _correctIndex;

  @override
  void onInit() {
    super.onInit();

    // Orijinal seçenekleri yükle
    final base = (question.options ?? <String>[]).map((e) => e.trim()).toList();
    if (shuffleOptions) base.shuffle();
    options.assignAll(base);

    // Doğru cevabı bul
    final ans = (question.correctAnswer ?? '').trim();
    if (ans.isNotEmpty) {
      final idx = options.indexWhere(
        (o) => o.trim().toLowerCase() == ans.toLowerCase(),
      );
      _correctIndex = idx == -1 ? null : idx;
    }
  }

  void select(int index) {
    if (isSubmitted.value) return;
    selectedIndex.value = index;

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(true);
    }
  }

  Future<void> submit() async {
    if (selectedIndex.value == -1) {
      Get.snackbar(
        'No selection',
        'Please select an option.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // ✅ Lokal doğru/yanlış kontrolü
    final chosen = options[selectedIndex.value];
    final correct = (question.correctAnswer ?? '').trim();
    isCorrect.value =
        chosen.trim().toLowerCase() == correct.trim().toLowerCase();

    isSubmitted.value = true;

    // 🔹 AI değerlendirmesi
    await _evaluateWithAi(chosen);
  }

  bool isOptionCorrect(int index) {
    if (_correctIndex == null) return false;
    return index == _correctIndex;
  }

  int? get correctIndex => _correctIndex;

  // ------------------- AI + Firestore -------------------

  Future<void> _evaluateWithAi(String chosen) async {
    isEvaluating.value = true;
    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: chosen,
      );
      aiResult.value = res;

      // 🔹 XP hesapla
      final baseXp = question.xp;
      final normalized = (res.score ?? 0) / 5.0;
      final xp = (normalized * baseXp).round();
      earnedXp.value = xp;

      final verdict = isCorrect.value ? "✅ Correct." : "❌ Incorrect.";
      final explain =
          (res.explanation.isNotEmpty) ? "\n${res.explanation}" : "";

      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      // 🔹 Firestore güncelle
      await _saveResultToFirestore(res);
    } catch (e, st) {
      print("AI error (mcq): $e\n$st");
      final verdict = isCorrect.value ? "✅ Correct." : "❌ Incorrect.";
      final helper = question.aiPromptHelper ??
          "Evaluate the selected answer logically. Explain if it is correct or not.";
      aiFeedback.value = "$verdict\n$helper";
    } finally {
      isEvaluating.value = false;
    }
  }

  Future<void> _saveResultToFirestore(AiEvaluateResult res) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final solvedRef = userRef.collection('solved').doc(question.id);

      final snap = await solvedRef.get();

      final baseXp = question.xp;
      final rawScore = res.score ?? 0;
      final newScore =
          (rawScore is int) ? rawScore.toDouble() : rawScore.toDouble();
      final newEarnedXp = ((newScore / 5.0) * baseXp).round();

      print(
          "🔍 [AI] rawScore=$rawScore | newScore=$newScore | baseXp=$baseXp | newEarnedXp=$newEarnedXp");

      if (snap.exists) {
        final data = snap.data() ?? {};
        final prevScore = (data['score'] is int)
            ? (data['score'] as int).toDouble()
            : (data['score'] as num?)?.toDouble() ?? 0.0;
        final prevXp = (data['xpEarned'] as num?)?.toInt() ?? 0;

        print("🔍 [Firestore] prevScore=$prevScore | prevXp=$prevXp");

        if (newScore > prevScore) {
          final xpDiff = newEarnedXp - prevXp;
          print("🔍 [XP Update] xpDiff=$xpDiff");

          if (xpDiff > 0) {
            await userRef.update({
              'totalXp': FieldValue.increment(xpDiff),
            });
          }

          await solvedRef.update({
            'score': newScore,
            'xpEarned': newEarnedXp,
            'lastAttempt': FieldValue.serverTimestamp(),
          });
        } else {
          print("ℹ️ Yeni skor daha yüksek değil, sadece tarih güncellendi.");
          await solvedRef.update({
            'lastAttempt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // 🔹 İlk çözüm
        print("🔍 [First Solve] earnedXp=$newEarnedXp");

        await userRef.update({
          'totalXp': FieldValue.increment(newEarnedXp),
        });

        await solvedRef.set({
          'status': 'solved',
          'score': newScore,
          'xpEarned': newEarnedXp,
          'solvedAt': FieldValue.serverTimestamp(),
        });
      }

      // 🔥 STREAK GÜNCELLEME 🔥
      try {
        final auth = Get.find<AuthController>();
        final currentUser = auth.user; // ✅ düzeltildi (.value yok)
  final uidToUse =
    currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;


        if (uidToUse != null) {
          await Streak.updateStreak(uidToUse);
          print("🔥 Streak updated successfully for user=$uidToUse");
        } else {
          print("⚠️ Streak update skipped (no uid)");
        }
      } catch (e, st) {
        print("❌ Streak update error: $e\n$st");
      }
    } catch (e, st) {
      print("❌ Firestore save error: $e\n$st");
    }
  }
}
