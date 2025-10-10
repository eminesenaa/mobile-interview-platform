class AiExamQuestionEvaluation {
  final int index;
  final String verdict; // "correct" / "wrong" / "unanswered"
  final String? feedback;

  const AiExamQuestionEvaluation({
    required this.index,
    required this.verdict,
    this.feedback,
  });

  factory AiExamQuestionEvaluation.fromJson(Map<String, dynamic> json) {
    return AiExamQuestionEvaluation(
      index: json['index'] ?? 0,
      verdict: json['verdict'] ?? '',
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'verdict': verdict,
    if (feedback != null) 'feedback': feedback,
  };
}
