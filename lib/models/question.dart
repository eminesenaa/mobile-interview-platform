enum QuestionType {
  mcq,
  shortAnswer,
  coding,
  fillInTheBlanks,
  debugging,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

enum Status {
  todo,
  solved,
}

class Question {
  final String id;
  final String title;
  final String topic;
  final Difficulty difficulty;
  final Status status;
  final List<String> tags;
  final QuestionType type;

  final List<String>? options;
  final String? correctAnswer;

  Question({
    required this.id,
    required this.title,
    required this.topic,
    required this.difficulty,
    required this.status,
    required this.tags,
    required this.type,
    this.options,
    this.correctAnswer,
  });
}
