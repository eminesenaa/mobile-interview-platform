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

  const ExamStateModel({
    required this.examId,
    this.answers = const {},
    this.flagged = const {},
    this.currentIndex = 0,
    required this.secondsLeft,
    this.submitted = false,
  });

  ExamStateModel copyWith({
    Map<String, dynamic>? answers,
    Set<String>? flagged,
    int? currentIndex,
    int? secondsLeft,
    bool? submitted,
  }) {
    return ExamStateModel(
      examId: examId,
      answers: answers ?? this.answers,
      flagged: flagged ?? this.flagged,
      currentIndex: currentIndex ?? this.currentIndex,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      submitted: submitted ?? this.submitted,
    );
  }
}
