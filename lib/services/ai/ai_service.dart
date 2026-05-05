// lib/services/ai/ai_service.dart
import 'dart:async';
import 'dart:collection';

import '../../models/exam.dart';
import '../../models/interview.dart';
import '../../models/question.dart';
import '../../models/ai_interview_question_result.dart';
import '../../models/ai_interview_result.dart';
import 'ai_config.dart';
import 'gemini_service.dart';
import 'openai_service.dart';
import 'anthropic_service.dart';
import 'llama_service.dart';

class AiService {
  /// Her tip soru için tek giriş noktası.
  /// MCQ: userAnswer = seçilen index (int) veya text
  /// ShortAnswer/FillBlank: userAnswer = String
  ///
  Future<AiEvaluateResult> evaluate({
    required Question question,
    required dynamic userAnswer,
  }) async {
    final meta = _toMeta(question);

    // ✅ boş cevaplar da LLM'e gitsin (sentinel ile)
    final dynamic safeUserAnswer = (userAnswer == null ||
            (userAnswer is String && userAnswer.trim().isEmpty))
        ? "noAnswerProvided"
        : userAnswer;

    final candidate = _candidateFromAnswer(question, safeUserAnswer);
    final category = _mapTopicToCategory(question.topic);

    // burada karar verilecek: training mi interview mu
    var promptType = PromptType.training;

    switch (question.type.name) {
      case 'mcq':
        promptType = PromptType.mcq;
        break;
      case 'shortAnswer':
        promptType = PromptType.shortAnswer;
        break;
      case 'coding':
        promptType = PromptType.codeWriting;
        break;
      case 'fillBlank':
        promptType = PromptType.fillBlanks;
        break;
    }

    print("Soru türü: ${question.type.name}");
    final provider = AiConfig.chooseModel(questionType: question.type.name);
    print("kullanılacak provider: $provider");

    final result = await switch (provider) {
      AiProvider.openai => OpenAIService.gradeWithTemplate(
        promptType: promptType,
        qMeta: meta,
        candidateAnswer: candidate,
      ),
      AiProvider.gemini => GeminiService().gradeWithTemplate(
        promptType: promptType,
        qMeta: meta,
        candidateAnswer: candidate,
      ),
      AiProvider.anthropic => AnthropicService().gradeWithTemplate(
        promptType: promptType,
        qMeta: meta,
        candidateAnswer: candidate,
      ),
      AiProvider.llama => LlamaService().gradeWithTemplate(
        promptType: promptType,
        qMeta: meta,
        candidateAnswer: candidate,
      ),
    };

    return AiEvaluateResult(
      finalAnswer: result.expected,
      explanation:
          "${result.correct ? "Correct" : "Incorrect"}. ${result.reason}",
      score: result.score,
      correct: result.correct,
    );
  }

  // Exam evaluation
  Future<AiExamEvaluateResult> evaluateExam({
    required Exam exam,
    required Map<String, dynamic> userAnswers,
  }) async {
    // Tüm çağrılar 5'li batch değerlendirmeye yönlensin
    return await evaluateExamBatched(exam: exam, userAnswers: userAnswers);
  }

  // ===============================================================
  // 🔥 INTERVIEW EVALUATION (Two-Stage Pipeline)
  // ===============================================================
  //
  // Stage 1: Evaluate each question individually
  //   - Loads InterviewQuestionEvaluation.yml
  //   - Strips irrelevant rubric sections per question type
  //   - Returns rich JSON per question (subscores, STAR, coaching, etc.)
  //
  // Stage 2: Final hiring decision
  //   - Sends all Stage 1 JSON outputs to InterviewFinalDecision.yml
  //   - Returns executive summary, role recommendation, global patterns
  // ===============================================================

