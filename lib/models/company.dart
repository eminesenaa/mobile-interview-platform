// ===================== File: lib/models/company.dart =====================
// Purpose:
// Represents a company entity in the system.
// Each HR user belongs to a company.
// Each interview is created under a company.
//
// This model is the root of the HR system.
//
// ========================================================================

class Company {
  final String id;
  final String name;

  /// Company domain (e.g. techcorp.com)
  final String? domain;

  /// Optional logo
  final String? logoUrl;

  /// List of HR user IDs belonging to this company
  final List<String> hrUserIds;

  /// Metadata
  final DateTime createdAt;

  const Company({
    required this.id,
    required this.name,
    this.domain,
    this.logoUrl,
    this.hrUserIds = const [],
    required this.createdAt,
  });

  // -------------------- JSON --------------------

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      domain: json['domain'],
      logoUrl: json['logoUrl'],
      hrUserIds: List<String>.from(json['hrUserIds'] ?? []),
      createdAt:
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (domain != null) 'domain': domain,
      if (logoUrl != null) 'logoUrl': logoUrl,
      'hrUserIds': hrUserIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // -------------------- COPY --------------------

  Company copyWith({
    String? id,
    String? name,
    String? domain,
    String? logoUrl,
    List<String>? hrUserIds,
    DateTime? createdAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      logoUrl: logoUrl ?? this.logoUrl,
      hrUserIds: hrUserIds ?? this.hrUserIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}