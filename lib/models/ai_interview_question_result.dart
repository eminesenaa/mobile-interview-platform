// ===================== File: lib/models/ai_interview_question_result.dart =====================
// Purpose:
// Represents the AI evaluation result for a SINGLE interview question.
// Maps to the JSON schema defined in InterviewQuestionEvaluation.yml
//
// This is the Stage 1 output — one per question.
// Kept lean: only fields the frontend will actually use + what Stage 2 needs.
// ============================================================================================

class AiInterviewQuestionResult {
  // ── Identity ──
  final String questionId;
  final int questionIndex;

  // ── Core Score ──
  final double overallScore; // 0.0–5.0
  final String decision; // "advance" | "borderline" | "reject"

  // ── Subscores ──
  final Map<String, double> subscores; // correctness, complexity_awareness, code_quality, communication, explainability
  final Map<String, double>? starCoverage; // S, T, A, R (null if non-behavioral)

  // ── Qualitative ──
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> redFlags;
  final List<String> evidenceQuotes;

  // ── Tags ──
  final List<String> coveredTags;
  final List<String> missingTags;

  // ── Coaching ──
  final List<String> shortTips;
  final String? personalizedFeedback;

  // ── Soft Skills (behavioral) ──
  final String? confidence; // "low" | "medium" | "high"
  final String? communicationStyle; // "clear" | "defensive" | "vague" | "supportive" | "neutral"

  const AiInterviewQuestionResult({
    required this.questionId,
    required this.questionIndex,
    required this.overallScore,
    required this.decision,
    this.subscores = const {},
    this.starCoverage,
    this.strengths = const [],
    this.weaknesses = const [],
    this.redFlags = const [],
    this.evidenceQuotes = const [],
    this.coveredTags = const [],
    this.missingTags = const [],
    this.shortTips = const [],
    this.personalizedFeedback,
    this.confidence,
    this.communicationStyle,
  });

  // ── fromJson (defensive parsing) ──

  factory AiInterviewQuestionResult.fromJson(
    Map<String, dynamic> json,
    String questionId,
    int questionIndex,
  ) {
    final subscoresRaw = json['subscores'] as Map<String, dynamic>? ?? {};
    final starRaw = subscoresRaw['star_coverage'] as Map<String, dynamic>?;
    final softRaw = json['soft_skills'] as Map<String, dynamic>? ?? {};
    final coachingRaw = json['coaching_tips'] as Map<String, dynamic>? ?? {};

    // Build subscores map (flatten numeric values only)
    final subscores = <String, double>{};
    for (final key in [
      'correctness',
      'complexity_awareness',
      'code_quality',
      'communication',
      'explainability'
    ]) {
      final v = subscoresRaw[key];
      if (v is num) subscores[key] = v.toDouble();
    }

    // STAR coverage
    Map<String, double>? starCoverage;
    if (starRaw != null) {
      starCoverage = {};
      for (final k in ['S', 'T', 'A', 'R']) {
        final v = starRaw[k];
        if (v is num) starCoverage[k] = v.toDouble();
      }
    }

    return AiInterviewQuestionResult(
      questionId: questionId,
      questionIndex: questionIndex,
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0.0,
      decision: (json['decision'] as String?) ?? 'reject',
      subscores: subscores,
      starCoverage: starCoverage,
      strengths: _toStringList(json['strengths']),
      weaknesses: _toStringList(json['weaknesses']),
      redFlags: _toStringList(json['red_flags']),
      evidenceQuotes: _toStringList(json['evidence_quotes']),
      coveredTags: _toStringList(json['covered_tags']),
      missingTags: _toStringList(json['missing_tags']),
      shortTips: _toStringList(coachingRaw['short_tips']),
      personalizedFeedback: coachingRaw['personalized_feedback']?.toString(),
      confidence: softRaw['confidence']?.toString(),
      communicationStyle: softRaw['communication_style']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'questionIndex': questionIndex,
        'overall_score': overallScore,
        'decision': decision,
        'subscores': {
          ...subscores,
          if (starCoverage != null) 'star_coverage': starCoverage,
        },
        'strengths': strengths,
        'weaknesses': weaknesses,
        'red_flags': redFlags,
        'evidence_quotes': evidenceQuotes,
        'covered_tags': coveredTags,
        'missing_tags': missingTags,
        'coaching_tips': {
          'short_tips': shortTips,
          if (personalizedFeedback != null)
            'personalized_feedback': personalizedFeedback,
        },
        'soft_skills': {
          if (confidence != null) 'confidence': confidence,
          if (communicationStyle != null)
            'communication_style': communicationStyle,
        },
      };

  // ── Helpers ──

  static List<String> _toStringList(dynamic val) {
    if (val is List) return val.map((e) => e.toString()).toList();
    return const [];
  }
}
