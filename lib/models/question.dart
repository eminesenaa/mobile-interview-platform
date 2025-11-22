// ===================== File: lib/models/question.dart =====================
// Purpose: Uygulamadaki soruların veri modelini tanımlar.
// ==========================================================================

import 'package:flutter/foundation.dart';

import '../utils/example_parser.dart';

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
  final List<ExampleCase> examples; // Input/Output/(optional) Explanation

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
    this.examples = const [],
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

    // 🔹 Examples biriktirmek için listeyi tanımla
    final List<ExampleCase> parsedExamples = <ExampleCase>[];

// 1) Yeni şema: examples alanı mevcut (List / Map)
    final examplesRaw = data['examples'];
    if (examplesRaw is List) {
      for (final e in examplesRaw) {
        if (e is Map<String, dynamic>) {
          // a) Map geldi; alanlar karışık olabilir (bazen "input" içinde Output da var).
          final rawIn = (e['input'] ?? '').toString();
          final rawOut = (e['output'] ?? '').toString();
          final rawExp = (e['explanation'] ?? e['note'] ?? '').toString();

          String _ensureLabel(String label, String v) {
            if (v.trim().isEmpty) return '';
            final low = v.trimLeft().toLowerCase();
            // zaten "label:" ile başlıyorsa dokunma
            return low.startsWith('$label:') ? v : '$label: $v';
          }

          final blob = [
            _ensureLabel('input', rawIn),
            _ensureLabel('output', rawOut),
            _ensureLabel('explanation', rawExp),
          ].where((s) => s.isNotEmpty).join('\n');

          if (blob.isNotEmpty) {
            final p = ExampleParser.parse(blob);
            final ex = ExampleCase(
              input: p.input,
              output: p.output,
              explanation: p.explanation,
            );
            parsedExamples.add(ex);

            if (kDebugMode) {
              // debugPrint(
              //   '[FS examples<Map-IO>] $documentId -> in="${ex.input}" out="${ex.output}"',
              // );
            }
          } else {
            // b) Map ama tek bir metin taşıyor: text / value / example
            final raw =
                (e['text'] ?? e['value'] ?? e['example'] ?? '').toString();

            if (raw.trim().isNotEmpty) {
              final ex = ExampleCase.fromDisplayText(raw);
              parsedExamples.add(ex);

              // if (kDebugMode) {
              //   debugPrint(
              //     '[FS examples<Map-TEXT>] $documentId -> in="${ex.input}" out="${ex.output}"',
              //   );
              // }
            }
          }
        } else if (e is String) {
          // c) Düz string listesi
          final ex = ExampleCase.fromDisplayText(e);
          parsedExamples.add(ex);
          // if (kDebugMode) {
          //   debugPrint(
          //       '[FS examples<String>] $documentId -> in="${ex.input}" out="${ex.output}"');
          // }
        }
      }
    } else if (examplesRaw is Map<String, dynamic>) {
      // examples: { "1": "Input: ...", "2": "Input: ..." }
      for (final v in examplesRaw.values) {
        final raw = (v ?? '').toString();
        if (raw.trim().isEmpty) continue;
        final ex = ExampleCase.fromDisplayText(raw);
        parsedExamples.add(ex);
        if (kDebugMode) {
          // debugPrint(
          //     '[FS examples<Map>] $documentId -> in="${ex.input}" out="${ex.output}"');
        }
      }
    }

// 2) Legacy şema: ayrı alanlarda example1/2/3 (çeşitli adlandırmalar)
    if (parsedExamples.isEmpty) {
      final candidateKeys = <String>[
        'example1',
        'example2',
        'example3',
        'example_1',
        'example_2',
        'example_3',
        'Example 1',
        'Example 2',
        'Example 3',
        'ex1',
        'ex2',
        'ex3',
      ];

      for (final key in candidateKeys) {
        final raw = data[key];

        if (raw is String && raw.trim().isNotEmpty) {
          final ex = ExampleCase.fromDisplayText(raw);
          parsedExamples.add(ex);

          if (kDebugMode) {
            // debugPrint(
            //     '[FS $key] $documentId -> in="${ex.input}" out="${ex.output}"');
          }
        }
      }
      // 3) Son çare: "example" ile başlayan TÜM string alanları tara
      if (parsedExamples.isEmpty) {
        for (final entry in data.entries) {
          final k = entry.key.toString().toLowerCase().trim();
          if (!k.startsWith('example')) continue;

          final raw = entry.value?.toString() ?? '';
          if (raw.trim().isEmpty) continue;

          final ex = ExampleCase.fromDisplayText(raw);
          parsedExamples.add(ex);

          if (kDebugMode) {
            // debugPrint(
            //   '[FS any<$k>] $documentId -> in="${ex.input}" out="${ex.output}"',
            // );
          }
        }
      }

// 4) Hâlâ boşsa bir kere debug olarak anahtarları gösterelim
      if (kDebugMode && parsedExamples.isEmpty) {
        // debugPrint(
        //   '⚠️ No examples parsed for $documentId. keys=${data.keys.toList()}',
        // );
      }
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
      examples: parsedExamples,
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
      if (examples.isNotEmpty)
        'examples': examples.map((e) => e.toJson()).toList(),
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

    if (examples.isNotEmpty) {
      for (var i = 0; i < examples.length; i++) {
        final ex = examples[i];
        buffer.writeln(
          "Example ${i + 1} — Input: ${ex.input} | Output: ${ex.output}"
          "${ex.explanation != null ? ' | Explanation: ${ex.explanation}' : ''}",
        );
      }
    }

    return buffer.toString();
  }
}

/// 🔸 Tek örnek: Input/Output çifti
class ExampleCase {
  final String input;
  final String output;
  final String? explanation;

  const ExampleCase(
      {required this.input, required this.output, this.explanation});

  factory ExampleCase.fromJson(Map<String, dynamic> j) => ExampleCase(
        input: (j['input'] ?? '').toString(),
        output: (j['output'] ?? '').toString(),
        explanation: (j['explanation'] ?? '').toString().trim().isEmpty
            ? null
            : (j['explanation'] ?? '').toString(),
      );

  /// Excel hücresi "Input: ...\nOutput: ..." biçimindeyse buradan parse edilir.
  factory ExampleCase.fromDisplayText(String raw) {
    // Ayrıştırmayı util'e delege et
    final p = ExampleParser.parse(raw);
    return ExampleCase(
      input: p.input,
      output: p.output,
      explanation: p.explanation,
    );
  }

  Map<String, dynamic> toJson() => {
        'input': input,
        'output': output,
        if (explanation != null) 'explanation': explanation,
      };
}
