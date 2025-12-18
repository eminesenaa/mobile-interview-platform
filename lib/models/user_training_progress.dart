// ===================== File: lib/models/user_training_progress.dart =====================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Tek bir modül için, kullanıcının toplam ilerlemesini temsil eder.
class UserTrainingModuleProgress {
  final String userId;
  final String moduleId;
  final int completedQuestions;
  final int totalQuestions;
  final DateTime lastUpdated;
  final bool isCompleted;
  
  // Çözülen soruların ID listesi
  final List<String> solvedQuestionIds; 

  UserTrainingModuleProgress({
    required this.userId,
    required this.moduleId,
    required this.completedQuestions,
    required this.totalQuestions,
    required this.lastUpdated,
    this.isCompleted = false,
    this.solvedQuestionIds = const [], 
  });

  double get progress =>
      totalQuestions == 0 ? 0.0 : completedQuestions / totalQuestions;

  factory UserTrainingModuleProgress.fromJson(Map<String, dynamic> j) {
    // 1. Çözülen soru ID'lerini ayıkla
    List<String> parsedSolvedIds = [];
    if (j['questions'] != null && j['questions'] is List) {
      for (var q in j['questions']) {
        if (q is Map && q['status'] == 'completed') {
          parsedSolvedIds.add(q['questionId'].toString());
        }
      }
    }

    // 2. Tarih Dönüşümü (Hem Timestamp hem int desteği)
    DateTime parsedDate = DateTime.now();
    final rawDate = j['lastUpdated'];

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    }

    return UserTrainingModuleProgress(
      userId: (j['userId'] ?? '').toString(),
      moduleId: (j['moduleId'] ?? '').toString(),
      completedQuestions: (j['completedQuestions'] ?? 0) as int,
      totalQuestions: (j['totalQuestions'] ?? 0) as int,
      lastUpdated: parsedDate,
      isCompleted: j['isCompleted'] ?? false,
      solvedQuestionIds: parsedSolvedIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'moduleId': moduleId,
      'completedQuestions': completedQuestions,
      'totalQuestions': totalQuestions,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  UserTrainingModuleProgress copyWith({
    String? userId,
    String? moduleId,
    int? completedQuestions,
    int? totalQuestions,
    DateTime? lastUpdated,
    bool? isCompleted,
    List<String>? solvedQuestionIds,
  }) {
    return UserTrainingModuleProgress(
      userId: userId ?? this.userId,
      moduleId: moduleId ?? this.moduleId,
      completedQuestions: completedQuestions ?? this.completedQuestions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isCompleted: isCompleted ?? this.isCompleted,
      solvedQuestionIds: solvedQuestionIds ?? this.solvedQuestionIds,
    );
  }
}

/// 🔥 BU ENUM EKSİK KALDIĞI İÇİN HATA ALIYORDUNUZ:
enum TrainingQuestionStatus {
  notStarted,
  inProgress,
  completed,
}

/// Tek bir soru özelinde, kullanıcının o sorunun durumunu gösterir.
class UserTrainingQuestionProgress {
  final String userId;
  final String moduleId;
  final String sectionId;
  final String questionId;
  final TrainingQuestionStatus status;

  const UserTrainingQuestionProgress({
    required this.userId,
    required this.moduleId,
    required this.sectionId,
    required this.questionId,
    required this.status,
  });

  factory UserTrainingQuestionProgress.fromJson(Map<String, dynamic> j) {
    final statusRaw = (j['status'] ?? 'notStarted').toString();
    final parsedStatus = TrainingQuestionStatus.values.firstWhere(
      (s) => s.name == statusRaw,
      orElse: () => TrainingQuestionStatus.notStarted,
    );

    return UserTrainingQuestionProgress(
      userId: (j['userId'] ?? '').toString(),
      moduleId: (j['moduleId'] ?? '').toString(),
      sectionId: (j['sectionId'] ?? '').toString(),
      questionId: (j['questionId'] ?? '').toString(),
      status: parsedStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'moduleId': moduleId,
      'sectionId': sectionId,
      'questionId': questionId,
      'status': status.name,
    };
  }

  UserTrainingQuestionProgress copyWith({
    String? userId,
    String? moduleId,
    String? sectionId,
    String? questionId,
    TrainingQuestionStatus? status,
  }) {
    return UserTrainingQuestionProgress(
      userId: userId ?? this.userId,
      moduleId: moduleId ?? this.moduleId,
      sectionId: sectionId ?? this.sectionId,
      questionId: questionId ?? this.questionId,
      status: status ?? this.status,
    );
  }
}