import 'package:get/get.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/exam/services/ai_duration_service.dart';
import 'package:interview_project/pages/exam/services/exam_factory.dart';

import '../../../models/exam.dart';

/// CreateExamController
/// Kullanıcının seçtiği topic/tag/difficulty/type ve soru sayısını tutar.
/// Havuzdan (şimdilik stub) distinct topic & tag çıkarır.
/// ExamFactory ile sınavı oluşturur (AI süre hesaplanır).
class CreateExamController extends GetxController {
  // Seçimler
  final topics = <String>{}.obs;
  final tags = <String>{}.obs;
  final types = <QuestionType>{}.obs;
  final difficulties = <Difficulty>{}.obs;
  final count = 10.obs;

  // Ekranda listelenecek opsiyonlar (havuzdan doldurulur)
  final availableTopics = <String>[].obs;
  final availableTags = <String>[].obs;
  final availableTypes = QuestionType.values.obs;

  late final ExamFactory factory;

  @override
  void onInit() {
    super.onInit();
    factory = ExamFactoryStub(
      AiDurationServiceStub(),
      getPool: _getPool,
    );
    _loadOptions();
  }

  // TODO: Firestore’a bağlayınca burayı değiştir.
  Future<List<Question>> _getPool() async {
    return [
      Question(
        id: 'q1',
        title: 'What is the time complexity of accessing an element in a HashMap?',
        difficulty: Difficulty.medium,
        type: QuestionType.mcq,
        topic: 'Data Structures',
        tags: ['hashmap', 'complexity'],
        options: [
          'O(1) - Constant time',
          'O(log n) - Logarithmic time',
          'O(n) - Linear time',
          'O(n log n)',
        ], description: '', status: Status.todo,
      ),
      Question(
        id: 'q2',
        title: 'Which sorting has the best average-case time complexity?',
        difficulty: Difficulty.easy,
        type: QuestionType.mcq,
        topic: 'Algorithms',
        tags: ['sorting'],
        options: ['Bubble Sort', 'Quick Sort', 'Selection Sort', 'Insertion Sort'],
        description: '', status: Status.todo,
      ),
      Question(
        id: 'q3',
        title: 'Pick the correct Big-O for binary search.',
        difficulty: Difficulty.easy_medium,
        type: QuestionType.mcq,
        topic: 'Algorithms',
        tags: ['binary-search'],
        options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
        description: '', status: Status.todo,
      ),
      Question(
        id: 'q4',
        title: 'Which DS is best for LRU cache?',
        difficulty: Difficulty.medium,
        type: QuestionType.mcq,
        topic: 'Data Structures',
        tags: ['cache', 'lru'],
        options: ['Stack + Array', 'DLL + HashMap', 'Queue only', 'BST only'],
        description: '', status: Status.todo,
      ),
    ];
  }

  Future<void> _loadOptions() async {
    final pool = await _getPool();
    final tSet = <String>{};
    final tagSet = <String>{};

    for (final q in pool) {
      if (q.topic != null && q.topic!.isNotEmpty) tSet.add(q.topic!);
      for (final tg in (q.tags ?? const <String>[])) {
        if (tg.isNotEmpty) tagSet.add(tg);
      }
    }

    availableTopics.assignAll(tSet.toList()..sort());
    availableTags.assignAll(tagSet.toList()..sort());
  }

  /// Sınavı oluşturup geri döner. (Navigasyon sheet tarafında yapılır)
  Future<Exam> buildExam() async {
    // 1) Kullanıcının seçtikleriyle dene
    Exam exam = await factory.fromFilters(CreateExamFilters(
      topics: {...topics},
      tags: {...tags},
      types: {...types},
      // çoklu zorluk seçimi varsa factory şaşırmasın: tek seçim yoksa null geç
      difficulty: difficulties.length == 1 ? difficulties.first : null,
      count: count.value,
    ));

    // 2) Boşsa filtreleri sırayla gevşet
    if (exam.questions.isEmpty) {
      // difficulty'i kaldır
      exam = await factory.fromFilters(CreateExamFilters(
        topics: {...topics},
        tags: {...tags},
        types: {...types},
        difficulty: null,
        count: count.value,
      ));
    }
    if (exam.questions.isEmpty) {
      // tags'ı kaldır
      exam = await factory.fromFilters(CreateExamFilters(
        topics: {...topics},
        tags: const {},
        types: {...types},
        difficulty: null,
        count: count.value,
      ));
    }
    if (exam.questions.isEmpty) {
      // topics'i kaldır
      exam = await factory.fromFilters(CreateExamFilters(
        topics: const {},
        tags: const {},
        types: {...types},
        difficulty: null,
        count: count.value,
      ));
    }
    if (exam.questions.isEmpty) {
      // types'ı da kaldır → tamamen rastgele
      exam = await factory.fromFilters(CreateExamFilters(
        topics: const {},
        tags: const {},
        types: const {},
        difficulty: null,
        count: count.value,
      ));
    }

    return exam;
  }

}
