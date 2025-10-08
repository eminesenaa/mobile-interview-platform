import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/exam/services/ai_duration_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateExamFilters {
  final Set<String> topics;
  final Set<String> tags;
  final Set<QuestionType> types;
  final Difficulty? difficulty;
  final int count;

  const CreateExamFilters({
    this.topics = const {},
    this.tags = const {},
    this.types = const {},
    this.difficulty,
    this.count = 10,
  });
}

abstract class ExamFactory {
  Future<Exam> fromRandom({int count = 10});
  Future<Exam> fromFilters(CreateExamFilters f);
}

class ExamFactoryFirebase implements ExamFactory {
  final AiDurationService ai;

  ExamFactoryFirebase(this.ai);

  Future<List<Question>> _fetchAllQuestions() async {
    final db = FirebaseFirestore.instance;
    final snap = await db.collection('questions').get();
    return snap.docs.map((d) => Question.fromFirestore(d.data(), d.id)).toList();
  }

  List<Question> _takeRandom(List<Question> list, int n) {
    if (list.length <= n) return List<Question>.from(list);
    final rnd = Random();
    final copy = List<Question>.from(list);
    copy.shuffle(rnd);
    return copy.take(n).toList();
  }

  @override
  Future<Exam> fromRandom({int count = 10}) async {
    debugPrint('\n==================== 🎲 RANDOM EXAM DEBUG START ====================');

    final pool = await _fetchAllQuestions();
    debugPrint('📚 Pulled total questions from Firestore: ${pool.length}');

    if (pool.isEmpty) {
      throw Exception("No questions found in Firestore");
    }

    // 🔹 Tüm havuz sorularını logla
    // for (final q in pool) {
    //   debugPrint(
    //     '   🟦 [POOL] ID: ${q.id} | Topic: ${q.topic} | '
    //     'Type: ${q.type.name} | Diff: ${q.difficulty.name} | '
    //     'Tags: ${q.tags.isEmpty ? "—" : q.tags.join(", ")}',
    //   );
    // }

    // 🔹 Rastgele seç
    final selected = _takeRandom(pool, count);

    debugPrint('');
    debugPrint('🎯 Selected random ${selected.length} questions:');
    for (int i = 0; i < selected.length; i++) {
      final q = selected[i];
      debugPrint(
        '➡️ Q${i + 1} | ID: ${q.id} | Topic: ${q.topic} | '
        'Type: ${q.type.name} | Diff: ${q.difficulty.name} | '
        'Tags: ${q.tags.isEmpty ? "—" : q.tags.join(", ")}',
      );
    }
    debugPrint('=============================================================\n');

    const Duration estimatedDuration = Duration(seconds: 300);

    return Exam(
      id: 'rnd_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Random Exam',
      duration: estimatedDuration,
      questions: selected,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Exam> fromFilters(CreateExamFilters f) async {
    final pool = await _fetchAllQuestions();
    final filtered = pool.where((q) {
      final okTopic = f.topics.isEmpty || f.topics.contains(q.topic);
      final okType = f.types.isEmpty || f.types.contains(q.type);
      final okDiff = f.difficulty == null || q.difficulty == f.difficulty;
      final okTags = f.tags.isEmpty || q.tags.any(f.tags.contains);
      return okTopic && okType && okDiff && okTags;
    }).toList();

    final selected = _takeRandom(filtered, f.count);
    const Duration estimatedDuration = Duration(seconds: 300);

    return Exam(
      id: 'flt_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Filtered Exam',
      duration: estimatedDuration,
      questions: selected,
      createdAt: DateTime.now(),
    );
  }
}
