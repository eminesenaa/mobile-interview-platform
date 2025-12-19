// lib/services/ai/ai_service.dart
import '../../models/exam.dart';
import '../../models/question.dart';
import 'ai_config.dart';
import 'gemini_service.dart';
import 'openai_service.dart';
//import 'gemini_service.dart';

class AiService {
  /// Her tip soru için tek giriş noktası.
  /// MCQ: userAnswer = seçilen index (int) veya text
  /// ShortAnswer/FillBlank: userAnswer = String
  ///
  Future<AiEvaluateResult> evaluate({

    required Question question,
    required dynamic userAnswer,
    //Belki eklenebilir, dışardan almak için: required PromptType promptType

  }) async {

    final meta = _toMeta(question);
    //print(meta);
    final candidate = _candidateFromAnswer(question, userAnswer);
    final category = _mapTopicToCategory(question.topic);

    // burada karar verilecek: training mi interview mu
    var promptType = PromptType.training;

    switch(question.type.name){
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

    /*
    if(question is Behavioral) {
      promptType = PromptType.interview;
    }
    */

    print("Soru türü: ${question.type.name}");
    final provider = AiConfig.chooseModel(questionType: question.type.name);
    print("kullanılacak provider: $provider");
    final result = switch (provider) {

      AiProvider.openai => await OpenAIService.gradeWithTemplate(
        promptType: promptType,
        qMeta: meta,
        candidateAnswer: candidate,
      ),

      AiProvider.gemini => await GeminiService().gradeWithTemplate(
        promptType: promptType,
        category: category,
        qMeta: meta,
        candidateAnswer: candidate,
      ),

      AiProvider.anthropic => throw Exception("Anthropic provider not implemented yet."),
    };


    return AiEvaluateResult(
      finalAnswer: result.expected,
      explanation: result.reason,
      score: result.score,
      correct: result.correct,
    );
  }

  // Exam evaluation

  Future<AiExamEvaluateResult> evaluateExam({
    required Exam exam,
    required Map<String, dynamic> userAnswers,
  }) async {
    // Tüm çağrılar 5’li batch değerlendirmeye yönlensin
    //print(userAnswers);
    return await evaluateExamBatched(exam: exam, userAnswers: userAnswers);
  }

  Future<AiExamEvaluateResult> evaluateExamBatched({
    required Exam exam,
    required Map<String, dynamic> userAnswers,
  }) async {
    final questionEvaluations = <AiExamQuestionEvaluateResult>[];
    int correctCount = 0, falseCount = 0, emptyCount = 0;
    double totalScore = 0.0;

    final idxChunks = _chunkIndices(exam.questions.length, 5);

    for (final chunk in idxChunks) {
      final items = <Map<String, dynamic>>[];
      for (final i in chunk) {
        final q = exam.questions[i];
        final questionKey = q.id;
        final rawAns = userAnswers[questionKey];
        final userAns =
            (rawAns == null || (rawAns is String && rawAns.trim().isEmpty))
                ? ""
                : rawAns;

        items.add({
          "index": i,
          "meta": _toMeta(q),
          "user_answer": _candidateFromAnswer(q, userAns),
          "topic": _mapTopicToCategory(q.topic),
        });
      }

      const provider = AiConfig.provider;

      final results = switch (provider) {
        AiProvider.openai => await OpenAIService.gradeBatch(
          batchId: "exam_${exam.id}_${DateTime.now().millisecondsSinceEpoch}",
          items: items,
        ),
        AiProvider.gemini => await GeminiService().gradeBatch(
          batchId: "exam_${exam.id}_${DateTime.now().millisecondsSinceEpoch}",
          items: items,
        ),
        AiProvider.anthropic => throw Exception("Anthropic provider not implemented yet."),
      };


      for (final r in results) {
        final i = (r['index'] as num).toInt();
        final isCorrect = (r['correct'] as bool?) ?? false;
        final expected = (r['expected'] as String?) ?? '';
        final reason = (r['reason'] as String?) ?? '';
        final score = (r['score'] as num?)?.toDouble() ?? 0.0;
        final q = exam.questions[i];
        final questionKey = q.id;
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
            questionGeneralIndex: exam.questions[i].id,
            questionIndex: i,
            correctness: !answered ? 0 : (isCorrect ? 1 : -1),
            correctAnswer: expected.isEmpty ? [] : [expected],
            explanation: reason,
            score: score,
          ),
        );
      }
    }

