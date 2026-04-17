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
//
// This is the central entity of the Interview module.
// ==========================================================================

import 'question.dart';

enum InterviewStatus {
  scheduled,   // henüz başlamadı
  active,      // şu an devam ediyor
  completed,   // bitmiş
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

  /// Scheduling
  final DateTime startTime;
  final DateTime endTime;

  /// Join system
  final String joinCode;

  /// Status
  final InterviewStatus status;

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
    required this.startTime,
    required this.endTime,
    required this.joinCode,
    required this.status,
    required this.createdAt,
  });

  // -------------------- JSON --------------------

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      createdByHrId: json['createdByHrId'] ?? '',
      title: json['title'] ?? '',
      position: json['position'] ?? '',
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => Question.fromFirestore(q, q['id'] ?? ''))
          .toList(),
      candidateIds: List<String>.from(json['candidateIds'] ?? []),
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      joinCode: json['joinCode'] ?? '',
      status: InterviewStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => InterviewStatus.scheduled,
      ),
      createdAt:
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
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
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'joinCode': joinCode,
      'status': status.name,
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
    DateTime? startTime,
    DateTime? endTime,
    String? joinCode,
    InterviewStatus? status,
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
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      joinCode: joinCode ?? this.joinCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // -------------------- HELPERS --------------------

  /// 5 dakika önce giriş açılır
  DateTime get joinOpenTime =>
      startTime.subtract(const Duration(minutes: 5));

  /// Süre (dakika)
  Duration get duration => endTime.difference(startTime);
}