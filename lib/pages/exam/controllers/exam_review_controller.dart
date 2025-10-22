import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import '../../../services/ai/ai_service.dart';
import '../widgets/review_ai_explanation_dialog.dart';
import 'exam_controller.dart';

/// 🔹 Review aşamasında soruların durumunu belirtmek için enum
enum ReviewStatus { correct, wrong, unanswered }

class ExamReviewController extends GetxController {
  final Exam exam;
  final currentIndex = 0.obs;

  /// Kullanıcının sınavda verdiği cevaplar
  final Map<String, dynamic> answers = {};

  // Opsiyonel: AI’nın hesapladığı doğru cevapları önceden dolduruyorsan:
  final Map<String, String> _aiCorrectByQid = {};

  // 🔹 AI açıklamalarını cache’leyelim
  // ===== AI Review Caches (qid -> value) =====

  final Map<String, String> _aiExplanationByQid = {};

  final Map<String, List<String>> _aiAcceptedByQid =
      {}; // kabul edilen varyantlar
  final Map<String, bool> _aiIsCorrectByQid =
      {}; // kullanıcının cevabı doğru mu?

  AiService? _ai;

  /// AI tarafından sağlanan açıklamalar
  final Map<String, dynamic> aiFeedback = {};

  /// İstatistik verileri
  int correctCount = 0;
  int wrongCount = 0;
  int unansweredCount = 0;

  ExamReviewController(this.exam) {
    // Eğer aynı exam ID'li aktif bir ExamController varsa, cevapları oradan al
    if (Get.isRegistered<ExamController>(tag: exam.id)) {
      final examController = Get.find<ExamController>(tag: exam.id);
      answers.addAll(examController.answers);
    } else if (exam.answers != null) {
      // Eğer Exam modeline gömülü cevaplar varsa onları da al
      answers.addAll(exam.answers!);
    }

    // AI açıklamaları
    if (exam.aiFeedback != null) {
      aiFeedback.addAll(exam.aiFeedback!);
    }

    // İstatistik verileri
    final stats = exam.stats ?? {};
    correctCount = stats['correct'] ?? 0;
    wrongCount = stats['wrong'] ?? 0;
    unansweredCount = stats['unanswered'] ?? 0;
  }

  /// Şu anda görüntülenen soru
  Question get currentQuestion => exam.questions[currentIndex.value];

  /// Toplam soru sayısı
  int get total => exam.questions.length;

  /// Şu anki soru numarası
  int get currentNumber => currentIndex.value + 1;

  @override
  void onInit() {
    super.onInit();
    // AiService opsiyonel; register edilmediyse null kalır
    try {
      _ai = Get.find<AiService>();
    } catch (_) {}
    _primeAiExplanationsFromExam();
  }

  /// 🔹 Belirli bir index'e git
  void goToQuestion(int index) {
    if (index >= 0 && index < exam.questions.length) {
      currentIndex.value = index;
    }
  }

  /// 🔹 Sonraki soruya geç
  void next() {
    if (currentIndex.value < exam.questions.length - 1) {
      currentIndex.value++;
    }
  }

  /// 🔹 Önceki soruya dön
  void prev() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  /// 🔹 Sorunun durumu (doğru, yanlış, boş)
  ReviewStatus getQuestionStatus(String questionId) {
    final correctIds = (exam.stats?['correctIds'] as List?) ?? [];
    final wrongIds = (exam.stats?['wrongIds'] as List?) ?? [];

    if (correctIds.contains(questionId)) {
      return ReviewStatus.correct;
    } else if (wrongIds.contains(questionId)) {
      return ReviewStatus.wrong;
    } else {
      return ReviewStatus.unanswered;
    }
  }

  /// 🔹 Sorunun cevaplanıp cevaplanmadığını kontrol eder
  bool isAnswered(String questionId) => answers.containsKey(questionId);

  /// 🔹 Sorunun cevabını döndürür (string olarak)
  String getAnswer(String questionId) {
    final value = answers[questionId];
    if (value == null) return '';

    // Eğer Map içinde tutuluyorsa (fillBlank gibi), boş döndürmesin
    if (value is Map && value.isNotEmpty) {
      return value.values.join(', ');
    }
    return value.toString();
  }