    questionEvaluations
        .sort((a, b) => a.questionIndex.compareTo(b.questionIndex));

    final avgScore =
        exam.questions.isNotEmpty ? (totalScore / exam.questions.length) : 0.0;
    final totalScore100 = (avgScore * 20).clamp(0, 100).toInt();

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

    AiExamEvaluateResult result = AiExamEvaluateResult(
      totalScore: totalScore100,
      correctCount: correctCount,
      falseCount: falseCount,
      emptyCount: emptyCount,
      questionEvaluations: questionEvaluations,
      topicPercentage: topicPercentage,
    );
/*
  print(result.totalScore);
  print(result.correctCount);
  print(result.falseCount);
  print(result.emptyCount);
  print(result.questionEvaluations[0].explanation);
  print(result.questionEvaluations[1].explanation);
  print(result.questionEvaluations[2].explanation);
  print(result.questionEvaluations[3].explanation);
  print(result.questionEvaluations[4].explanation);
  print(result.questionEvaluations[5].explanation);
  print(result.questionEvaluations[6].explanation);
  print(result.topicPercentage);
  */

    return result;
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
    // Arkadaşının template’inde beklenen anahtar adları:
    // "Question Text", "Question Format", "Option A"..."Option D", "Correct Option", "Tags", "AI Prompt Helper"
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
    // Doğru şıkkı bilmiyorsak boş geç
    // meta["Correct Option"] = q.correctOptionIndex != null ? String.fromCharCode(65 + q.correctOptionIndex!) : "";

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
      return 'behavioral hr questions';
    }
    if (t.contains('data science')) return 'data science';
    if (t.contains('ml') || t.contains('machine learning')) return 'ml basics';
    if (t.contains('network')) return 'network';
    if (t.contains('java')) return 'java';
    if (t.contains('c/c++') || t.contains('c++') || t == 'c') return 'c/c++';
    if (t.contains('python')) return 'python';
    if (t.contains('sql') || t.contains('database')) return 'sql';
    if (t.contains('git') || t.contains('version control')) return 'git';
    if (t.contains('oop') || t.contains('object oriented')) return 'oop';
    if (t.contains('data structure')) return 'data structure';
    if (t.contains('algorithm')) return 'algorithm';

    // eşleşme yoksa güvenli varsayılan
    return 'algorithm';
  }
}

/// ------------ Templates ------------

//Sonra eklenmesi için enum
enum Correctness {
  correct,
  incorrect,
  partiallyCorrect,
  empty
}

// Alıştırmalar için
class AiEvaluateResult {
  final String finalAnswer;
  final String explanation;
  final double? score; // 0...5
  final bool correct; // arkadaşın servisinden geliyor
  AiEvaluateResult({
    required this.finalAnswer,
    required this.explanation,
    required this.correct,
    this.score,
  });
}

/// Examler için tek soru değerlendirme çıktısı (UI satırı)
class AiExamQuestionEvaluateResult {
  final String questionGeneralIndex; //Q231 şeklinde
  final int questionIndex; // Kaçıncı soru (0-based index)
  final int correctness; // -1: yanlış, 0: boş, 1: doğru
  final List<String>
      correctAnswer; // Doğru Cevap, birden fazla olabilir fill in the blanks için
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

/// Tüm sınavın değerlendirme özeti
class AiExamEvaluateResult {
  final int totalScore; // 100 üzerinden puan
  final int correctCount; // Doğru Sayısı
  final int falseCount; // Yanlış Sayısı
  final int emptyCount; // Boş Sayısı
  final List<AiExamQuestionEvaluateResult>
      questionEvaluations; //Tüm Soruların Sıralanmış Hali
  final Map<String, int> topicPercentage; //Her topic'in doğruluk oranı
  AiExamEvaluateResult(
      {required this.totalScore,
      required this.correctCount,
      required this.falseCount,
      required this.emptyCount,
      required this.questionEvaluations,
      required this.topicPercentage});
}
