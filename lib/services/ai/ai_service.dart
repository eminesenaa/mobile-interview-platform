// lib/services/ai/ai_service.dart
import '../../models/exam.dart';
import '../../models/question.dart';
import 'openai_service.dart';

class AiService {
  /// Her tip soru için tek giriş noktası.
  /// MCQ: userAnswer = seçilen index (int) veya text
  /// ShortAnswer/FillBlank: userAnswer = String
  Future<AiEvaluateResult> evaluate({
    required Question question,
    required dynamic userAnswer,
    //Belki eklenebilir, dışardan almak için: required PromptType promptType
  }) async {
    final meta = _toMeta(question);
    final candidate = _candidateFromAnswer(question, userAnswer);
    final category = _mapTopicToCategory(question.topic);

    // burada karar verilecek: training mi interview mu
    const promptType = PromptType.training;

    final result = await OpenAIService.gradeWithTemplate(
      promptType: promptType,
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

  // Exam evaluation

  Future<AiExamEvaluateResult> evaluateExam({
    required Exam exam,
    required Map<int, dynamic> userAnswers,
  }) async {
    final questionEvaluations = <AiExamQuestionEvaluateResult>[];
    int correctCount = 0;
    int falseCount = 0;
    int emptyCount = 0;
    double totalScore = 0.0;

    // Tüm sınav sorularını evaluate'le
    for (int i = 0; i < exam.questions.length; i++) {

      final q = exam.questions[i];
      final rawAns = userAnswers[i];

      // Kullanıcı cevabı boşsa bile string olarak gönder (AI doğru cevabı döndürsün)
      final userAns = (rawAns == null || (rawAns is String && rawAns.trim().isEmpty))
          ? ""
          : rawAns;

      try {
        // AI değerlendirmesi
        final eval = await evaluate(question: q, userAnswer: userAns);

        // Cevap boşsa "emptyCount" artar ama değerlendirme yapılır
        if (userAns.toString().isEmpty) {
          emptyCount++;
        } else if (eval.correct) {
          correctCount++;
        } else {
          falseCount++;
        }

        //Şimdilik puanlama double
        totalScore += (eval.score ?? 0);

        questionEvaluations.add(
          AiExamQuestionEvaluateResult(
            questionIndex: i,
            correctness: userAns.toString().isEmpty
                ? 0
                : (eval.correct ? 1 : -1),
            correctAnswer: [eval.finalAnswer],
            explanation: eval.explanation,
            score: eval.score,
          ),
        );
      } catch (e) {
        // AI hatasında fallback
        questionEvaluations.add(
          AiExamQuestionEvaluateResult(
            questionIndex: i,
            correctness: 0,
            correctAnswer: const [],
            explanation: "AI evaluation failed: $e",
            score: 0,
          ),
        );
        falseCount++;
      }
    }

    // Ortalama puanı 100 üzerinden hesapla (AI score 0–5 arası olduğu için ×20)
    final avgScore = exam.questions.isNotEmpty
        ? (totalScore / exam.questions.length)
        : 0;
    final totalScore100 = (avgScore * 20).clamp(0, 100).toInt();

    // Konu bazlı başarı yüzdelerini hesapla
    final topicMap = <String, List<bool>>{};
    for (int i = 0; i < exam.questions.length; i++) {
      final topic = (exam.questions[i].topic ?? 'Unknown').toLowerCase();
      final correct = questionEvaluations[i].correct;
      topicMap.putIfAbsent(topic, () => []);
      topicMap[topic]!.add(correct);
    }

    final topicPercentage = <String, int>{};
    topicMap.forEach((topic, results) {
      final percent = (results.where((c) => c).length / results.length * 100)
          .round();
      topicPercentage[topic] = percent;
    });

    return AiExamEvaluateResult(
      totalScore: totalScore100,
      correctCount: correctCount,
      falseCount: falseCount,
      emptyCount: emptyCount,
      questionEvaluations: questionEvaluations,
      topicPercentage: topicPercentage,
    );
  }


  // ---------- helpers ----------

  Map<String, String> _toMeta(Question q) {
    // Arkadaşının template’inde beklenen anahtar adları:
    // "Question Text", "Question Format", "Option A"..."Option D", "Correct Option", "Tags", "AI Prompt Helper"
    final meta = <String, String>{
      "Question Text": q.title,
      "Question Format": (q.type?.name ?? '').toUpperCase(),
      "Tags": (q.tags?.join(', ') ?? ''),
      "AI Prompt Helper": q.description ?? '',
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
      return '$letter'; // "A" | "B" | ...
    }
    return ans?.toString() ?? '';
  }

  String _mapTopicToCategory(String? topic) {
    // Arkadaşının OpenAIService._buildSystemRole ile eşleşecek şekilde
    final t = (topic ?? '').toLowerCase();
    if (t.contains('algorithm')) return 'algorithm';
    if (t.contains('data')) return 'data structure';
    if (t.contains('git')) return 'git';
    if (t.contains('oop')) return 'oop';
    return 'algorithm';
  }
}

/// ------------ Templates ------------

// Alıştırmalar için
class AiEvaluateResult {
  final String finalAnswer;
  final String explanation;
  final double? score;   // 0...5
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
  final int questionIndex; // Kaçıncı soru (0-based index)
  final int correctness; // -1: yanlış, 0: boş, 1: doğru
  final List<String> correctAnswer; // Doğru Cevap, birden fazla olabilir fill in the blanks için
  final String explanation; // Ai açıklama
  final double? score; // 0-5 arası
  AiExamQuestionEvaluateResult({
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
  final List<AiExamQuestionEvaluateResult> questionEvaluations; //Tüm Soruların Sıralanmış Hali
  final Map<String, int> topicPercentage; //Her topic'in doğruluk oranı
  AiExamEvaluateResult({
    required this.totalScore,
    required this.correctCount,
    required this.falseCount,
    required this.emptyCount,
    required this.questionEvaluations,
    required this.topicPercentage
  });
}

