// ===================== File: lib/models/question.dart =====================
// Purpose: Uygulamadaki soruların veri modelini tanımlar.
// ==========================================================================

enum QuestionType {
  mcq,
  shortAnswer,
  coding,
  fillBlank,
  debugging,
}

enum Difficulty {
  easy,
  easy_medium,
  medium,
  medium_hard,
  hard,
}

enum Status {
  todo,
  solved,
}

class Question {
  final String id;
  final String title;
  final String? description;
  final String topic;
  final Difficulty difficulty;
  final Status status;
  final List<String> tags;
  final QuestionType type;

  final List<String>? options;
  final String? correctAnswer;

  final String? aiPromptHelper;

  int get xp => _calculateXp();

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.difficulty,
    required this.status,
    required this.tags,
    required this.type,
    this.options,
    this.correctAnswer,
    this.aiPromptHelper,
  });

  static const Map<QuestionType, int> _typeBase = {
    QuestionType.mcq: 5,
    QuestionType.shortAnswer: 6,
    QuestionType.fillBlank: 6,
    QuestionType.debugging: 9,
    QuestionType.coding: 10,
  };

  static const Map<Difficulty, double> _diffMul = {
    Difficulty.easy: 1.00,
    Difficulty.easy_medium: 1.25,
    Difficulty.medium: 1.50,
    Difficulty.medium_hard: 1.75,
    Difficulty.hard: 2.00,
  };

  int _calculateXp() {
    final base = _typeBase[type] ?? 5;
    final mul = _diffMul[difficulty] ?? 1.0;
    return (base * mul).round();
  }

  // 🔹 Firestore dönüşümü
  factory Question.fromFirestore(Map<String, dynamic> data, String documentId) {
    final extra = data['extra'] != null
        ? Map<String, dynamic>.from(data['extra'])
        : <String, dynamic>{};

    List<String> opts = [];
    if (data['options'] != null) {
      opts = List<String>.from(data['options']);
    } else if (extra['options'] != null) {
      opts = List<String>.from(extra['options']);
    } else {
      for (var key in ['Option A', 'Option B', 'Option C', 'Option D']) {
        if (data[key] != null) opts.add(data[key]);
        if (extra[key] != null) opts.add(extra[key]);
      }
    }

    final correct = data['correctAnswer'] ??
        data['Correct Option'] ??
        extra['Correct Option'];

    final helper = data['aiPromptHelper'] ?? extra['AI Prompt Helper'];

    return Question(
      id: documentId,
      title: data['title'] ??
          data['Question Title'] ??
          extra['Question Title'] ??
          '',
      description: data['description'] ??
          data['text'] ?? // 🔥 Firestore’daki asıl field
          data['Question Text'] ??
          data['question_text'] ??
          extra['Question Text'] ??
          '',
      topic: data['topic'] ??
          data['Category'] ??
          extra['Category'] ??
          'General',
      difficulty: _parseDifficulty(data['difficulty']),
      status: _parseStatus(data['status']),
      tags: data['tags'] != null
          ? List<String>.from(data['tags'])
          : (extra['Tags'] != null
              ? extra['Tags']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
              : []),
      type: _parseType(data['type'] ?? extra['Question Format']),
      options: opts,
      correctAnswer: correct,
      aiPromptHelper: helper,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'topic': topic,
      'difficulty': difficulty.name,
      'status': status.name,
      'tags': tags,
      'type': type.name,
      'options': options,
      'correctAnswer': correctAnswer,
      'aiPromptHelper': aiPromptHelper,
    };
  }

  static Difficulty _parseDifficulty(dynamic val) {
    if (val == null) return Difficulty.easy;
    return Difficulty.values.firstWhere(
      (e) => e.name == val,
      orElse: () => Difficulty.easy,
    );
  }

  static Status _parseStatus(dynamic val) {
    if (val == null) return Status.todo;
    return Status.values.firstWhere(
      (e) => e.name == val,
      orElse: () => Status.todo,
    );
  }

  static QuestionType _parseType(dynamic val) {
    if (val == null) return QuestionType.mcq;

    final normalized =
        val.toString().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    switch (normalized) {
      case 'mcq':
        return QuestionType.mcq;
      case 'short':
      case 'shortanswer':
        return QuestionType.shortAnswer;
      case 'coding':
        return QuestionType.coding;
      case 'fill':
      case 'fillblank':
        return QuestionType.fillBlank;
      case 'debugging':
        return QuestionType.debugging;
      default:
        return QuestionType.mcq;
    }
  }
}
