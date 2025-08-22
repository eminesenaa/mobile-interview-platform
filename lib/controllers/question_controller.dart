/// ============================================================================
/// QuestionController (GLOBAL)
/// ----------------------------------------------------------------------------
/// Amaç:
/// - Uygulama genelinde (Home, Practice, Exam, Progress vb.) ortak soru havuzunu
///   yönetmek. Erişim tek bir yerden olsun ve tekrar eden kod olmasın.
///
/// Veri Kaynağı:
/// - İlk sürümde lokal/Mock veri seti kullanılabilir.
/// - Üretimde Firebase (Cloud Firestore veya Realtime DB) üzerinden okunacak.
///   Aşağıdaki `fetchFromFirebase()` bu iş için ayrılmıştır; içi bilerek boştur.
///   Yorumlarda nasıl entegre edileceğine dair kısa yönergeler mevcut.
///
/// Kullanım:
/// - `Get.put(QuestionController())` ile uygulama açılışında oluşturup,
///   sayfalarda `Get.find<QuestionController>()` ile erişebilirsin.
/// - `setQuestions(mockList)` ile geçici veri basıp geliştirme yapabilirsin.
///
/// Not:
/// - Model sınıfının adları/propları projendeki `Question` tanımıyla uyumlu
///   olacak şekilde kullanıldı. Gerekirse küçük isim düzeltmeleri yapabilirsin.
/// ============================================================================

import 'dart:math';
import 'package:get/get.dart';
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
    loadDummyQuestions(); // DEV: mock veri
    // PROD: fetchFromFirebase();
    // Üretimde: uygulama başlarken Firebase'den çekmek için açarsın.
    // fetchFromFirebase();
  }

  /// ----------------------------------------------------------------------------
  /// Firebase'den verileri çek (PLACEHOLDER)
  /// ----------------------------------------------------------------------------
  Future<void> fetchFromFirebase() async {
    /*
    // Örnek Firestore entegrasyonu (yorum, içi bilerek boş):
    // import 'package:cloud_firestore/cloud_firestore.dart';

    try {
      isLoading.value = true;
      error.value = '';

      final snap = await FirebaseFirestore.instance
          .collection('questions')
          .get();

      final items = snap.docs.map((d) {
        final data = d.data();
        // Question.fromJson / fromMap senin modeline göre
        return Question.fromJson({
          'id': d.id,
          ...data,
        });
      }).toList();

      allQuestions.assignAll(items);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
    */
  }

  /// ----------------------------------------------------------------------------
  /// Dummy / Mock veri yükle (statik)
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
      ),
      Question(
        id: 'code1',
        title: 'Write a function to reverse a linked list.',
        topic: 'Data Structures',
        description: "Hard level data structure question.",
        difficulty: Difficulty.hard,
        status: Status.todo,
        tags: ['linked list'],
        type: QuestionType.coding,
      ),
      Question(
        id: 'short2',
        title: 'What is the time complexity of binary search?',
        topic: 'Algorithms',
        description: 'Classic question on search algorithms.',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: ['binary search', 'time complexity'],
        type: QuestionType.shortAnswer,
        correctAnswer: 'O(log n)',
      ),
      Question(
        id: 'fib_single_1',
        title: 'Fill the blank',
        description: 'Flutter is a ***.',
        topic: 'Flutter',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: ['flutter', 'basics'],
        type: QuestionType.fillBlank,
        correctAnswer: 'framework',
        options: ['language', 'sdk', 'framework', 'package', 'library'],
      ),
    ]);
  }
  /// Geliştirme sırasında veya testte dışarıdan set edebilmek için
  void setQuestions(List<Question> questions) {
    allQuestions.assignAll(questions);
  }

  /// Filtre yardımcıları
  List<Question> byDifficulty(Difficulty d) =>
      allQuestions.where((q) => q.difficulty == d).toList();

  List<Question> byTopic(String topic) =>
      allQuestions.where((q) => (q.topic ?? '').toLowerCase() == topic.toLowerCase()).toList();

  List<Question> search(String term) {
    final t = term.trim().toLowerCase();
    return allQuestions.where((q) {
      final title = (q.title).toLowerCase();
      final topic = (q.topic ?? '').toLowerCase();
      final tags  = (q.tags ?? <String>[]).map((e) => e.toLowerCase()).join(' ');
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

    // aynı soru iki kez seçilmesin diye benzersizleştir
    final seen = <String>{};
    final unique = <Question>[];
    for (final q in picks) {
      final key = q.id?.toString() ?? q.title; // modeline göre id alanını kullan
      if (seen.add(key)) unique.add(q);
    }
    return unique;
  }

  /// Basit istatistikler (Progress için işine yarayabilir)
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
