// ===================== File: lib/models/user.dart =====================
// Purpose: Uygulama kullanıcısı. Kimlik bilgileri, XP/Level, Streak,
//          Progress ve Library gibi alt modülleri içerir.
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

  /// Kullanıcının Library özet bilgileri (savedCount, collectionsCount vb.)
  final UserLibrary librarySummary;

  /// 🔹 Yeni eklenen alanlar
  final int totalXp;
  final int level;
  final List<String> savedQuestions;
  final Map<String, dynamic> progress; // soru türü bazlı ilerleme

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
    this.totalXp = 0,
    this.level = 1,
    this.savedQuestions = const [],
    this.progress = const {},
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
        totalXp: 0,
        level: 1,
        savedQuestions: const [],
        progress: const {},
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

        /// 🔹 yeni alanlar
        totalXp: json['totalXp'] ?? 0,
        level: json['level'] ?? 1,
        savedQuestions: List<String>.from(json['savedQuestions'] ?? []),
        progress: json['progress'] ?? {},
      );

  // Firestore’a yazmak için
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

        /// 🔹 yeni alanlar
        'totalXp': totalXp,
        'level': level,
        'savedQuestions': savedQuestions,
        'progress': progress,
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
    int? totalXp,
    int? level,
    List<String>? savedQuestions,
    Map<String, dynamic>? progress,
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
        totalXp: totalXp ?? this.totalXp,
        level: level ?? this.level,
        savedQuestions: savedQuestions ?? this.savedQuestions,
        progress: progress ?? this.progress,
      );
}
