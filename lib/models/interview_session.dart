// ===================== File: lib/models/interview_session.dart =====================
// Purpose:
// Represents the ACTIVE state of a candidate during an interview.
//
// This model exists ONLY while the interview is ongoing.
// It tracks:
// - Current question index
// - Remaining time
// - User answers (temporary)
// - Progress state
//
// When the user submits:
// → This session is converted into InterviewResult
//
// This is similar to ExamStateModel BUT isolated for interview system.
// ================================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class InterviewSession {
  final String id;

  /// Relations
  final String interviewId;
  final String candidateId;

  /// Current progress
  final int currentQuestionIndex;

  /// Remaining time in seconds
  final int secondsLeft;

  /// Answers (questionId -> answer)
  final Map<String, dynamic> answers;

  /// Flags
  final bool isStarted;
  final bool isFinished;

  /// Metadata
  final DateTime? startedAt;
  final DateTime? lastUpdatedAt;

  const InterviewSession({
    required this.id,
    required this.interviewId,
    required this.candidateId,
    this.currentQuestionIndex = 0,
    required this.secondsLeft,
    this.answers = const {},
    this.isStarted = false,
    this.isFinished = false,
    this.startedAt,
    this.lastUpdatedAt,
  });

  // -------------------- JSON --------------------

  factory InterviewSession.fromJson(Map<String, dynamic> json) {
    return InterviewSession(
      id: json['id'] ?? '',
      interviewId: json['interviewId'] ?? '',
      candidateId: json['candidateId'] ?? '',
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      secondsLeft: json['secondsLeft'] ?? 0,
      answers: json['answers'] != null
          ? Map<String, dynamic>.from(json['answers'])
          : {},
      isStarted: json['isStarted'] ?? false,
      isFinished: json['isFinished'] ?? false,
      startedAt: json['startedAt'] != null
          ? (json['startedAt'] is Timestamp
              ? (json['startedAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['startedAt'].toString()))
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? (json['lastUpdatedAt'] is Timestamp
              ? (json['lastUpdatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['lastUpdatedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interviewId': interviewId,
      'candidateId': candidateId,
      'currentQuestionIndex': currentQuestionIndex,
      'secondsLeft': secondsLeft,
      'answers': answers,
      'isStarted': isStarted,
      'isFinished': isFinished,
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      if (lastUpdatedAt != null)
        'lastUpdatedAt': lastUpdatedAt!.toIso8601String(),
    };
  }

  // -------------------- COPY --------------------

  InterviewSession copyWith({
    String? id,
    String? interviewId,
    String? candidateId,
    int? currentQuestionIndex,
    int? secondsLeft,
    Map<String, dynamic>? answers,
    bool? isStarted,
    bool? isFinished,
    DateTime? startedAt,
    DateTime? lastUpdatedAt,
  }) {
    return InterviewSession(
      id: id ?? this.id,
      interviewId: interviewId ?? this.interviewId,
      candidateId: candidateId ?? this.candidateId,
      currentQuestionIndex:
      currentQuestionIndex ?? this.currentQuestionIndex,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      answers: answers ?? this.answers,
      isStarted: isStarted ?? this.isStarted,
      isFinished: isFinished ?? this.isFinished,
      startedAt: startedAt ?? this.startedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  // -------------------- HELPERS --------------------

  /// Check if session is still active
  bool get isActive => isStarted && !isFinished;

  /// Check if time is over
  bool get isTimeUp => secondsLeft <= 0;
}