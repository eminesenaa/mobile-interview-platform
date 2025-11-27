// ================= File: lib/models/user_training_progress.dart =============
// Purpose: Kullanıcının training module bazlı ilerlemesini tutar.
//          Örn: "Warm-up Quick Win" modülünde 8/10 soru → %80 progress.
// Notes:
// - Bu model, Progress (global XP) modelinden bağımsızdır.
// - XP artışları Progress içinde tutulurken, hangi modülde ne kadar
//   ilerlenmiş olduğu burada saklanır.
// ==========================================================================

/// Tek bir modül için, kullanıcının toplam ilerlemesini temsil eder.
class UserTrainingModuleProgress {
  /// Kullanıcı id (User.id).
  final String userId;

  /// TrainingModule.id
  final String moduleId;

  /// Bu modülde tamamlanan soru sayısı.
  final int completedQuestions;

  /// Bu modülde toplam soru sayısı.
  /// (TrainingModule.totalQuestions ile aynı olabilir, ama
  /// cache / offline kullanım için burada da saklayabiliriz.)
  final int totalQuestions;

  const UserTrainingModuleProgress({
    required this.userId,
    required this.moduleId,
    required this.completedQuestions,
    required this.totalQuestions,
  });

  /// 0.0 – 1.0 arası progress yüzdesi.
  double get progress =>
      totalQuestions == 0 ? 0.0 : completedQuestions / totalQuestions;

  factory UserTrainingModuleProgress.fromJson(Map<String, dynamic> j) {
    return UserTrainingModuleProgress(
      userId: (j['userId'] ?? '').toString(),
      moduleId: (j['moduleId'] ?? '').toString(),
      completedQuestions: (j['completedQuestions'] ?? 0) as int,
      totalQuestions: (j['totalQuestions'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'moduleId': moduleId,
      'completedQuestions': completedQuestions,
      'totalQuestions': totalQuestions,
    };
  }

  UserTrainingModuleProgress copyWith({
    String? userId,
    String? moduleId,
    int? completedQuestions,
    int? totalQuestions,
  }) {
    return UserTrainingModuleProgress(
      userId: userId ?? this.userId,
      moduleId: moduleId ?? this.moduleId,
      completedQuestions: completedQuestions ?? this.completedQuestions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }
}

/// Tek bir soru özelinde, kullanıcının o sorunun durumunu gösterir.
/// Örn: notStarted, inProgress, completed
enum TrainingQuestionStatus {
  notStarted,
  inProgress,
  completed,
}

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
