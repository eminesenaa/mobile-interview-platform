// ===================== File: lib/models/hr_user.dart =====================
// Purpose:
// Represents an HR user in the system.
// HR users belong to a company and are responsible for:
// - Creating interviews
// - Managing candidates
// - Reviewing results and making decisions
//
// This is separate from the main User model (candidate).
// ========================================================================

class HRUser {
  final String id;

  /// Company this HR belongs to
  final String companyId;

  /// Basic info
  final String name;
  final String surname;
  final String email;

  /// Role inside company (optional)
  /// Example: "HR Manager", "Recruiter"
  final String? roleTitle;

  /// Optional profile image
  final String? photoUrl;

  /// Metadata
  final DateTime createdAt;

  const HRUser({
    required this.id,
    required this.companyId,
    required this.name,
    required this.surname,
    required this.email,
    this.roleTitle,
    this.photoUrl,
    required this.createdAt,
  });

  // -------------------- JSON --------------------

  factory HRUser.fromJson(Map<String, dynamic> json) {
    return HRUser(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      roleTitle: json['roleTitle'],
      photoUrl: json['photoUrl'],
      createdAt:
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'surname': surname,
      'email': email,
      if (roleTitle != null) 'roleTitle': roleTitle,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // -------------------- COPY --------------------

  HRUser copyWith({
    String? id,
    String? companyId,
    String? name,
    String? surname,
    String? email,
    String? roleTitle,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return HRUser(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      roleTitle: roleTitle ?? this.roleTitle,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // -------------------- HELPERS --------------------

  String get fullName => "$name $surname";
}