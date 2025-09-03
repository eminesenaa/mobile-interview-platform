// ===================== File: lib/models/user.dart =====================
// Purpose: Uygulama kullanıcısı. Kimlik bilgileriyle birlikte Streak gibi
//          alt modülleri içerir. Progress/Library/StudyPlan alanları daha
//          sonra eklenecek.
// =====================================================================

import 'package:interview_project/models/progress.dart';
import 'package:interview_project/models/user_library.dart';

import 'streak.dart';

class User {
  final String id;
  final String name;
  final String surname;
  final int? age;
  final String username;
  final String email;
  final String? password;   // üretimde hash/token ile değişecek
  final String? photoUrl;
  final Streak streak;

  // TODO: Progress, StudyPlan modelleri eklenince buraya konacak.
  // final Progress progress;
  // final StudyPlan plan;

  /// Kullanıcının Library özet bilgileri (savedCount, collectionsCount vb.)
  final UserLibrary librarySummary;

  const User({
    required this.id,
    required this.name,
    required this.surname,
    this.age,
    required this.username,
    required this.email,
    this.password,
    this.photoUrl,
    required this.streak,
    required this.librarySummary,
  });

  factory User.initial({
    required String id,
    required String name,
    required String surname,
    required String username,
    required String email,
    String? timezone,
    String? photoUrl,
  }) =>
      User(
        id: id,
        name: name,
        surname: surname,
        username: username,
        email: email,
        photoUrl: photoUrl,
        streak: Streak.empty(timezone: timezone),
        librarySummary: UserLibrary.empty(),
      );

  // ---- JSON ----
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: (json['id'] ?? '') as String,
    name: (json['name'] ?? '') as String,
    surname: (json['surname'] ?? '') as String,
    age: json['age'] == null ? null : json['age'] as int,
    username: (json['username'] ?? '') as String,
    email: (json['email'] ?? '') as String,
    password: json['password'] as String?,
    photoUrl: json['photoUrl'] as String?,
    streak: json['streak'] == null
        ? Streak.empty()
        : Streak.fromJson(json['streak'] as Map<String, dynamic>),
    librarySummary: json['library'] == null
        ? UserLibrary.empty()
        : UserLibrary.fromJson(json['library'] as Map<String, dynamic>),
  );

  // Kimlik doğrulama için Firebase Auth kullanın.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'surname': surname,
    'age': age,
    'username': username,
    'email': email,
    'photoUrl': photoUrl,
    'streak': streak.toJson(),
    'library': librarySummary.toJson(),
  };

  User copyWith({
    String? id,
    String? name,
    String? surname,
    int? age,
    String? username,
    String? email,
    String? password,
    String? photoUrl,
    Streak? streak,
    UserLibrary? librarySummary,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        surname: surname ?? this.surname,
        age: age ?? this.age,
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
        photoUrl: photoUrl ?? this.photoUrl,
        streak: streak ?? this.streak,
        librarySummary: librarySummary ?? this.librarySummary,
      );
}
