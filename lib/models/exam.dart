import 'package:interview_project/models/question.dart';

import '../services/ai/ai_service.dart';

class Exam {
  final String id;
  final String title;
  final Duration duration;
  final List<Question> questions;
  final bool allowPause;
  final DateTime createdAt;
  final bool isInterview;

  // 🔹 Kullanıcının sınav sonrası verileri (Review / Library kaydı için)
  final Map<String, dynamic>? answers; // questionId -> answer
  final Map<String, dynamic>? aiFeedback; // questionId -> AI explanation
  final Map<String, dynamic>? stats; // correct, wrong, unanswered

  final AiExamEvaluateResult? aiResult;

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
    this.aiResult,
    this.isInterview = false,
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
    Map<String, dynamic>? stats,
    AiExamEvaluateResult? aiResult,
    bool? isInterview,
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
      aiResult: aiResult ?? this.aiResult, // 🔥
      isInterview: isInterview ?? this.isInterview,
    );
  }

  factory Exam.fromFirestore(Map<String, dynamic> data) {
    return Exam(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      duration: Duration(minutes: (data['duration'] ?? 0) as int),
      questions: () {
        final rawQs = data['questions'] as List<dynamic>? ?? [];
        final List<Question> list = [];
        for (int i = 0; i < rawQs.length; i++) {
          final q = rawQs[i] as Map<String, dynamic>;
          final rawId = q['id']?.toString() ?? '';
          final id = rawId.isNotEmpty ? rawId : 'q_$i';
          list.add(Question.fromFirestore(q, id));
        }
        return list;
      }(),
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      answers: data['answers'] != null
          ? Map<String, dynamic>.from(data['answers'])
          : null,
      aiFeedback: data['aiFeedback'] != null
          ? Map<String, dynamic>.from(data['aiFeedback'])
          : null,
      stats:
          data['stats'] != null ? Map<String, dynamic>.from(data['stats']) : null,
      isInterview: data['isInterview'] ?? false,
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
      'isInterview': isInterview,
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
