// ===================== File: lib/models/interview_result.dart =====================
// Purpose:
// Represents the result of a candidate for a specific interview.
//
// Includes:
// - Candidate answers
// - AI evaluation result
// - Final score
// - hr decision (accepted / rejected)
// - hr message
//
// This model connects Interview ↔ Candidate ↔ hr
// ================================================================================

import 'user.dart';
import 'ai_interview_result.dart';

enum InterviewDecisionStatus {
  pending,   // hr henüz karar vermedi
  accepted,
  rejected,
}

class InterviewResult {
  final String id;

  /// Relations
  final String interviewId;
  final String candidateId;

  /// Embedded candidate (for UI access)
  final User? candidate;

  /// Candidate answers
  /// questionId -> answer
  final Map<String, dynamic> answers;

  /// AI evaluation result from the two-stage interview grading pipeline
  final AiInterviewResult? aiResult;

  /// Basic stats (quick access)
  final int score;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;

  /// hr decision
  final InterviewDecisionStatus decision;

  /// hr message (manual or AI generated)
  final String? hrMessage;

  /// Flags
  final bool isSubmitted;   // aday submit etti mi
  final bool isReviewed;    // hr inceledi mi

  /// Metadata
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  const InterviewResult({
    required this.id,
    required this.interviewId,
    required this.candidateId,
    this.candidate,
    this.answers = const {},
    this.aiResult,
    this.score = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.unansweredCount = 0,
    this.decision = InterviewDecisionStatus.pending,
    this.hrMessage,
    this.isSubmitted = false,
    this.isReviewed = false,
    this.submittedAt,
    this.reviewedAt,
  });

  // -------------------- JSON --------------------

  factory InterviewResult.fromJson(Map<String, dynamic> json) {
    return InterviewResult(
      id: json['id'] ?? '',
      interviewId: json['interviewId'] ?? '',
      candidateId: json['candidateId'] ?? '',
      candidate: json['candidate'] != null
          ? User.fromJson(json['candidate'])
          : null,
      answers: json['answers'] != null
          ? Map<String, dynamic>.from(json['answers'])
          : {},
      aiResult: json['aiResult'] != null
          ? AiInterviewResult.fromJson(json['aiResult'])
          : null,
      score: json['score'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['wrongCount'] ?? 0,
      unansweredCount: json['unansweredCount'] ?? 0,
      decision: InterviewDecisionStatus.values.firstWhere(
            (e) => e.name == json['decision'],
        orElse: () => InterviewDecisionStatus.pending,
      ),
      hrMessage: json['hrMessage'],
      isSubmitted: json['isSubmitted'] ?? false,
      isReviewed: json['isReviewed'] ?? false,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interviewId': interviewId,
      'candidateId': candidateId,
      if (candidate != null) 'candidate': candidate!.toJson(),
      'answers': answers,
      if (aiResult != null) 'aiResult': aiResult!.toJson(),
      'score': score,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'unansweredCount': unansweredCount,
      'decision': decision.name,
      if (hrMessage != null) 'hrMessage': hrMessage,
      'isSubmitted': isSubmitted,
      'isReviewed': isReviewed,
      if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
    };
  }

  // -------------------- COPY --------------------

  InterviewResult copyWith({
    String? id,
    String? interviewId,
    String? candidateId,
    User? candidate,
    Map<String, dynamic>? answers,
    AiInterviewResult? aiResult,
    int? score,
    int? correctCount,
    int? wrongCount,
    int? unansweredCount,
    InterviewDecisionStatus? decision,
    String? hrMessage,
    bool? isSubmitted,
    bool? isReviewed,
    DateTime? submittedAt,
    DateTime? reviewedAt,
  }) {
    return InterviewResult(
      id: id ?? this.id,
      interviewId: interviewId ?? this.interviewId,
      candidateId: candidateId ?? this.candidateId,
      candidate: candidate ?? this.candidate,
      answers: answers ?? this.answers,
      aiResult: aiResult ?? this.aiResult,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      unansweredCount: unansweredCount ?? this.unansweredCount,
      decision: decision ?? this.decision,
      hrMessage: hrMessage ?? this.hrMessage,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isReviewed: isReviewed ?? this.isReviewed,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  String get displayName {
    if (candidate == null) return "Candidate";
    return "${candidate!.name} ${candidate!.surname}";
  }

  String get initials {
    if (candidate == null) return "NA";

    final n = candidate!.name;
    final s = candidate!.surname;

    if (n.isEmpty) return "NA";
    if (s.isEmpty) return n[0];

    return "${n[0]}${s[0]}";
  }
}