  Future<AiInterviewResult> evaluateInterview({
    required Interview interview,
    required Map<String, dynamic> userAnswers,
  }) async {
    final totalSw = Stopwatch()..start();

    // ═══════════════════════════════════════
    // STAGE 1: Per-Question Evaluation
    // ═══════════════════════════════════════
    final questionResults = <AiInterviewQuestionResult>[];
    final rawJsonResults = <Map<String, dynamic>>[];

    // Use _AsyncPool to limit concurrency (avoid rate limits)
    final pool = _AsyncPool(3);
    final futures = <Future<void>>[];

    for (int i = 0; i < interview.questions.length; i++) {
      final q = interview.questions[i];
      final questionKey = q.id;
      final rawAns = userAnswers[questionKey];

      final safeAns =
          (rawAns == null || (rawAns is String && rawAns.trim().isEmpty))
              ? "noAnswerProvided"
              : rawAns;

      final int capturedIndex = i;

      futures.add(pool.withResource(() async {
        try {
          final meta = _toMeta(q);
          final candidate = _candidateFromAnswer(q, safeAns);
          final category = _mapTopicToCategory(q.topic);
          final provider =
              AiConfig.chooseModel(questionType: q.type.name);

          print(
            "📝 [INTERVIEW Q$capturedIndex] type=${q.type.name} "
            "topic=${q.topic} provider=$provider",
          );

          final resultJson = await switch (provider) {
            AiProvider.openai => OpenAIService.gradeInterviewQuestion(
              qMeta: meta,
              candidateAnswer: candidate,
              category: category,
              questionTypeName: q.type.name,
            ),
            AiProvider.gemini => GeminiService().gradeInterviewQuestion(
              qMeta: meta,
              candidateAnswer: candidate,
              category: category,
              questionTypeName: q.type.name,
            ),
            AiProvider.anthropic =>
                AnthropicService().gradeInterviewQuestion(
              qMeta: meta,
              candidateAnswer: candidate,
              category: category,
              questionTypeName: q.type.name,
            ),
            AiProvider.llama => LlamaService().gradeInterviewQuestion(
              qMeta: meta,
              candidateAnswer: candidate,
              category: category,
              questionTypeName: q.type.name,
            ),
          };

          final parsed = AiInterviewQuestionResult.fromJson(
            resultJson,
            questionKey,
            capturedIndex,
          );

          questionResults.add(parsed);
          rawJsonResults.add(resultJson);

          print(
            "✅ [INTERVIEW Q$capturedIndex] "
            "score=${parsed.overallScore} decision=${parsed.decision}",
          );
        } catch (e, st) {
          print("❌ [INTERVIEW Q$capturedIndex] error=$e");
          print(st);

          // Add a fallback result so we don't lose the question
          questionResults.add(AiInterviewQuestionResult(
            questionId: questionKey,
            questionIndex: capturedIndex,
            overallScore: 0.0,
            decision: 'reject',
            weaknesses: ['AI evaluation failed for this question.'],
          ));
          rawJsonResults.add({
            'overall_score': 0.0,
            'decision': 'reject',
            'error': e.toString(),
          });
        }
      }));
    }

    await Future.wait(futures);

    // Sort by question index
    questionResults
        .sort((a, b) => a.questionIndex.compareTo(b.questionIndex));
    // rawJsonResults doesn't need sorting — Stage 2 doesn't care about order

    print(
      "📊 [INTERVIEW STAGE 1 DONE] "
      "questions=${interview.questions.length} "
      "results=${questionResults.length}",
    );

    // ═══════════════════════════════════════
    // STAGE 2: Final Decision
    // ═══════════════════════════════════════
    Map<String, dynamic> finalJson;

    try {
      final provider = AiConfig.provider;

      finalJson = await switch (provider) {
        AiProvider.openai => OpenAIService.gradeInterviewFinal(
          evaluationsJson: rawJsonResults,
        ),
        AiProvider.gemini => GeminiService().gradeInterviewFinal(
          evaluationsJson: rawJsonResults,
        ),
        AiProvider.anthropic => AnthropicService().gradeInterviewFinal(
          evaluationsJson: rawJsonResults,
        ),
        AiProvider.llama => LlamaService().gradeInterviewFinal(
          evaluationsJson: rawJsonResults,
        ),
      };

      print(
        "✅ [INTERVIEW STAGE 2 DONE] "
        "decision=${finalJson['final_decision']} "
        "score=${finalJson['overall_interview_score']}",
      );
    } catch (e, st) {
      print("❌ [INTERVIEW STAGE 2 FAILED] error=$e");
      print(st);

      // Fallback: compute basic aggregation without AI
      final avgScore = questionResults.isEmpty
          ? 0.0
          : questionResults.map((q) => q.overallScore).reduce((a, b) => a + b) /
              questionResults.length;

      finalJson = {
        'final_decision': avgScore >= 3.5 ? 'advance' : 'reject',
        'overall_interview_score': avgScore,
        'executive_summary': 'Stage 2 AI evaluation failed. Scores aggregated manually.',
        'global_strengths': <String>[],
        'global_weaknesses': <String>[],
        'critical_red_flags': <String>[],
        'technical_competence_summary': '',
        'behavioral_and_soft_skills_summary': '',
        'recommended_role_level': 'none',
        'areas_for_probing_in_next_round': <String>[],
      };
    }

    totalSw.stop();
    print(
      "🏁 [INTERVIEW EVAL COMPLETE] "
      "questions=${interview.questions.length} "
      "totalTime=${totalSw.elapsedMilliseconds}ms",
    );

    return AiInterviewResult.fromStages(questionResults, finalJson);
  }