  /// 🔹 (İleride) Firestore’a kaydedilecek
  Future<void> saveToLibrary() async {
    Get.snackbar(
      "Saved",
      "Exam added to your library!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ==========================================================
// 🔌 PUBLIC API for AI team (servise dokunmadan entegrasyon)
// ==========================================================

  /// AI backend'den gelen REVIEW JSON'unu tek seferde beslemek için kullanılır.
  /// Arkadaşın serviste veriyi çektikten sonra:
  ///   controller.setAiReviewData(responseJson);
  /// demesi yeterli. UI otomatik güncellenir.
  void setAiReviewData(Map<String, dynamic> reviewJson) {
    final evals = _extractEvaluations(reviewJson);
    if (evals == null) return;
    _hydrateFromEvaluations(evals);
    update(); // GetBuilder/Obx kullanan yerleri tazeler
  }

  /// (Opsiyonel) Geçici/test amaçlı: dışarıdan bir fetcher fonksiyonu alır,
  /// veriyi indirir ve setAiReviewData ile doldurur.
  Future<void> loadAiReviewWith(
    Future<Map<String, dynamic>?> Function(String examId) fetcher,
  ) async {
    final data = await fetcher(exam.id);
    if (data != null) setAiReviewData(data);
  }

  /// (Placeholder) AI dev burada kendi servis çağrısını yazacak ve sonunda
  /// setAiReviewData(...) çağıracak. Şimdilik no-op.
  Future<void> loadAiReview() async {
    // TODO(AI): fetch JSON via your service, then call:
    // final data = await myAiService.fetchExamReview(exam.id);
    // if (data != null) setAiReviewData(data);
  }

// ---- Internal: JSON -> caches ----
  Iterable<dynamic>? _extractEvaluations(dynamic root) {
    if (root == null) return null;
    if (root is Map) {
      final candidates = [
        root['questionEvaluations'],
        root['evaluations'],
        root['mcqEvaluations'],
        root['details'],
      ];
      for (final c in candidates) {
        if (c is Iterable) return c.cast<dynamic>();
      }
      return null;
    }
    // object-like destek
    try {
      final p = (root as dynamic).questionEvaluations;
      if (p is Iterable) return p;
    } catch (_) {}
    try {
      final p = (root as dynamic).evaluations;
      if (p is Iterable) return p;
    } catch (_) {}
    try {
      final p = (root as dynamic).mcqEvaluations;
      if (p is Iterable) return p;
    } catch (_) {}
    try {
      final p = (root as dynamic).details;
      if (p is Iterable) return p;
    } catch (_) {}
    return null;
  }

  void _hydrateFromEvaluations(Iterable evals) {
    for (final e in evals) {
      final qid = _readId(e);
      if (qid == null || qid.isEmpty) continue;

      // correctAnswer
      final corr = _readCorrectAnswer(e);
      if (corr != null && corr.trim().isNotEmpty) {
        _aiCorrectByQid[qid] = corr.trim();
      }

      // accepted variants
      final variants = _readAcceptedAnswers(e);
      if (variants.isNotEmpty) {
        _aiAcceptedByQid[qid] = variants;
      }

      // isCorrect
      final ok = _readIsCorrect(e);
      if (ok != null) {
        _aiIsCorrectByQid[qid] = ok;
      }

      // explanation (seçenekler içinde olabilir; seçili/doğru şıkkı önceliklendir)
      final selected = (answers[qid] ?? '').toString();
      final exp = _pickExplanation(e, selected: selected, correct: corr);
      if (exp != null && exp.trim().isNotEmpty) {
        _aiExplanationByQid[qid] = exp.trim();
      }
    }
  }

// ---- Field readers (Map / object-like) ----
  String? _readId(dynamic e) {
    if (e is Map) return (e['questionId'] ?? e['id'] ?? e['qid'])?.toString();
    try {
      return ((e as dynamic).questionId ?? e.id ?? e.qid)?.toString();
    } catch (_) {}
    return null;
  }

  bool? _readIsCorrect(dynamic e) {
    if (e is Map) {
      final v = e['isCorrect'] ?? e['correct'];
      return v is bool ? v : null;
    }
    try {
      final v = ((e as dynamic).isCorrect ?? e.correct);
      return v is bool ? v : null;
    } catch (_) {}
    return null;
  }

  String? _readCorrectAnswer(dynamic e) {
    if (e is Map) {
      return (e['correctAnswer'] ?? e['answer'] ?? e['modelAnswer'])
          ?.toString();
    }
    try {
      return ((e as dynamic).correctAnswer ?? e.answer ?? e.modelAnswer)
          ?.toString();
    } catch (_) {}
    return null;
  }

  List<String> _readAcceptedAnswers(dynamic e) {
    dynamic v;
    if (e is Map) {
      v = e['acceptedAnswers'] ?? e['variants'];
    } else {
      try {
        v = (e as dynamic).acceptedAnswers ?? e.variants;
      } catch (_) {}
    }
    if (v is Iterable) return v.map((x) => x.toString()).toList();
    return const [];
  }

  String? _pickExplanation(dynamic e, {String? selected, String? correct}) {
    String? exp;
    if (e is Map) {
      exp = (e['explanation'] ??
              e['aiExplanation'] ??
              e['rationale'] ??
              e['feedback'] ??
              e['message'])
          ?.toString();
      if ((exp == null || exp.trim().isEmpty) && e['options'] is Iterable) {
        for (final o in (e['options'] as Iterable)) {
          if (o is! Map) continue;
          final txt = o['text']?.toString();
          final oxp = (o['explanation'] ??
                  o['aiExplanation'] ??
                  o['rationale'] ??
                  o['feedback'])
              ?.toString();
          if (oxp == null || oxp.trim().isEmpty) continue;
          if (correct != null && txt == correct) return oxp;
          if (selected != null && txt == selected) exp ??= oxp;
        }
      }
      return exp;
    }
    try {
      exp = ((e as dynamic).explanation ??
              e.aiExplanation ??
              e.rationale ??
              e.feedback ??
              e.message)
          ?.toString();
    } catch (_) {}
    return exp;
  }

  /// ✅ Review ekranı için doğru cevabı verir.
  /// 1) Question.correctAnswer varsa öncelik o
  /// 2) Yoksa AI’dan gelen kayıttan (senin veri yapına göre) döner
  String? correctAnswerFor(String questionId) {
    // 1) Önce exam içindeki question’dan oku
    try {
      final q = exam.questions.firstWhereOrNull((e) => e.id == questionId);
      if (q?.correctAnswer != null && q!.correctAnswer!.isNotEmpty) {
        return q.correctAnswer;
      }
    } catch (_) {}

    // 2) AI değerlendirme sonuçlarından (senin map’ini kullan)
    if (_aiCorrectByQid.containsKey(questionId)) {
      return _aiCorrectByQid[questionId];
    }

    // TODO: Gerekirse exam.aiResult.questionEvaluations içinden resolve et
    return null;
  }

  // ==========================================================
// ✅ Short Answer Review Helpers
// ==========================================================

  // ----------------------------------------------------------
// Safe accessors for AI review/evaluation blocks on Exam
// ----------------------------------------------------------
  dynamic _getAiResultRoot() {
    // try multiple common field names without crashing
    try {
      final v = (exam as dynamic).aiResult;
      if (v != null) return v;
    } catch (_) {}
    try {
      final v = (exam as dynamic).review;
      if (v != null) return v;
    } catch (_) {}
    try {
      final v = (exam as dynamic).result;
      if (v != null) return v;
    } catch (_) {}
    try {
      final v = (exam as dynamic).evaluation;
      if (v != null) return v;
    } catch (_) {}
    // if nothing is present, return null
    return null;
  }

  Iterable<dynamic>? _pickEvaluations(dynamic root) {
    if (root == null) return null;
    // Map form
    if (root is Map) {
      final paths = [
        root['questionEvaluations'],
        root['evaluations'],
        root['mcqEvaluations'],
        root['details'],
      ];
      for (final p in paths) {
        if (p is Iterable) return p.cast<dynamic>();
      }
      return null;
    }
    // Object-like form
    try {
      final p = (root as dynamic).questionEvaluations;
      if (p is Iterable) return p.cast<dynamic>();
    } catch (_) {}
    try {
      final p = (root as dynamic).evaluations;
      if (p is Iterable) return p.cast<dynamic>();
    } catch (_) {}
    try {
      final p = (root as dynamic).mcqEvaluations;
      if (p is Iterable) return p.cast<dynamic>();
    } catch (_) {}
    try {
      final p = (root as dynamic).details;
      if (p is Iterable) return p.cast<dynamic>();
    } catch (_) {}
    return null;
  }

  /// Returns the list of accepted (alternative) answers for a question.
  /// Looks inside exam.aiResult.questionEvaluations[*].acceptedAnswers or similar.
  List<String> acceptedAnswersFor(String questionId) {
    final root = _getAiResultRoot();
    final evals = _pickEvaluations(root);
    if (evals == null) return const [];
    for (final e in evals) {
      final id = _readId(e);
      if (id == questionId) {
        return _readAcceptedAnswers(e);
      }
    }
    return const [];
  }

  /// Short-Answer
  /// Returns the AI-evaluated review status (Correct/Wrong/Unanswered)
  /// Fallbacks to simple text comparison if AI info missing.
  ReviewStatus reviewStatusFor(String questionId) {
    final userAnswer = (answers[questionId] as String?)?.trim() ?? '';
    if (userAnswer.isEmpty) return ReviewStatus.unanswered;

    // Try to locate evaluation result (safely)
    final root = _getAiResultRoot();
    final evals = _pickEvaluations(root);
    if (evals != null) {
      for (final e in evals) {
        final id = _readId(e);
        if (id == questionId) {
          final ok = _readIsCorrect(e);
          if (ok == true) return ReviewStatus.correct;
          if (ok == false) return ReviewStatus.wrong;
          break;
        }
      }
    }

    // fallback basic comparison
    final model = correctAnswerFor(questionId)?.trim() ?? '';
    // Model/AI yoksa ama kullanıcı cevap vermişse: review ekranında Wrong gösterelim
    if (model.isEmpty) return ReviewStatus.wrong;
    return userAnswer.toLowerCase() == model.toLowerCase()
        ? ReviewStatus.correct
        : ReviewStatus.wrong;
  }

  /// ✅ Exam içindeki AI sonuçlarından explanation’ı çeker.
  /// Beklenen yapı esnek: exam.aiResult.questionEvaluations : List<Map|Obj>
  /// Her elemanda { questionId, explanation (veya aiExplanation/feedback) } olabilir.
  void _primeAiExplanationsFromExam() {
    try {
      final aiResult = (exam as dynamic)?.aiResult;
      if (aiResult == null) {
        Get.log('[review] aiResult null – parse atlandı');
        return;
      }

      // Olası path’leri sırayla dene
      final List<dynamic>? candidates = () {
        final d = aiResult is Map ? aiResult : null;
        final o = aiResult is Map ? null : aiResult;

        final paths = <dynamic>[
          // Map formu
          if (d != null) d['questionEvaluations'],
          if (d != null) d['evaluations'],
          if (d != null) d['mcqEvaluations'],
          if (d != null) d['details'],
          // Object formu
          if (o != null) o.questionEvaluations,
          if (o != null) o.evaluations,
          if (o != null) o.mcqEvaluations,
          if (o != null) o.details,
        ];

        for (final p in paths) {
          if (p is Iterable) return p.cast<dynamic>().toList();
        }
        return null;
      }();

      if (candidates == null) {
        Get.log(
            '[review] eval listesi yok (questionEvaluations/evaluations/mcqEvaluations/details bulunamadı)');
        return;
      }

      int loaded = 0;
      for (final e in candidates) {
        String? qid;
        String? exp;

        if (e is Map) {
          qid = (e['questionId'] ?? e['id'] ?? e['qid'])?.toString();
          exp = (e['explanation'] ??
                  e['aiExplanation'] ??
                  e['rationale'] ??
                  e['feedback'] ??
                  e['explain'] ??
                  e['message'])
              ?.toString();
        } else {
          // Object benzeri
          try {
            qid = (e.questionId ?? e.id ?? e.qid)?.toString();
          } catch (_) {}
          try {
            exp = (e.explanation ??
                    e.aiExplanation ??
                    e.rationale ??
                    e.feedback ??
                    e.explain ??
                    e.message)
                ?.toString();
          } catch (_) {}
        }

        if ((qid ?? '').isNotEmpty && (exp ?? '').trim().isNotEmpty) {
          _aiExplanationByQid[qid!] = exp!.trim();
          loaded++;
        }
      }
      Get.log('[review] explanation cache yüklendi: $loaded kayıt');
      if (loaded == 0) {
        // Hangi anahtarlar var, hızlı debug:
        try {
          Get.log(
              '[review] örnek eval anahtarları: ${candidates.first is Map ? (candidates.first as Map).keys.toList() : candidates.first.runtimeType}');
        } catch (_) {}
      }
    } catch (err) {
      Get.log('[review] _primeAiExplanationsFromExam hata: $err');
    }
  }

  /// ✅ Verilen soru için explanation metnini getir (cache’ten).
  Future<String> _getAiExplanationFor(String questionId) async {
    final text = _aiExplanationByQid[questionId]?.trim()
        // int/string id farklarını yakalamak için fallback:
        ??
        _aiExplanationByQid[tryOtherIdForms(questionId)]?.trim();

    if (text == null || text.isEmpty) {
      return 'No explanation available for this question.';
    }
    return text;
  }

  /// questionId eşleşmelerinde tip farkını telafi et (örn. "10" vs 10)
  String tryOtherIdForms(String qid) {
    // örn: "Q0010" gibi özel prefix’lerin varsa burada normalize edebilirsin
    // basic: baştaki sıfırları at
    final compact = qid.replaceFirst(RegExp(r'^0+'), '');
    return compact.isEmpty ? qid : compact;
  }

  // ==========================================================
// ✅ Fill-in-the-Blank Review Helper
//  - Tek blank için kullanıcı cevabını AI/Model ile kıyaslayıp
//    Correct / Wrong / Unanswered döner.
//  - AI tarafı acceptedVariants/alternatives dönerse onları da dikkate alır.
//  - Çoklu blank desteği gerekiyorsa, bu metodu blankIndex parametresi ile
//    genişletebiliriz (AI şeması netleştiğinde).
// ==========================================================
  ReviewStatus fillBlankStatusFor(String questionId) {
    // final user = (answers[questionId] as String?)?.trim() ?? '';
    final user = userAnswerTextFor(questionId);
    if (user.isEmpty) return ReviewStatus.unanswered;

    // 1) Correct answer (AI cache → exam → null)
    final model = correctAnswerFor(questionId)?.trim();
    // 2) Accepted variants (AI cache → exam → empty)
    final variants = acceptedAnswersFor(questionId);

    bool _eq(String a, String b) => _normalize(a) == _normalize(b);

    // a) accepted variants içinde eşleşme
    for (final v in variants) {
      if (v.trim().isEmpty) continue;
      if (_eq(user, v)) return ReviewStatus.correct;
    }
    // b) model ile eşleşme
    if (model != null && model.isNotEmpty && _eq(user, model)) {
      return ReviewStatus.correct;
    }
    // c) model/variants yok ama kullanıcı yazmış → Wrong (review akışında)
    if ((model == null || model.isEmpty) && variants.isEmpty) {
      return ReviewStatus.wrong;
    }
    // d) aksi halde Wrong
    return ReviewStatus.wrong;
  }

  /// Kullanıcının bu soruya verdiği yanıtı **daima String** olarak döndürür.
  /// answers[qid] şunlardan biri olabilir:
  /// - String -> direkt döner
  /// - Map<String, String> (multi-blank) -> değerleri birleştirir (" " ile)
  /// - List<String> -> birleştirir
  /// - Diğer -> toString (ama önce trim)
  String userAnswerTextFor(String questionId) {
    final ans = answers[questionId];
    if (ans == null) return '';
    if (ans is String) return ans.trim();

    if (ans is Map) {
      // varsa sayısal index'e göre sırala; yoksa mevcut sırayla birleştir
      try {
        final entries = ans.entries
            .map((e) => MapEntry(e.key.toString(), e.value?.toString() ?? ''))
            .toList();
        entries.sort((a, b) {
          final ai = int.tryParse(a.key) ?? 0;
          final bi = int.tryParse(b.key) ?? 0;
          return ai.compareTo(bi);
        });
        return entries
            .map((e) => e.value.trim())
            .where((s) => s.isNotEmpty)
            .join(' ');
      } catch (_) {
        return ans.values
            .map((v) => (v ?? '').toString().trim())
            .where((s) => s.isNotEmpty)
            .join(' ');
      }
    }

    if (ans is List) {
      return ans
          .map((e) => (e ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .join(' ');
    }

    return ans.toString().trim();
  }

  String _normalize(String s) {
    // Temel normalize: trim + lowercase
    // İstersen punctuation/whitespace temizliği ekleyebiliriz.
    return s.trim().toLowerCase();
  }

  /// 🔽 Ortada açılan modal dialog
  void showAiExplanation({required String questionId, String? title}) {
    Get.dialog(
      ReviewAiExplanationDialog(
        explanationFuture: _getAiExplanationFor(questionId),
        // 🔹 Doğru cevabı burada sağlıyoruz (varsa)
        correctAnswerFuture: Future<String?>(() async {
          final v = correctAnswerFor(questionId);
          return (v == null || v.trim().isNotEmpty == false) ? null : v.trim();
        }),

        title: title ?? 'AI Explanation',
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }
}
