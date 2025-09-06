/// ExamFactory
/// -------------
/// Bu dosya, kullanıcı "Random Exam" veya "Create Your Exam" seçtiğinde
/// sınavı oluşturmak için kullanılır. Soruları (Firebase'den/yerel havuzdan)
/// alır, filtreleri uygular, soruları rastgele seçer ve AI servisinden gelen
/// tahmini süre ile `Exam` nesnesini döndürür.
///
/// Notlar:
/// - Burada **demo soru üretmiyoruz**. Soru havuzunu dışarıdan sağlayan bir
///   provider fonksiyon (getPool) enjekte edilir. Böylece gerçek Firestore
///   entegrasyonuna kolayca geçilir.
/// - Question modelindeki alanlar nullable olduğu için filtreler **null-safe**
///   şekilde uygulanır.

import 'dart:math';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/exam/services/ai_duration_service.dart';

class CreateExamFilters {
  final Set<String> topics;            // örn: {'Java','Network'}
  final Set<String> tags;              // örn: {'array','oop'}
  final Set<QuestionType> types;       // örn: {QuestionType.mcq}
  final Difficulty? difficulty;        // null => hepsi
  final int count;                     // istenen soru sayısı

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

class ExamFactoryStub implements ExamFactory {
  /// Soru havuzunu sağlayan fonksiyon.
  /// Firebase'e geçtiğinde burayı Firestore query ile değiştir.
  final Future<List<Question>> Function() getPool;

  final AiDurationService ai;

  ExamFactoryStub(
      this.ai, {
        Future<List<Question>> Function()? getPool,
      }) : getPool = getPool ?? (() async => <Question>[]);

  // ---------- helpers ----------

  List<Question> _applyFilters(List<Question> pool, CreateExamFilters f) {
    return pool.where((q) {
      // topic
      final okTopic = f.topics.isEmpty ||
          (q.topic != null && f.topics.contains(q.topic));

      // types
      final okType = f.types.isEmpty ||
          (q.type != null && f.types.contains(q.type!));

      // difficulty
      final okDiff = f.difficulty == null ||
          (q.difficulty != null && q.difficulty == f.difficulty);

      // tags (model List<String>? ise null-safe)
      final tags = q.tags ?? const <String>[];
      final okTags = f.tags.isEmpty || tags.any(f.tags.contains);

      return okTopic && okType && okDiff && okTags;
    }).toList();
  }

  List<Question> _takeRandom(List<Question> list, int n) {
    if (list.length <= n) return List<Question>.from(list);
    final rnd = Random();
    final copy = List<Question>.from(list);
    copy.shuffle(rnd);
    return copy.take(n).toList();
  }

  // ---------- interface ----------

  @override
  Future<Exam> fromRandom({int count = 10}) async {
    final pool = await getPool();                 // tüm sorular
    final picked = _takeRandom(pool, count);      // rastgele seç
    final duration = await ai.estimateFor(picked);
    return Exam(
      id: 'rnd_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Random Exam',
      duration: duration,
      questions: picked,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Exam> fromFilters(CreateExamFilters f) async {
    final pool = await getPool();
    final filtered = _applyFilters(pool, f);

    // Yeterli soru yoksa mevcut kadarını veriyoruz (UI’da uyarı gösterilebilir)
    final picked = _takeRandom(filtered, f.count);

    final duration = await ai.estimateFor(picked);
    return Exam(
      id: 'flt_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Custom Exam',
      duration: duration,
      questions: picked,
      createdAt: DateTime.now(),
    );
  }
}
