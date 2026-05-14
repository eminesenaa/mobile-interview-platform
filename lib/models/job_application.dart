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
  pending, // henüz incelenmedi
  accepted, // mülakata alınacak
  rejected, // elendi
}

class JobApplication {
  final String id;

  /// ===================== APPLICATION DATA =====================
  /// Candidate'ın başvuru sırasında verdiği bilgiler

  /// Cover letter (en önemli alan)
  final String? coverLetter;

  /// Skills (React, Flutter, etc.)
  final List<String> skills;

  /// Links
  final String? portfolioUrl;
  final String? githubUrl;
  final String? linkedinUrl;

  /// Resume / CV
  final String? resumeUrl;

  /// 🔹 Relations
  final String jobPostingId;
  final String candidateId;

  /// 🔥 Embedded user (UI için hızlı erişim)
  final User? candidate;

  /// 🔥 NEW: Convenience fields for dashboard
  final String? candidateName;
  final String? jobTitle;
  final String? location;
  final String? workType;
  final String? company;
  final String? university;
  final String? department;

  /// 🔹 Status
  final ApplicationStatus status;

  /// 🔹 Metadata
  final DateTime appliedAt;
  final DateTime? reviewedAt;

  const JobApplication({
    required this.id,
    this.coverLetter,
    this.skills = const [],
    this.portfolioUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.resumeUrl,
    required this.jobPostingId,
    required this.candidateId,
    this.candidate,
    this.candidateName,
    this.jobTitle,
    this.location,
    this.workType,
    this.company,
    this.university,
    this.department,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    this.reviewedAt,
  });

  // ===================== JSON =====================

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] ?? '',
      coverLetter: json['coverLetter'],
      skills: List<String>.from(json['skills'] ?? []),
      portfolioUrl: json['portfolioUrl'],
      githubUrl: json['githubUrl'],
      linkedinUrl: json['linkedinUrl'],
      resumeUrl: json['resumeUrl'],
      jobPostingId: json['jobPostingId'] ?? '',
      candidateId: json['candidateId'] ?? '',
      candidate:
          json['candidate'] != null ? User.fromJson(json['candidate']) : null,
      candidateName: json['candidateName'],
      jobTitle: json['jobTitle'],
      location: json['location'],
      workType: json['workType'],
      company: json['company'],
      university: json['university'],
      department: json['department'],
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: DateTime.tryParse(json['appliedAt'] ?? '') ?? DateTime.now(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (coverLetter != null) 'coverLetter': coverLetter,
      'skills': skills,
      if (portfolioUrl != null) 'portfolioUrl': portfolioUrl,
      if (githubUrl != null) 'githubUrl': githubUrl,
      if (linkedinUrl != null) 'linkedinUrl': linkedinUrl,
      if (resumeUrl != null) 'resumeUrl': resumeUrl,
      'jobPostingId': jobPostingId,
      'candidateId': candidateId,
      if (candidate != null) 'candidate': candidate!.toJson(),
      if (candidateName != null) 'candidateName': candidateName,
      if (jobTitle != null) 'jobTitle': jobTitle,
      if (location != null) 'location': location,
      if (workType != null) 'workType': workType,
      if (company != null) 'company': company,
      if (university != null) 'university': university,
      if (department != null) 'department': department,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
    };
  }

  // ===================== COPY =====================

  JobApplication copyWith({
    String? id,
    String? coverLetter,
    List<String>? skills,
    String? portfolioUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? resumeUrl,
    String? jobPostingId,
    String? candidateId,
    User? candidate,
    String? candidateName,
    String? jobTitle,
    String? location,
    String? workType,
    String? company,
    String? university,
    String? department,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
  }) {
    return JobApplication(
      id: id ?? this.id,
      coverLetter: coverLetter ?? this.coverLetter,
      skills: skills ?? this.skills,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      jobPostingId: jobPostingId ?? this.jobPostingId,
      candidateId: candidateId ?? this.candidateId,
      candidate: candidate ?? this.candidate,
      candidateName: candidateName ?? this.candidateName,
      jobTitle: jobTitle ?? this.jobTitle,
      location: location ?? this.location,
      workType: workType ?? this.workType,
      company: company ?? this.company,
      university: university ?? this.university,
      department: department ?? this.department,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}