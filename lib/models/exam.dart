import 'package:interview_project/models/question.dart';

class Exam {
  final String id;
  final String title;
  final Duration duration;
  final List<Question> questions;
  final bool allowPause;
  final DateTime createdAt;

  const Exam({
    required this.id,
    required this.title,
    required this.duration,
    required this.questions,
    this.allowPause = false,
    required this.createdAt,
  });
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
