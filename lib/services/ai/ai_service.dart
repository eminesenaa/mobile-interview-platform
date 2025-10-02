// lib/services/ai/ai_service.dart
import '../../models/exam.dart';
import '../../models/question.dart';
import 'openai_service.dart';

/// Tek soru değerlendirme çıktısı (UI satırı)
class AiQuestionEvaluateResult {
  final String questionId;
  final bool correct;
  final String expected;
  final String explanation;
  final double? score;
  AiQuestionEvaluateResult({
    required this.questionId,
    required this.correct,
    required this.expected,
    required this.explanation,
    this.score,
  });
}

/// Tüm sınavın değerlendirme özeti
class ExamEvaluateResult {
  final String examId;
  final int total;
  final int correctCount;
  final List<AiQuestionEvaluateResult> items;
  final DateTime createdAt;
  ExamEvaluateResult({
    required this.examId,
    required this.total,
    required this.correctCount,
    required this.items,
    required this.createdAt,
  });
}

class AiService {
  /// Her tip soru için tek giriş noktası.
  /// MCQ: userAnswer = seçilen index (int) veya text
  /// ShortAnswer/FillBlank: userAnswer = String
  ///
  /// NOT: Arkadaşının kullanımını bozmayalım diye `promptType`
  /// parametresini opsiyonel yaptım. Vermezsen `training` kullanır.
  Future<AiEvaluateResult> evaluate({
    required Question question,
    required dynamic userAnswer,
    PromptType? promptType, // nullable -> verilmezse training
  }) async {
    final meta = _toMeta(question);
    final candidate = _candidateFromAnswer(question, userAnswer);
    final category = _mapTopicToCategory(question.topic);

    // burada karar verilecek: training mi interview mu
    final effectivePromptType = promptType ?? PromptType.training;

    final result = await OpenAIService.gradeWithTemplate(
      promptType: effectivePromptType,
      category: category,
      qMeta: meta,
      candidateAnswer: candidate,
    );

    return AiEvaluateResult(
      finalAnswer: result.expected,
      explanation: result.reason,
      score: result.score,
      correct: result.correct,
    );
  }

  /// Tek soru için önerilen çözüm süresini bul (arkadaşının eklediği API)
  Future<int> findQuestionTime(Question question) async {
    final secs = await OpenAIService.findQuestionTime(question);
    return secs;
  }

  /// Tüm sınav için önerilen toplam süreyi bul (5’lik batch ile)
  Future<int> findExamTime(List<Question> questions) async {
    int totalSecs = 0;

    for (int i = 0; i < questions.length; i += 5) {
      final chunk = questions.sublist(
        i,
        (i + 5 > questions.length) ? questions.length : i + 5,
      );

      final secsList = await OpenAIService.findQuestionsTimeBatch(chunk);
      totalSecs += secsList.fold(0, (a, b) => a + b);
    }

    return totalSecs;
  }

  /// TÜM SINAVI 5'lik paketler halinde değerlendirir (batch)
  Future<ExamEvaluateResult> evaluateExam({
    required Exam exam,

    /// questionId -> userAnswer (int index veya String)
    required Map<String, dynamic> userAnswers,
    PromptType promptType = PromptType.training,
  }) async {
    final items = <AiQuestionEvaluateResult>[];
    final qs = exam.questions;
    const batchSize = 5;

    for (int start = 0; start < qs.length; start += batchSize) {
      final end =
          (start + batchSize > qs.length) ? qs.length : start + batchSize;
      final batch = qs.sublist(start, end);

      final batchPayload = <Map<String, String>>[];
      final batchCandidates = <String>[];

      for (final q in batch) {
        final meta = _toMeta(q);
        meta["Category"] = _mapTopicToCategory(q.topic);
        meta["Question Id"] = q.id;

        final ans = userAnswers[q.id];
        final cand = _candidateFromAnswer(q, ans);

        batchPayload.add(meta);
        batchCandidates.add(cand);
      }

      final results = await OpenAIService.gradeBatchWithTemplate(
        qMetas: batchPayload,
        candidateAnswers: batchCandidates,
        promptType: promptType,
      );

      for (final r in results) {
        items.add(AiQuestionEvaluateResult(
          questionId: r.questionId,
          correct: r.correct,
          expected: r.expected,
          explanation: r.reason,
          score: r.score,
        ));
      }
    }

    final totalCorrect = items.where((e) => e.correct).length;
    return ExamEvaluateResult(
      examId: exam.id,
      total: qs.length,
      correctCount: totalCorrect,
      items: items,
      createdAt: DateTime.now(),
    );
  }

  // ---------- helpers ----------
  /// Şablonlarda beklenen alanlar:
  /// "Question Text", "Question Format", "Option A"..."Option D",
  /// "Correct Option", "Tags", "AI Prompt Helper"
  Map<String, String> _toMeta(Question q) {
    final meta = <String, String>{
      "Question Text": q.title,
      "Question Format": (q.type?.name ?? '').toUpperCase(),
      "Tags": (q.tags?.join(', ') ?? ''),
      "AI Prompt Helper": q.description ?? '',
    };

    // MCQ seçenekleri
    final opts = q.options ?? const [];
    if (opts.isNotEmpty) {
      if (opts.length > 0) meta["Option A"] = opts[0];
      if (opts.length > 1) meta["Option B"] = opts[1];
      if (opts.length > 2) meta["Option C"] = opts[2];
      if (opts.length > 3) meta["Option D"] = opts[3];
    }
    // Doğru şık kullanıcıya gösterilmiyorsa boş bırakılabilir
    // meta["Correct Option"] = q.correctOptionIndex != null
    //     ? String.fromCharCode(65 + q.correctOptionIndex!)
    //     : "";

    return meta;
  }

  String _candidateFromAnswer(Question q, dynamic ans) {
    // MCQ'da index geldiyse A/B/C/D'ye çevir
    if (ans is int && (q.options?.isNotEmpty ?? false)) {
      final idx = ans.clamp(0, q.options!.length - 1);
      final letter = String.fromCharCode(65 + idx); // 65='A'
      return '$letter'; // "A" | "B" | ...
    }
    return ans?.toString() ?? '';
  }

  String _mapTopicToCategory(String? topic) {
    // Geniş kapsamlı eşleme (senin versiyon + arkadaşının versiyonu)
    final t = (topic ?? '').toLowerCase();
    if (t.contains('algorithm')) return 'algorithm';
    if (t.contains('data')) return 'data structure';
    if (t.contains('git')) return 'git';
    if (t.contains('oop')) return 'oop';
    if (t.contains('sql')) return 'sql';
    if (t.contains('network')) return 'network';
    if (t.contains('python')) return 'python';
    if (t.contains('java')) return 'java';
    if (t.contains('c++') || t.contains('c/c++') || t.contains('c '))
      return 'c/c++';
    if (t.contains('ml')) return 'ml basics';
    if (t.contains('data science')) return 'data science';
    return 'algorithm';
  }
}

class AiEvaluateResult {
  final String finalAnswer;
  final String explanation;
  final double? score;   // 0...5
  final bool correct;    // servis kararından gelir
  AiEvaluateResult({
    required this.finalAnswer,
    required this.explanation,
    required this.correct,
    this.score,
  });
}

