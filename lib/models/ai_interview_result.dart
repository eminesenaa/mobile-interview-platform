// ===================== File: lib/models/ai_interview_result.dart =====================
// Purpose:
// Represents the complete AI evaluation of a candidate's interview.
//
// Contains:
// - Stage 2 output: final decision, executive summary, role recommendation
// - Stage 1 results: embedded list of per-question evaluations
// - Core stats: totalScore, correctCount, wrongCount, unansweredCount
// - Topic breakdown: topicPercentage map
//
// This replaces AiExamResult for the interview system.
// =====================================================================================

import 'ai_interview_question_result.dart';

class AiInterviewResult {
  // ── Core Stats ──
  final int totalScore;                 // 0–100
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final Map<String, int> topicPercentage; // topic → 0–100

  // ── Stage 2: Final Decision ──
  final String finalDecision;           // "strong advance" | "advance" | "borderline" | "reject" | "strong reject"
  final double overallInterviewScore;   // 0.0–5.0
  final String executiveSummary;
  final List<String> globalStrengths;
  final List<String> globalWeaknesses;
  final List<String> criticalRedFlags;
  final String recommendedRoleLevel;    // "junior" | "mid" | "senior" | "tech lead" | "none"

  // ── Stage 1: Per-Question Results ──
  final List<AiInterviewQuestionResult> questionResults;

  const AiInterviewResult({
    this.totalScore = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.unansweredCount = 0,
    this.topicPercentage = const {},
    required this.finalDecision,
    required this.overallInterviewScore,
    this.executiveSummary = '',
    this.globalStrengths = const [],
    this.globalWeaknesses = const [],
    this.criticalRedFlags = const [],
    this.recommendedRoleLevel = 'none',
    this.questionResults = const [],
  });

  // ── Factory: Build from both stages ──

  factory AiInterviewResult.fromStages(
    List<AiInterviewQuestionResult> stage1Results,
    Map<String, dynamic> stage2Json,
  ) {
    // Compute core stats from Stage 1 results
    final advanceCount =
        stage1Results.where((q) => q.decision == 'advance').length;
    final rejectCount =
        stage1Results.where((q) => q.decision == 'reject').length;
    final borderlineCount = stage1Results.length - advanceCount - rejectCount;

    // Compute topic percentages from per-question covered_tags
    final Map<String, List<double>> buckets = {};
    for (final q in stage1Results) {
      for (final tag in q.coveredTags) {
        final key = tag.toLowerCase();
        buckets.putIfAbsent(key, () => []).add(q.overallScore);
      }
    }
    final topicPct = <String, int>{};
    buckets.forEach((topic, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      topicPct[topic] = (avg * 20).clamp(0, 100).round(); // 0–5 → 0–100
    });

    final score =
        (stage2Json['overall_interview_score'] as num?)?.toDouble() ?? 0.0;

    return AiInterviewResult(
      totalScore: (score * 20).clamp(0, 100).round(),
      correctCount: advanceCount,
      wrongCount: rejectCount,
      unansweredCount: borderlineCount,
      topicPercentage: topicPct,
      finalDecision:
          (stage2Json['final_decision'] as String?) ?? 'borderline',
      overallInterviewScore: score,
      executiveSummary:
          (stage2Json['executive_summary'] as String?) ?? '',
      globalStrengths:
          _toStringList(stage2Json['global_strengths']),
      globalWeaknesses:
          _toStringList(stage2Json['global_weaknesses']),
      criticalRedFlags:
          _toStringList(stage2Json['critical_red_flags']),
      recommendedRoleLevel:
          (stage2Json['recommended_role_level'] as String?) ?? 'none',
      questionResults: stage1Results,
    );
  }

  // ── JSON serialization ──

  factory AiInterviewResult.fromJson(Map<String, dynamic> json) {
    final qResults = (json['questionResults'] as List? ?? [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          return AiInterviewQuestionResult.fromJson(
            m,
            m['questionId'] ?? '',
            (m['questionIndex'] as num?)?.toInt() ?? 0,
          );
        })
        .toList();

    return AiInterviewResult(
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      unansweredCount: (json['unansweredCount'] as num?)?.toInt() ?? 0,
      topicPercentage:
          Map<String, int>.from(json['topicPercentage'] ?? {}),
      finalDecision: json['finalDecision'] ?? 'borderline',
      overallInterviewScore:
          (json['overallInterviewScore'] as num?)?.toDouble() ?? 0.0,
      executiveSummary: json['executiveSummary'] ?? '',
      globalStrengths: _toStringList(json['globalStrengths']),
      globalWeaknesses: _toStringList(json['globalWeaknesses']),
      criticalRedFlags: _toStringList(json['criticalRedFlags']),
      recommendedRoleLevel: json['recommendedRoleLevel'] ?? 'none',
      questionResults: qResults,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalScore': totalScore,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'unansweredCount': unansweredCount,
        'topicPercentage': topicPercentage,
        'finalDecision': finalDecision,
        'overallInterviewScore': overallInterviewScore,
        'executiveSummary': executiveSummary,
        'globalStrengths': globalStrengths,
        'globalWeaknesses': globalWeaknesses,
        'criticalRedFlags': criticalRedFlags,
        'recommendedRoleLevel': recommendedRoleLevel,
        'questionResults': questionResults.map((q) => q.toJson()).toList(),
      };

  // ── Helpers ──

  static List<String> _toStringList(dynamic val) {
    if (val is List) return val.map((e) => e.toString()).toList();
    return const [];
  }
}