  /// ✅ Paralel chunk değerlendirme (controller/firebase değişmeden)
  Future<AiExamEvaluateResult> evaluateExamBatched({
    required Exam exam,
    required Map<String, dynamic> userAnswers,
  }) async {
    // ✅ TOPLAM süre ölçümü (sadece exam evaluation için)
    final totalSw = Stopwatch()..start();

    final questionEvaluations = <AiExamQuestionEvaluateResult>[];
    int correctCount = 0, falseCount = 0, emptyCount = 0;
    double totalScore = 0.0;

    // ✅ 5'li chunk’lara böl
    final idxChunks = _chunkIndices(exam.questions.length, 5);
    print(
      "🧩 [EXAM] totalQuestions=${exam.questions.length} "
      "chunks=${idxChunks.length} chunkSize=5",
    );

    // ✅ Aynı anda kaç chunk paralel gitsin?
    // Çok yükseltirsen rate-limit riski artar.
    final int maxConcurrentChunks = 3;

    final pool = _AsyncPool(maxConcurrentChunks);

    // Her chunk için paralel görev oluştur
    final futures = <Future<_ChunkRunResult>>[];
    for (int chunkNo = 0; chunkNo < idxChunks.length; chunkNo++) {
      final chunk = idxChunks[chunkNo];

      futures.add(
        pool.withResource(() async {
          return await _runExamChunk(
            chunkNo: chunkNo,
            chunk: chunk,
            exam: exam,
            userAnswers: userAnswers,
          );
        }),
      );
    }

    // Tüm chunklar bitince topla
    final chunkResults = await Future.wait(futures);

    // Logları daha düzgün görmek için chunkNo sırasına dizelim
    chunkResults.sort((a, b) => a.chunkNo.compareTo(b.chunkNo));

    for (final cr in chunkResults) {
      // chunk log
      print(
        "⏱️ [EXAM CHUNK] chunk=${cr.chunkNo} size=${cr.chunkSize} "
        "provider=${cr.provider} api=${cr.apiMs}ms totalChunk=${cr.totalChunkMs}ms",
      );

      // sonuçları topla
      for (final r in cr.results) {
        final i = (r['index'] as num).toInt();
        final isCorrect = (r['correct'] as bool?) ?? false;
        final expected = (r['expected'] as String?) ?? '';
        final reason = (r['reason'] as String?) ?? '';
        final score = (r['score'] as num?)?.toDouble() ?? 0.0;

        final q = exam.questions[i];
        final questionKey = q.id;

        // ✅ doğru sayım mantığı değişmesin: gerçekten boş mu kontrolü
        final answered =
            userAnswers[questionKey]?.toString().trim().isNotEmpty ?? false;

        if (!answered) {
          emptyCount++;
        } else if (isCorrect) {
          correctCount++;
        } else {
          falseCount++;
        }

        totalScore += score;

        questionEvaluations.add(
          AiExamQuestionEvaluateResult(
            questionGeneralIndex: q.id,
            questionIndex: i,
            correctness: !answered ? 0 : (isCorrect ? 1 : -1),
            correctAnswer: expected.isEmpty ? [] : [expected],
            explanation: reason,
            score: score,
          ),
        );
      }
    }

    // Soru sırasına göre düzelt
    questionEvaluations
        .sort((a, b) => a.questionIndex.compareTo(b.questionIndex));

    // Final Score
    final avgScore =
        exam.questions.isNotEmpty ? (totalScore / exam.questions.length) : 0.0;
    final totalScore100 = (avgScore * 20).clamp(0, 100).toInt();

    // Topic Percentages
    final topicMap = <String, List<bool>>{};
    for (final qe in questionEvaluations) {
      final t =
          (exam.questions[qe.questionIndex].topic ?? 'Unknown').toLowerCase();
      final ok = qe.correctness == 1;
      topicMap.putIfAbsent(t, () => []).add(ok);
    }
    final topicPercentage = <String, int>{};
    topicMap.forEach((t, list) {
      final p = (list.where((e) => e).length / list.length * 100).round();
      topicPercentage[t] = p;
    });

    final result = AiExamEvaluateResult(
      totalScore: totalScore100,
      correctCount: correctCount,
      falseCount: falseCount,
      emptyCount: emptyCount,
      questionEvaluations: questionEvaluations,
      topicPercentage: topicPercentage,
    );

    totalSw.stop();
    print(
      "✅ [EXAM DONE] totalQuestions=${exam.questions.length} "
      "correct=$correctCount wrong=$falseCount empty=$emptyCount "
      "totalScore=$totalScore100/100 totalTime=${totalSw.elapsedMilliseconds}ms",
    );

    return result;
  }

