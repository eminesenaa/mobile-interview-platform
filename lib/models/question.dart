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
  final List<String>? blanks;
  final String? codeTemplate;

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
    this.blanks,
    this.codeTemplate,
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
    final parsedType = _parseType(data['type']);

    // options yalnızca MCQ için dolu; diğer tiplerde kesinlikle null bırak
    List<String>? parsedOptions;
    if (parsedType == QuestionType.mcq && data['options'] is List) {
      parsedOptions = List<String>.from(data['options']);
    } else {
      parsedOptions = null; // <- ÖNEMLİ
    }
    return Question(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? data['text'] ?? '',
      topic: data['topic'] ?? 'General',
      difficulty: _parseDifficulty(data['difficulty']),
      status: _parseStatus(data['status']),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      type: parsedType,
      options: parsedOptions,
      // <- burada null/MCQ’ya göre
      blanks: data['blanks'] != null ? List<String>.from(data['blanks']) : null,
      codeTemplate: data['codeTemplate'] as String?,
      correctAnswer: data['correctAnswer'],
      aiPromptHelper: data['aiPromptHelper'],
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
      if (blanks != null) 'blanks': blanks,
      if (codeTemplate != null) 'codeTemplate': codeTemplate,
      'correctAnswer': correctAnswer,
      'aiPromptHelper': aiPromptHelper,
    };
  }

  static Difficulty _parseDifficulty(dynamic val) {
    if (val == null) return Difficulty.easy;

    String raw = val.toString().trim().replaceAll("–", "-").toLowerCase();

    switch (raw) {
      case '1 - easy':
      case 'easy':
        return Difficulty.easy;
      case '2 - easy-medium':
      case 'easy_medium':
        return Difficulty.easy_medium;
      case '3 - medium':
      case 'medium':
        return Difficulty.medium;
      case '4 - medium-hard':
      case 'medium_hard':
        return Difficulty.medium_hard;
      case '5 - hard':
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.easy;
    }
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

    final raw = val.toString().toLowerCase().trim();
    final core = raw.contains('.') ? raw.split('.').last : raw;
    final normalized = core.replaceAll(RegExp(r'[^a-z]'), '');

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

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln("Question ID: $id");
    buffer.writeln("Title: $title");

    if (description != null && description!.isNotEmpty) {
      buffer.writeln("Description: $description");
    }

    buffer.writeln("Topic: $topic");
    buffer.writeln("Type: ${type.name}");
    buffer.writeln("Difficulty: ${difficulty.name}");

    if (tags.isNotEmpty) {
      buffer.writeln("Tags: ${tags.join(', ')}");
    }

    if (options != null && options!.isNotEmpty) {
      for (int i = 0; i < options!.length; i++) {
        buffer.writeln("Option ${String.fromCharCode(65 + i)}: ${options![i]}");
      }
    }

    if (codeTemplate != null && codeTemplate!.isNotEmpty) {
      buffer.writeln("Code Template: $codeTemplate");
    }

    return buffer.toString();
  }
}
