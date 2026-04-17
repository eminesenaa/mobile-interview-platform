// ===================== File: lib/models/user.dart =====================
// Purpose: Uygulama kullanıcısı. Kimlik bilgileri, XP/Level, Streak,
//          Progress ve Library gibi alt modülleri içerir.
// =====================================================================

import 'package:interview_project/models/progress.dart';
import 'package:interview_project/models/user_library.dart';
import '../utils/level_calculator.dart';
import 'streak.dart';

class User {
  final String id;
  final String name;
  final String surname;
  final int? age;
  final String username;
  final String email;
  final String? password; // üretimde hash/token ile değişecek
  final String? photoUrl;
  final String? duelAvatar; // assets/avatars/avatar1.jpg
  final Streak streak;

  /// Kullanıcının Library özet bilgileri (savedCount, collectionsCount vb.)
  final UserLibrary librarySummary;

  /// Yeni profil alanları
  final String? role;
  final String? location;
  final String? website;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? cvUrl;

  final String? phoneNumber;

  /// 🔹 Yeni eklenen alanlar
  final int totalXp;

  // final int level;
  final List<String> savedQuestions;
  final Map<String, dynamic> progress; // soru türü bazlı ilerleme

  // ===================== INTERVIEW SYSTEM FIELDS =====================

  /// Assigned interviews (Interview IDs)
  final List<String> assignedInterviewIds;

  /// Completed interview results (InterviewResult IDs)
  final List<String> interviewResultIds;

  /// Currently active interview (if user is inside one)
  final String? activeInterviewId;

  const User({
    required this.id,
    required this.name,
    required this.surname,
    this.age,
    required this.username,
    required this.email,
    this.password,
    this.photoUrl,
    this.duelAvatar,
    required this.streak,
    required this.librarySummary,
    this.role,
    this.location,
    this.website,
    this.linkedinUrl,
    this.githubUrl,
    this.cvUrl,
    this.phoneNumber,
    this.totalXp = 0,
    // this.level = 1,
    this.savedQuestions = const [],
    this.progress = const {},
    this.assignedInterviewIds = const [],
    this.interviewResultIds = const [],
    this.activeInterviewId,
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
        streak: Streak.empty(),
        //Streak.empty(timezone: timezone)
        librarySummary: UserLibrary.empty(),
        totalXp: 0,
        // level: 1,
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
        duelAvatar: json['duelAvatar'] as String?,
        // streak: Streak.empty(),
        streak: json['streak'] == null
            ? Streak.empty()
            : Streak.fromMap(json['streak'] as Map<String, dynamic>),

        librarySummary: json['library'] == null
            ? UserLibrary.empty()
            : UserLibrary.fromJson(json['library'] as Map<String, dynamic>),
        role: json['role'],
        location: json['location'],
        website: json['website'],
        linkedinUrl: json['linkedinUrl'],
        githubUrl: json['githubUrl'],
        cvUrl: json['cvUrl'],
        phoneNumber: json['phoneNumber'],

        /// 🔹 yeni alanlar
        totalXp: json['totalXp'] ?? 0,
        // level: json['level'] ?? 1,
        savedQuestions: List<String>.from(json['savedQuestions'] ?? []),
        progress: json['progress'] ?? {},
        assignedInterviewIds:
            List<String>.from(json['assignedInterviewIds'] ?? []),

        interviewResultIds: List<String>.from(json['interviewResultIds'] ?? []),

        activeInterviewId: json['activeInterviewId'],
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
        'duelAvatar': duelAvatar,
        'streak': streak.toJson(),
        'library': librarySummary.toJson(),
        'role': role,
        'location': location,
        'website': website,
        'linkedinUrl': linkedinUrl,
        'githubUrl': githubUrl,
        'cvUrl': cvUrl,
        'phoneNumber': phoneNumber,

        /// 🔹 yeni alanlar
        'totalXp': totalXp,
        // 'level': level,
        'savedQuestions': savedQuestions,
        'progress': progress,
        'assignedInterviewIds': assignedInterviewIds,
        'interviewResultIds': interviewResultIds,
        if (activeInterviewId != null) 'activeInterviewId': activeInterviewId,
      };

  User copyWith({
    String? id,
    String? name,
    String? surname,
    int? age,
    String? username,
    String? email,
    String? phoneNumber,
    String? password,
    String? photoUrl,
    String? duelAvatar,
    Streak? streak,
    UserLibrary? librarySummary,
    int? totalXp,
    int? level,
    List<String>? savedQuestions,
    Map<String, dynamic>? progress,
    String? role,
    String? location,
    String? website,
    String? linkedinUrl,
    String? githubUrl,
    String? cvUrl,
    List<String>? assignedInterviewIds,
    List<String>? interviewResultIds,
    String? activeInterviewId,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        surname: surname ?? this.surname,
        age: age ?? this.age,
        username: username ?? this.username,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        password: password ?? this.password,
        photoUrl: photoUrl ?? this.photoUrl,
        duelAvatar: duelAvatar ?? this.duelAvatar,
        streak: streak ?? this.streak,
        librarySummary: librarySummary ?? this.librarySummary,
        totalXp: totalXp ?? this.totalXp,
        // level: level ?? this.level,
        savedQuestions: savedQuestions ?? this.savedQuestions,
        progress: progress ?? this.progress,
        role: role ?? this.role,
        location: location ?? this.location,
        website: website ?? this.website,
        linkedinUrl: linkedinUrl ?? this.linkedinUrl,
        githubUrl: githubUrl ?? this.githubUrl,
        cvUrl: cvUrl ?? this.cvUrl,
        assignedInterviewIds: assignedInterviewIds ?? this.assignedInterviewIds,
        interviewResultIds: interviewResultIds ?? this.interviewResultIds,
        activeInterviewId: activeInterviewId ?? this.activeInterviewId,
      );

  /// User avatar — duelAvatar (user-selected) takes priority over photoUrl (Google/auth)
  String? get avatar {
    if (duelAvatar != null && duelAvatar!.isNotEmpty) return duelAvatar;
    if (photoUrl != null && photoUrl!.isNotEmpty) return photoUrl;
    return null;
  }

  /// 🔹 Level artık XP üzerinden hesaplanır (stored değil computed)
  int get level => LevelCalculator.calculate(totalXp);
}