  /// Tek bir chunk'ı çalıştırır (paralelde çağrılır).
  ///
  /// ✅ TOKEN verimliliği için: chunk içinde hangi tiplerin olduğunu çıkarır
  /// ve OpenAIService.gradeBatch'e hasMCQ/hasFillBlanks/... flag'lerini geçirir.
  Future<_ChunkRunResult> _runExamChunk({
    required int chunkNo,
    required List<int> chunk,
    required Exam exam,
    required Map<String, dynamic> userAnswers,
  }) async {
    final chunkSw = Stopwatch()..start();

    var chunkHasMcq = false;
    var chunkHasFillBlanks = false;
    var chunkHasShortAnswer = false;
    var chunkHasCodeWriting = false;
    var chunkHasBehavioral = false;

    final items = <Map<String, dynamic>>[];

    for (final i in chunk) {
      final q = exam.questions[i];

      // ✅ chunk tiplerini topla -> prompt'u kısaltmak için
      switch (q.type) {
        case QuestionType.mcq:
          chunkHasMcq = true;
          break;
        case QuestionType.shortAnswer:
          chunkHasShortAnswer = true;
          break;
        case QuestionType.coding:
          chunkHasCodeWriting = true;
          break;
        case QuestionType.fillBlank:
          chunkHasFillBlanks = true;
          break;
        case QuestionType.debugging:
          chunkHasCodeWriting = true;
          break;
      }

      final questionKey = q.id;
      final rawAns = userAnswers[questionKey];

      // ✅ boş cevaplar da LLM'e gitsin (sentinel ile)
      final userAns =
          (rawAns == null || (rawAns is String && rawAns.trim().isEmpty))
              ? "noAnswerProvided"
              : rawAns;

      items.add({
        "index": i,
        "meta": _toMeta(q),
        "user_answer": _candidateFromAnswer(q, userAns),
        "topic": _mapTopicToCategory(q.topic),
      });
    }

    const provider = AiConfig.provider;

    // ✅ provider çağrısı süre ölçümü
    final callSw = Stopwatch()..start();
    final batchId =
        "exam_${exam.id}_${DateTime.now().millisecondsSinceEpoch}_$chunkNo";

    List<Map<String, dynamic>> results;

    // ✅ jsonDecode/prompt bozulursa app çökmesin
    try {

      results = await switch (provider) {
        AiProvider.openai => OpenAIService.gradeBatch(
          batchId: batchId,
          items: items,
          hasMCQ: chunkHasMcq,
          hasFillBlanks: chunkHasFillBlanks,
          hasShortAnswer: chunkHasShortAnswer,
          hasCodeWriting: chunkHasCodeWriting,
          hasBehavioral: chunkHasBehavioral,
        ),
        AiProvider.gemini => GeminiService().gradeBatch(
          batchId: batchId,
          items: items,
          hasMCQ: chunkHasMcq,
          hasFillBlanks: chunkHasFillBlanks,
          hasShortAnswer: chunkHasShortAnswer,
          hasCodeWriting: chunkHasCodeWriting,
          hasBehavioral: chunkHasBehavioral,
        ),
        AiProvider.anthropic => AnthropicService().gradeBatch(
          batchId: batchId,
          items: items,
          hasMCQ: chunkHasMcq,
          hasFillBlanks: chunkHasFillBlanks,
          hasShortAnswer: chunkHasShortAnswer,
          hasCodeWriting: chunkHasCodeWriting,
          hasBehavioral: chunkHasBehavioral,
        ),
        AiProvider.llama => LlamaService().gradeBatch(
          batchId: batchId,
          items: items,
          hasMCQ: chunkHasMcq,
          hasFillBlanks: chunkHasFillBlanks,
          hasShortAnswer: chunkHasShortAnswer,
          hasCodeWriting: chunkHasCodeWriting,
          hasBehavioral: chunkHasBehavioral,
        ),
      };

    } catch (e, st) {
      print("! EXAM chunk failed chunk=$chunkNo error=$e");
      print(st);
      results = <Map<String, dynamic>>[];
    }

    callSw.stop();
    chunkSw.stop();

    return _ChunkRunResult(
      chunkNo: chunkNo,
      chunkSize: chunk.length,
      provider: provider,
      apiMs: callSw.elapsedMilliseconds,
      totalChunkMs: chunkSw.elapsedMilliseconds,
      results: results,
    );
  }

