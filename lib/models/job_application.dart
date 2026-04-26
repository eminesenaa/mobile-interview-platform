// ===================== File: lib/models/job_application.dart =====================
// Purpose:
// Represents a candidate's application to a JobPosting.
//
// FLOW:
// Candidate applies → Application created → HR reviews →
// Application becomes accepted/rejected → accepted ones go to Interview.
//
// ===============================================================================

import 'user.dart';

enum ApplicationStatus {
  pending,   // henüz incelenmedi
  accepted,  // mülakata alınacak
  rejected,  // elendi
}

class JobApplication {
  final String id;

  /// 🔹 Relations
  final String jobPostingId;
  final String candidateId;

  /// 🔥 Embedded user (UI için hızlı erişim)
  final User? candidate;

  /// 🔹 Basic info (snapshot olarak saklıyoruz)
  final String name;
  final String email;
  final String phone;

  final String university;
  final String department;
  final String? grade; // 3rd year, graduate etc.

  /// 🔹 Status
  final ApplicationStatus status;

  /// 🔹 Metadata
  final DateTime appliedAt;
  final DateTime? reviewedAt;

  const JobApplication({
    required this.id,
    required this.jobPostingId,
    required this.candidateId,
    this.candidate,
    required this.name,
    required this.email,
    required this.phone,
    required this.university,
    required this.department,
    this.grade,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    this.reviewedAt,
  });

  // ===================== JSON =====================

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] ?? '',
      jobPostingId: json['jobPostingId'] ?? '',
      candidateId: json['candidateId'] ?? '',
      candidate: json['candidate'] != null
          ? User.fromJson(json['candidate'])
          : null,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      university: json['university'] ?? '',
      department: json['department'] ?? '',
      grade: json['grade'],
      status: ApplicationStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt:
      DateTime.tryParse(json['appliedAt'] ?? '') ?? DateTime.now(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobPostingId': jobPostingId,
      'candidateId': candidateId,
      if (candidate != null) 'candidate': candidate!.toJson(),
      'name': name,
      'email': email,
      'phone': phone,
      'university': university,
      'department': department,
      if (grade != null) 'grade': grade,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
    };
  }

  // ===================== COPY =====================

  JobApplication copyWith({
    String? id,
    String? jobPostingId,
    String? candidateId,
    User? candidate,
    String? name,
    String? email,
    String? phone,
    String? university,
    String? department,
    String? grade,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobPostingId: jobPostingId ?? this.jobPostingId,
      candidateId: candidateId ?? this.candidateId,
      candidate: candidate ?? this.candidate,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      department: department ?? this.department,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}