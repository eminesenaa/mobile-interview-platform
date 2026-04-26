// ===================== File: lib/models/job_posting.dart =====================
// Purpose:
// Represents a public job posting created by an HR user.
//
// FLOW:
// HR creates JobPosting → Candidates apply → HR reviews applications →
// Selected candidates are accepted → Interview is created from this posting.
//
// This is the ENTRY POINT of the hiring pipeline.
//
// ============================================================================

enum JobPostingStatus {
  active, // ilan açık, başvuru alınabilir
  closed, // ilan kapalı, artık başvuru alınmaz
}

enum JobLevel {
  intern,
  junior,
  mid,
  senior,
}

enum WorkType {
  remote,
  hybrid,
  onsite,
}

class JobPosting {
  final String id;

  /// 🔹 Relations
  final String companyId;
  final String createdByHrId;

  /// 🔹 Basic job info
  final String title; // "Frontend Developer"
  final JobLevel level; // junior / senior / intern
  final WorkType workType; // remote / hybrid / onsite

  /// 🔹 Location
  final String country;
  final String city;

  /// 🔹 Optional salary
  final String? salaryRange; // "$4000 - $6000"

  /// 🔹 Description
  final String description; // uzun text
  final String requirements; // bullet list gibi text

  /// 🔹 Status
  final JobPostingStatus status;

  /// 🔹 Applications
  final List<String> applicationIds;

  /// 🔥 CRITICAL:
  /// HR tarafından seçilen adaylar
  /// Bu adaylar interview'a gidecek
  final List<String> acceptedCandidateIds;

  /// 🔹 Metadata
  final DateTime createdAt;
  final DateTime? closedAt;

  const JobPosting({
    required this.id,
    required this.companyId,
    required this.createdByHrId,
    required this.title,
    required this.level,
    required this.workType,
    required this.country,
    required this.city,
    this.salaryRange,
    required this.description,
    required this.requirements,
    this.status = JobPostingStatus.active,
    this.applicationIds = const [],
    this.acceptedCandidateIds = const [],
    required this.createdAt,
    this.closedAt,
  });

  // ===================== JSON =====================

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      createdByHrId: json['createdByHrId'] ?? '',
      title: json['title'] ?? '',
      level: JobLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => JobLevel.junior,
      ),
      workType: WorkType.values.firstWhere(
        (e) => e.name == json['workType'],
        orElse: () => WorkType.onsite,
      ),
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      salaryRange: json['salaryRange'],
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',
      status: JobPostingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => JobPostingStatus.active,
      ),
      applicationIds: List<String>.from(json['applicationIds'] ?? []),
      acceptedCandidateIds:
          List<String>.from(json['acceptedCandidateIds'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      closedAt:
          json['closedAt'] != null ? DateTime.tryParse(json['closedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'createdByHrId': createdByHrId,
      'title': title,
      'level': level.name,
      'workType': workType.name,
      'country': country,
      'city': city,
      if (salaryRange != null) 'salaryRange': salaryRange,
      'description': description,
      'requirements': requirements,
      'status': status.name,
      'applicationIds': applicationIds,
      'acceptedCandidateIds': acceptedCandidateIds,
      'createdAt': createdAt.toIso8601String(),
      if (closedAt != null) 'closedAt': closedAt!.toIso8601String(),
    };
  }

  // ===================== COPY =====================

  JobPosting copyWith({
    String? id,
    String? companyId,
    String? createdByHrId,
    String? title,
    JobLevel? level,
    WorkType? workType,
    String? country,
    String? city,
    String? salaryRange,
    String? description,
    String? requirements,
    JobPostingStatus? status,
    List<String>? applicationIds,
    List<String>? acceptedCandidateIds,
    DateTime? createdAt,
    DateTime? closedAt,
  }) {
    return JobPosting(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      createdByHrId: createdByHrId ?? this.createdByHrId,
      title: title ?? this.title,
      level: level ?? this.level,
      workType: workType ?? this.workType,
      country: country ?? this.country,
      city: city ?? this.city,
      salaryRange: salaryRange ?? this.salaryRange,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      status: status ?? this.status,
      applicationIds: applicationIds ?? this.applicationIds,
      acceptedCandidateIds: acceptedCandidateIds ?? this.acceptedCandidateIds,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}