  List<List<int>> _chunkIndices(int len, int size) {
    final chunks = <List<int>>[];
    for (int i = 0; i < len; i += size) {
      final end = (i + size < len) ? i + size : len;
      chunks.add(List.generate(end - i, (k) => i + k));
    }
    return chunks;
  }

  // ---------- helpers ----------

  Map<String, String> _toMeta(Question q) {
    final meta = <String, String>{
      "Question Text": q.description ?? '',
      "Question Format": (q.type?.name ?? '').toUpperCase(),
      "Tags": (q.tags?.join(', ') ?? ''),
      "AI Prompt Helper": q.aiPromptHelper ?? '',
    };

    // MCQ opsiyonlarını yerleştir (varsa)
    final opts = q.options ?? const [];
    if (opts.isNotEmpty) {
      if (opts.length > 0) meta["Option A"] = opts[0];
      if (opts.length > 1) meta["Option B"] = opts[1];
      if (opts.length > 2) meta["Option C"] = opts[2];
      if (opts.length > 3) meta["Option D"] = opts[3];
    }

    return meta;
  }

  String _candidateFromAnswer(Question q, dynamic ans) {
    // MCQ'da index geldiyse A/B/C/D'ye çevir
    if (ans is int && (q.options?.isNotEmpty ?? false)) {
      final idx = ans.clamp(0, q.options!.length - 1);
      final letter = String.fromCharCode(65 + idx); // 65='A'
      return letter; // "A" | "B" | ...
    }
    return ans?.toString() ?? '';
  }

