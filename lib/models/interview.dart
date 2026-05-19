// ===================== File: lib/models/interview.dart =====================
// Purpose:
// Core model for the Interview system.
//
// Represents a scheduled interview session created by an hr user
// under a company. Includes:
// - Scheduling (start/end time)
// - Assigned candidates
// - Question set
// - Join code access

// scheduled → UPCOMING
// active → ONGOING
// completed + pending → NEEDS REVIEW
// completed + reviewed → REVIEWED
//
// This is the central entity of the Interview module.
// ==========================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

enum InterviewStatus {
  scheduled, // henüz başlamadı
  active, // şu an devam ediyor
  completed, // bitmiş
}

enum ReviewStatus {
  pending, // henüz değerlendirilmedi
  reviewed, // değerlendirme tamamlandı
}

class Interview {
  final String id;

  /// Company & hr
  final String companyId;
  final String createdByHrId;

  /// Basic info
  final String title;
  final String position;

  /// Questions (reuse existing Question model)
  final List<Question> questions;

  /// Assigned candidates
  final List<String> candidateIds;

  /// Completed candidates
  final List<String> completedCandidateIds;

  /// Scheduling
  final DateTime startTime;
  final DateTime endTime;

  /// Join system
  final String joinCode;

  /// 🔥 NEW: Source job posting (ilan bağlantısı)
  final String? jobPostingId;

  /// Status
  final InterviewStatus status;
  final ReviewStatus reviewStatus;

  /// Metadata
  final DateTime createdAt;

  const Interview({
    required this.id,
    required this.companyId,
    required this.createdByHrId,
    required this.title,
    required this.position,
    required this.questions,
    required this.candidateIds,
    this.completedCandidateIds = const [],
    required this.startTime,
    required this.endTime,
    required this.joinCode,
    this.jobPostingId,
    required this.status,
    required this.reviewStatus,
    required this.createdAt,
  });

  // -------------------- JSON --------------------

  factory Interview.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return Interview(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      createdByHrId: json['createdByHrId'] ?? '',
      title: json['title'] ?? '',
      position: json['position'] ?? '',
      questions: () {
        final rawQs = json['questions'] as List<dynamic>? ?? [];
        final List<Question> list = [];
        for (int i = 0; i < rawQs.length; i++) {
          final q = rawQs[i] as Map<String, dynamic>;
          final rawId = q['id']?.toString() ?? '';
          final id = rawId.isNotEmpty ? rawId : 'q_$i';
          list.add(Question.fromFirestore(q, id));
        }
        return list;
      }(),
      candidateIds: List<String>.from(json['candidateIds'] ?? []),
      completedCandidateIds: List<String>.from(json['completedCandidateIds'] ?? []),
      startTime: parseDateTime(json['startTime']),
      endTime: parseDateTime(json['endTime']),
      joinCode: json['joinCode'] ?? '',
      jobPostingId: json['jobPostingId'],
      status: InterviewStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InterviewStatus.scheduled,
      ),
      reviewStatus: ReviewStatus.values.firstWhere(
        (e) => e.name == json['reviewStatus'],
        orElse: () => ReviewStatus.pending,
      ),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'createdByHrId': createdByHrId,
      'title': title,
      'position': position,
      'questions': questions.map((q) => q.toJson()).toList(),
      'candidateIds': candidateIds,
      'completedCandidateIds': completedCandidateIds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'joinCode': joinCode,
      if (jobPostingId != null) 'jobPostingId': jobPostingId,
      'status': status.name,
      'reviewStatus': reviewStatus.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // -------------------- COPY --------------------

  Interview copyWith({
    String? id,
    String? companyId,
    String? createdByHrId,
    String? title,
    String? position,
    List<Question>? questions,
    List<String>? candidateIds,
    List<String>? completedCandidateIds,
    DateTime? startTime,
    DateTime? endTime,
    String? joinCode,
    String? jobPostingId,
    InterviewStatus? status,
    ReviewStatus? reviewStatus,
    DateTime? createdAt,
  }) {
    return Interview(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      createdByHrId: createdByHrId ?? this.createdByHrId,
      title: title ?? this.title,
      position: position ?? this.position,
      questions: questions ?? this.questions,
      candidateIds: candidateIds ?? this.candidateIds,
      completedCandidateIds: completedCandidateIds ?? this.completedCandidateIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      joinCode: joinCode ?? this.joinCode,
      jobPostingId: jobPostingId ?? this.jobPostingId,
      status: status ?? this.status,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // -------------------- HELPERS --------------------

  /// 5 dakika önce giriş açılır
  DateTime get joinOpenTime => startTime.subtract(const Duration(minutes: 5));

  /// Süre (dakika)
  Duration get duration => endTime.difference(startTime);
}
