import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';

/// Çoktan Seçmeli (MCQ) controller
/// - Kullanıcı seçimi
/// - Submit sonrası hem local kontrol (doğru/yanlış renklendirme)
/// - Hem de LLM yorumlaması (aiPromptHelper ile)
class McqController extends GetxController {
  McqController(this.question, {this.shuffleOptions = false});

  final Question question;
  final bool shuffleOptions;

  /// Ekranda gösterilecek (şu anki sıralamasıyla) şıklar
  final options = <String>[].obs;

  /// Kullanıcının seçtiği index (-1 = seçilmedi)
  final selectedIndex = (-1).obs;

  /// Submit sonrası UI state
  final isSubmitted = false.obs;
  final isCorrect = false.obs;

  /// Ekranda göstereceğimiz AI metni
  final aiFeedback = "".obs;

  /// (Yeni) AI ayrıntıları ve yüklenme durumu
  final AiService _ai = Get.find<AiService>();
  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiResult = Rx<AiEvaluateResult?>(null);

  int? _correctIndex;

  @override
  void onInit() {
    super.onInit();

    // Orijinal seçenekleri al (trimleyip)
    final base = (question.options ?? <String>[]).map((e) => e.trim()).toList();
    if (shuffleOptions) base.shuffle();
    options.assignAll(base);

    // Doğru şıkkın indexini bul (Firestore’dan gelen doğru cevap metnine göre)
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

    // ✅ Lokal doğru/yanlış kontrolü (UI renklendirme için)
    final chosen = options[selectedIndex.value];
    final correct = (question.correctAnswer ?? '').trim();
    isCorrect.value =
        chosen.trim().toLowerCase() == correct.trim().toLowerCase();

    isSubmitted.value = true;

    // 🔹 AI yorumlama (açıklama + doğru/yanlış + Firestore güncelleme)
    await _evaluateWithAi(chosen);
  }

  /// UI renklendirme için
  bool isOptionCorrect(int index) {
    if (_correctIndex == null) return false;
    return index == _correctIndex;
  }

  int? get correctIndex => _correctIndex;

  // ------------------- AI + Firestore -------------------

  /// Gerçek AI çağrısı; hata olursa lokal sonucu korur
   Future<void> _evaluateWithAi(String chosen) async {
    isEvaluating.value = true;
    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: chosen,
      );
      aiResult.value = res;

      // 🔹 Kullanıcıya gösterilecek XP hesapla
      final baseXp = question.xp;
      final normalized = (res.score ?? 0) / 5.0;
      final earnedXp = (normalized * baseXp).round();

      // Eğer AI'dan gelen sonuç varsa onu kullan
      final verdict = isCorrect.value ? "✅ Correct." : "❌ Incorrect.";
      final explain =
          (res.explanation.isNotEmpty) ? "\n${res.explanation}" : "";

      // 🔹 Kullanıcıya XP bilgisini de göster
      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $earnedXp XP";

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

    // 🔹 Base XP
    final baseXp = question.xp;
    final rawScore = res.score ?? 0;
    final newScore = (rawScore is int) ? rawScore.toDouble() : rawScore.toDouble();
    final newEarnedXp = ((newScore / 5.0) * baseXp).round();

    print("🔍 [AI] rawScore=$rawScore | newScore=$newScore | baseXp=$baseXp | newEarnedXp=$newEarnedXp");

    if (snap.exists) {
      final data = snap.data() ?? {};
      final prevScore = (data['score'] is int)
          ? (data['score'] as int).toDouble()
          : (data['score'] as num?)?.toDouble() ?? 0.0;
      final prevXp = (data['xpEarned'] as num?)?.toInt() ?? 0;

      print("🔍 [Firestore] prevScore=$prevScore | prevXp=$prevXp");

      // Eğer yeni skor daha yüksekse → fark kadar XP ekle
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
      // İlk çözüm
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
  } catch (e, st) {
    print("❌ Firestore save error: $e\n$st");
  }
}


}