  String _mapTopicToCategory(String? topic) {
    final t = (topic ?? '').toLowerCase().trim();
    if (t.isEmpty) return 'algorithm';

    if (t.contains('behavior') || t.contains('hr') || t.contains('star')) {
      return 'Behavioral hr questions';
    }
    if (t.contains('data science')) return 'Data science';
    if (t.contains('ml') || t.contains('machine learning')) return 'Ml basics';
    if (t.contains('network')) return 'Network';
    if (t.contains('java')) return 'Java';
    if (t.contains('c/c++') || t.contains('c++') || t == 'c') return 'C/C++';
    if (t.contains('python')) return 'Python';
    if (t.contains('sql') || t.contains('database')) return 'Sql';
    if (t.contains('git') || t.contains('version control')) return 'Git';
    if (t.contains('oop') || t.contains('object oriented')) return 'Oop';
    if (t.contains('data structure')) return 'Data Structures';
    if (t.contains('algorithm')) return 'Algorithms';

    // eşleşme yoksa güvenli varsayılan
    return 'Algorithms';
  }
}

/// ------------ Parallel helpers ------------

/// Basit concurrency limiter (extra package yok)
class _AsyncPool {
  _AsyncPool(this._max) : _available = _max;

  final int _max;
  int _available;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  Future<T> withResource<T>(Future<T> Function() action) async {
    await _acquire();
    try {
      return await action();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() async {
    if (_available > 0) {
      _available--;
      return;
    }
    final c = Completer<void>();
    _waiters.addLast(c);
    await c.future;
  }

  void _release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
      return;
    }
    _available++;
    if (_available > _max) _available = _max;
  }
}

class _ChunkRunResult {
  final int chunkNo;
  final int chunkSize;
  final AiProvider provider;
  final int apiMs;
  final int totalChunkMs;
  final List<Map<String, dynamic>> results;

  _ChunkRunResult({
    required this.chunkNo,
    required this.chunkSize,
    required this.provider,
    required this.apiMs,
    required this.totalChunkMs,
    required this.results,
  });
}

/// ------------ Templates ------------

// Alıştırmalar için
class AiEvaluateResult {
  final String finalAnswer; // Perfect Answer
  final String explanation; // Açıklama
  final double? score; // 0...5
  final bool correct; // Doğru mu?
  AiEvaluateResult({
    required this.finalAnswer,
    required this.explanation,
    required this.correct,
    this.score,
  });
}

// Examler için tek soru değerlendirme çıktısı (UI satırı)
class AiExamQuestionEvaluateResult {
  final String questionGeneralIndex; // Q231 şeklinde
  final int questionIndex; // Kaçıncı soru (0-based index)
  final int correctness; // -1: yanlış, 0: boş, 1: doğru
  final List<String>
      correctAnswer; // Doğru Cevap (fill blanks birden fazla olabilir)
  final String explanation; // Ai açıklama
  final double? score; // 0-5 arası
  AiExamQuestionEvaluateResult({
    required this.questionGeneralIndex,
    required this.questionIndex,
    required this.correctness,
    required this.correctAnswer,
    required this.explanation,
    this.score,
  });
}

// Tüm sınavın değerlendirme özeti
class AiExamEvaluateResult {
  final int totalScore; // 100 üzerinden puan
  final int correctCount; // Doğru Sayısı
  final int falseCount; // Yanlış Sayısı
  final int emptyCount; // Boş Sayısı
  final List<AiExamQuestionEvaluateResult>
      questionEvaluations; //Tüm Soruların Sıralanmış Hali
  final Map<String, int> topicPercentage; //Her topic'in doğruluk oranı
  AiExamEvaluateResult({
    required this.totalScore,
    required this.correctCount,
    required this.falseCount,
    required this.emptyCount,
    required this.questionEvaluations,
    required this.topicPercentage,
  });
}
