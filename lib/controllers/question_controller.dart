/// ============================================================================
/// QuestionController (GLOBAL)
/// ----------------------------------------------------------------------------
/// Amaç:
/// - Uygulama genelinde (Home, Practice, Exam, Progress vb.) ortak soru havuzunu
///   yönetmek. Erişim tek bir yerden olsun ve tekrar eden kod olmasın.
/// ============================================================================
import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';

class QuestionController extends GetxController {
  /// Tüm soru havuzu (global)
  final RxList<Question> allQuestions = <Question>[].obs;

  /// Basit durum yönetimi
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFromFirebase();   // 🔹 Artık uygulama açıldığında Firestore’dan çekiyor
  }

  /// ----------------------------------------------------------------------------
  /// Firebase'den verileri çek
  /// ----------------------------------------------------------------------------
  Future<void> fetchFromFirebase() async {
    try {
      isLoading.value = true;
      error.value = '';

      final snap = await FirebaseFirestore.instance
          .collection('questions')
          .get();

      final items = snap.docs.map((d) {
        final data = d.data();
        return Question.fromFirestore(data, d.id);
      }).toList();

      allQuestions.assignAll(items);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------------------------------
  /// Dummy / Mock veri (geliştirme amaçlı)
  /// ----------------------------------------------------------------------------
  void loadDummyQuestions() {
    allQuestions.clear();
    allQuestions.addAll([
      Question(
        id: 'mcq1',
        title: 'What is Flutter?',
        topic: 'Mobile Development',
        description: "Easy level flutter question.",
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: ['flutter', 'framework'],
        type: QuestionType.mcq,
        options: ['Framework', 'IDE', 'Database', 'Language'],
        correctAnswer: 'Framework',
        aiPromptHelper: "Explain why Flutter is categorized as a framework.",
      ),
      Question(
        id: 'short1',
        title: 'Explain the use of "final" in Dart.',
        topic: 'Dart',
        description: "Medium level Dart question.",
        difficulty: Difficulty.medium,
        status: Status.todo,
        tags: ['variables', 'final'],
        type: QuestionType.shortAnswer,
        aiPromptHelper: "Clarify immutability in Dart using 'final'.",
      ),
    ]);
  }

  /// Geliştirme sırasında dışarıdan set edebilmek için
  void setQuestions(List<Question> questions) {
    allQuestions.assignAll(questions);
  }

  /// Filtre yardımcıları
  List<Question> byDifficulty(Difficulty d) =>
      allQuestions.where((q) => q.difficulty == d).toList();

  List<Question> byTopic(String topic) =>
      allQuestions.where((q) => q.topic.toLowerCase() == topic.toLowerCase()).toList();

  List<Question> search(String term) {
    final t = term.trim().toLowerCase();
    return allQuestions.where((q) {
      final title = q.title.toLowerCase();
      final topic = q.topic.toLowerCase();
      final tags = q.tags.map((e) => e.toLowerCase()).join(' ');
      return title.contains(t) || topic.contains(t) || tags.contains(t);
    }).toList();
  }

  /// Rastgele seçim (zorluğa göre)
  Question? randomByDifficulty(Difficulty d) {
    final pool = byDifficulty(d);
    if (pool.isEmpty) return null;
    return pool[Random().nextInt(pool.length)];
  }

  /// Home sayfasında göstermek için: Easy/Medium/Hard 3 adet rastgele
  List<Question> todaysPopular() {
    final picks = <Question?>[
      randomByDifficulty(Difficulty.easy),
      randomByDifficulty(Difficulty.medium),
      randomByDifficulty(Difficulty.hard),
    ].whereType<Question>().toList();

    final seen = <String>{};
    final unique = <Question>[];
    for (final q in picks) {
      final key = q.id;
      if (seen.add(key)) unique.add(q);
    }
    return unique;
  }

  /// Basit istatistikler
  int get totalCount => allQuestions.length;

  Map<Difficulty, int> countByDifficulty() {
    final map = <Difficulty, int>{
      Difficulty.easy: 0,
      Difficulty.easy_medium: 0,
      Difficulty.medium: 0,
      Difficulty.medium_hard: 0,
      Difficulty.hard: 0,
    };
    for (final q in allQuestions) {
      map[q.difficulty] = (map[q.difficulty] ?? 0) + 1;
    }
    return map;
  }
}
