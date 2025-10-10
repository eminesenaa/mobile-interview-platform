import 'package:interview_project/models/question.dart';

class Exam {
  final String id;
  final String title;
  final Duration duration;
  final List<Question> questions;
  final bool allowPause;
  final DateTime createdAt;

  // 🔹 Kullanıcının sınav sonrası verileri (Review / Library kaydı için)
  final Map<String, dynamic>? answers; // questionId -> answer
  final Map<String, dynamic>? aiFeedback; // questionId -> AI explanation
  final Map<String, int>? stats; // correct, wrong, unanswered

  const Exam({
    required this.id,
    required this.title,
    required this.duration,
    required this.questions,
    this.allowPause = false,
    required this.createdAt,
    this.answers,
    this.aiFeedback,
    this.stats,
  });

  // ✅ copyWith — review aşamasında transient değişiklikler için
  Exam copyWith({
    String? id,
    String? title,
    Duration? duration,
    List<Question>? questions,
    DateTime? createdAt,
    Map<String, dynamic>? answers,
    Map<String, dynamic>? aiFeedback,
    Map<String, int>? stats,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      answers: answers ?? this.answers,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      stats: stats ?? this.stats,
    );
  }


  factory Exam.fromFirestore(Map<String, dynamic> data) {
    return Exam(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      duration: Duration(minutes: (data['duration'] ?? 0) as int),
      questions: (data['questions'] as List<dynamic>? ?? [])
          .map((q) =>
          Question.fromFirestore(q as Map<String, dynamic>, q['id'] ?? ''))
          .toList(),
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      answers: data['answers'] != null
          ? Map<String, dynamic>.from(data['answers'])
          : null,
      aiFeedback: data['aiFeedback'] != null
          ? Map<String, dynamic>.from(data['aiFeedback'])
          : null,
      stats:
      data['stats'] != null ? Map<String, int>.from(data['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration.inMinutes,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      if (answers != null) 'answers': answers,
      if (aiFeedback != null) 'aiFeedback': aiFeedback,
      if (stats != null) 'stats': stats,
    };
  }
}

class ExamStateModel {
  final String examId;
  final Map<String, dynamic> answers; // mcq: optionId, text: string
  final Set<String> flagged;
  final int currentIndex;
  final int secondsLeft;
  final bool submitted;

  /// İlerleme bilgileri — kullanıcı kaç soruya yanıt verdi, kaçı boş
  final int answered;
  final int unanswered;

  const ExamStateModel({
    required this.examId,
    this.answers = const {},
    this.flagged = const {},
    this.currentIndex = 0,
    required this.secondsLeft,
    this.submitted = false,
    this.answered = 0,
    this.unanswered = 0,
  });

  ExamStateModel copyWith({
    Map<String, dynamic>? answers,
    Set<String>? flagged,
    int? currentIndex,
    int? secondsLeft,
    bool? submitted,
    int? answered,
    int? unanswered,
  }) {
    return ExamStateModel(
      examId: examId,
      answers: answers ?? this.answers,
      flagged: flagged ?? this.flagged,
      currentIndex: currentIndex ?? this.currentIndex,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      submitted: submitted ?? this.submitted,
      answered: answered ?? this.answered,
      unanswered: unanswered ?? this.unanswered,
    );
  }
}