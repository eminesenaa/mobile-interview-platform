// ===================== File: lib/models/ai_interview_result.dart =====================
// Purpose:
// Represents the complete AI evaluation of a candidate's interview.
//
// Contains:
// - Stage 2 output: final decision, executive summary, role recommendation
// - Stage 1 results: embedded list of per-question evaluations
// - Backward-compatible fields: topicPercentage, correctCount, etc.
//   (so existing UI code that reads aiResult.topicPercentage still works)
//
// This replaces AiExamResult for the interview system.
// =====================================================================================

import 'ai_interview_question_result.dart';

class AiInterviewResult {
  // ── Stage 2: Final Decision ──
  final String finalDecision; // "strong advance" | "advance" | "borderline" | "reject" | "strong reject"
  final double overallInterviewScore; // 0.0–5.0
  final String executiveSummary;
  final List<String> globalStrengths;
  final List<String> globalWeaknesses;
  final List<String> criticalRedFlags;
  final String technicalCompetenceSummary;
  final String behavioralSoftSkillsSummary;
  final String recommendedRoleLevel; // "junior" | "mid" | "senior" | "tech lead" | "none"
  final List<String> areasForProbingInNextRound;

  // ── Stage 1: Per-Question Results ──
  final List<AiInterviewQuestionResult> questionResults;

  const AiInterviewResult({
    required this.finalDecision,
    required this.overallInterviewScore,
    this.executiveSummary = '',
    this.globalStrengths = const [],
    this.globalWeaknesses = const [],
    this.criticalRedFlags = const [],
    this.technicalCompetenceSummary = '',
    this.behavioralSoftSkillsSummary = '',
    this.recommendedRoleLevel = 'none',
    this.areasForProbingInNextRound = const [],
    this.questionResults = const [],
  });

  // ── Backward-compat: fields that InterviewResult / HR controllers expect ──

  /// 0–100 score (same scale as AiExamResult.totalScore)
  int get totalScore => (overallInterviewScore * 20).clamp(0, 100).round();

  int get correctCount =>
      questionResults.where((q) => q.decision == 'advance').length;

  int get wrongCount =>
      questionResults.where((q) => q.decision == 'reject').length;

  int get unansweredCount => questionResults
      .where((q) => q.decision != 'advance' && q.decision != 'reject')
      .length;

  /// Topic → percentage (0–100) — aggregated from per-question covered_tags.
  /// Groups by topic and computes average score as percentage.
  Map<String, int> get topicPercentage {
    final Map<String, List<double>> buckets = {};

    for (final q in questionResults) {
      // Use covered_tags as topic keys
      for (final tag in q.coveredTags) {
        final key = tag.toLowerCase();
        buckets.putIfAbsent(key, () => []).add(q.overallScore);
      }
    }

    final result = <String, int>{};
    buckets.forEach((topic, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      result[topic] = (avg * 20).clamp(0, 100).round(); // 0–5 → 0–100
    });

    return result;
  }

  // ── Factory: Build from both stages ──

  factory AiInterviewResult.fromStages(
    List<AiInterviewQuestionResult> stage1Results,
    Map<String, dynamic> stage2Json,
  ) {
    return AiInterviewResult(
      finalDecision:
          (stage2Json['final_decision'] as String?) ?? 'borderline',
      overallInterviewScore:
          (stage2Json['overall_interview_score'] as num?)?.toDouble() ?? 0.0,
      executiveSummary:
          (stage2Json['executive_summary'] as String?) ?? '',
      globalStrengths:
          _toStringList(stage2Json['global_strengths']),
      globalWeaknesses:
          _toStringList(stage2Json['global_weaknesses']),
      criticalRedFlags:
          _toStringList(stage2Json['critical_red_flags']),
      technicalCompetenceSummary:
          (stage2Json['technical_competence_summary'] as String?) ?? '',
      behavioralSoftSkillsSummary:
          (stage2Json['behavioral_and_soft_skills_summary'] as String?) ?? '',
      recommendedRoleLevel:
          (stage2Json['recommended_role_level'] as String?) ?? 'none',
      areasForProbingInNextRound:
          _toStringList(stage2Json['areas_for_probing_in_next_round']),
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
      finalDecision: json['finalDecision'] ?? 'borderline',
      overallInterviewScore:
          (json['overallInterviewScore'] as num?)?.toDouble() ?? 0.0,
      executiveSummary: json['executiveSummary'] ?? '',
      globalStrengths: _toStringList(json['globalStrengths']),
      globalWeaknesses: _toStringList(json['globalWeaknesses']),
      criticalRedFlags: _toStringList(json['criticalRedFlags']),
      technicalCompetenceSummary: json['technicalCompetenceSummary'] ?? '',
      behavioralSoftSkillsSummary: json['behavioralSoftSkillsSummary'] ?? '',
      recommendedRoleLevel: json['recommendedRoleLevel'] ?? 'none',
      areasForProbingInNextRound:
          _toStringList(json['areasForProbingInNextRound']),
      questionResults: qResults,
    );
  }

  Map<String, dynamic> toJson() => {
        'finalDecision': finalDecision,
        'overallInterviewScore': overallInterviewScore,
        'executiveSummary': executiveSummary,
        'globalStrengths': globalStrengths,
        'globalWeaknesses': globalWeaknesses,
        'criticalRedFlags': criticalRedFlags,
        'technicalCompetenceSummary': technicalCompetenceSummary,
        'behavioralSoftSkillsSummary': behavioralSoftSkillsSummary,
        'recommendedRoleLevel': recommendedRoleLevel,
        'areasForProbingInNextRound': areasForProbingInNextRound,
        'questionResults': questionResults.map((q) => q.toJson()).toList(),
        // Derived fields persisted for quick access
        'totalScore': totalScore,
        'topicPercentage': topicPercentage,
      };

  // ── Helpers ──

  static List<String> _toStringList(dynamic val) {
    if (val is List) return val.map((e) => e.toString()).toList();
    return const [];
  }
}
