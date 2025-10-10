import 'package:interview_project/models/ai_question_evaluation.dart';

class AiExamResult {
  final int totalScore;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final Map<String, int> topicPercentage;
  final List<AiExamQuestionEvaluation> questionEvaluations;

  const AiExamResult({
    required this.totalScore,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.topicPercentage,
    required this.questionEvaluations,
  });

  factory AiExamResult.fromJson(Map<String, dynamic> json) {
    return AiExamResult(
      totalScore: (json['totalScore'] ?? 0).round(),
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['falseCount'] ?? json['wrong'] ?? 0,
      unansweredCount: json['emptyCount'] ?? json['unanswered'] ?? 0,
      topicPercentage:
      Map<String, int>.from(json['topicPercentage'] ?? {}),
      questionEvaluations: (json['questionEvaluations'] as List? ?? [])
          .map((e) => AiExamQuestionEvaluation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalScore': totalScore,
    'correctCount': correctCount,
    'wrongCount': wrongCount,
    'unansweredCount': unansweredCount,
    'topicPercentage': topicPercentage,
    'questionEvaluations':
    questionEvaluations.map((e) => e.toJson()).toList(),
  };

  /// ✅ AI servisinden dönen [AiExamEvaluationResult] benzeri bir objeyi dönüştürür.
  /// Eğer `evaluateExam()` fonksiyonundan gelen model farklı adlarla gelirse (örneğin `falseCount`, `emptyCount`),
  /// bu factory uyumlu hale getirir.
  factory AiExamResult.fromEvaluateResult(dynamic eval) {
    return AiExamResult(
      totalScore: (eval.totalScore ?? 0).round(),
      correctCount: eval.correctCount ?? 0,
      wrongCount: eval.falseCount ?? eval.wrongCount ?? 0,
      unansweredCount: eval.emptyCount ?? eval.unansweredCount ?? 0,
      topicPercentage: eval.topicPercentage.map(
            (k, v) => MapEntry(k, (v is double) ? v.round() : v),
      ),
      questionEvaluations: (eval.questionEvaluations ?? [])
          .map<AiExamQuestionEvaluation>(
            (e) => AiExamQuestionEvaluation(
          index: e.index,
          verdict: e.verdict,
          feedback: e.feedback,
        ),
      )
          .toList(),
    );
  }




}
