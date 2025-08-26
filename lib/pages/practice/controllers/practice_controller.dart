// ===================== File: lib/pages/practice/controllers/practice_controller.dart =====================
// Purpose:
// - Practice sayfasındaki soru akışını yönetir (yükleme, filtreleme, arama, random seçim).
// - Mevcut QuestionController API'sini korur + practice'e özgü ek filtre alanları sağlar.
// =========================================================================================================

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/question.dart';

class PracticeController extends GetxController {
  /// Tüm sorular
  final RxList<Question> allQuestions = <Question>[].obs;
  /// Arama metni
  final RxString searchQuery = ''.obs;

  /// Seçili konu (topic). "All" tümünü gösterir.
  final RxString selectedTopic = 'All'.obs;

  /// Seçili zorluk (null => tümü)
  final Rxn<Difficulty> selectedDifficulty = Rxn<Difficulty>();

  /// Seçili durum (null => tümü)
  final Rxn<Status> selectedStatus = Rxn<Status>();

  /// (İstersen) kullanılabilir tüm topic’ler; veri geldikçe güncelleyebilirsin.
  final RxList<String> allTopics = <String>['All'].obs;

  /// Bugünün sorusu (örnek: ilk TODO olan)
  Question? get todaysQuestion =>
      allQuestions.firstWhereOrNull((q) => q.status == Status.todo);

  /// Aktif filtrelere göre süzülmüş liste
  List<Question> get filteredQuestions {
    var list = allQuestions.toList();

    // Topic filtresi
    final topic = selectedTopic.value;
    if (topic.isNotEmpty && topic != 'All') {
      list = list.where((q) => q.topic == topic).toList();
    }

    // Difficulty filtresi
    final diff = selectedDifficulty.value;
    if (diff != null) {
      list = list.where((q) => q.difficulty == diff).toList();
    }

    // Status filtresi
    final st = selectedStatus.value;
    if (st != null) {
      list = list.where((q) => q.status == st).toList();
    }

    // Arama
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((it) {
        final haystack = '${it.title} ${it.description ?? ''} '
            '${it.topic} ${it.tags.join(" ")}'
            .toLowerCase();
        return haystack.contains(q);
      }).toList();
    }

    return list;
  }

  // ===========================
  // Eski API (korundu)
  // ===========================
  /// (Önceden var olan) arama metnini güncelle
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void updateFilters({String? topic, Difficulty? difficulty, Status? status}) {
    if (topic != null) selectedTopic.value = topic;
    if (difficulty != null) selectedDifficulty.value = difficulty;
    if (status != null) selectedStatus.value = status;
  }

  /// (Önceden var olan) filtrelenmiş listeden rastgele bir soru
  Question? getRandomQuestion() {
    final list = filteredQuestions;
    if (list.isEmpty) return null;
    list.shuffle();
    return list.first;
  }

  /// Soru listesini yükler (ör: mock data veya API çağrısı)
  void loadDummyQuestions() {
    // TODO: Burayı backend API’den veri çekme ile değiştirebilirsin.
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
        description: 'Flutter is a ***.', // Excel/Firebase’den bu şekilde gelecek
        topic: 'Flutter',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: ['flutter', 'basics'],
        type: QuestionType.fillBlank,     // switch’te FillInBlankPage’e yönlendir
        correctAnswer: 'framework',       // doğru cevap
        options: ['language', 'sdk', 'framework', 'package', 'library'],
      ),
    ]);
  }

  // ===========================
  // Yeni yardımcı setter’lar (practice spesifik)
  // ===========================
  void setSearchText(String v) => searchQuery.value = v;

  void setTopic(String v) => selectedTopic.value = v;

  void setDifficulty(Difficulty? d) => selectedDifficulty.value = d;

  void setStatus(Status? s) => selectedStatus.value = s;

  /// Dışarıdan (Firebase/Excel) full liste çektiğinde çağır.
  /// Topics listesini de otomatik günceller.
  void setAllQuestions(List<Question> items) {
    allQuestions.assignAll(items);
    final topics = <String>{'All', ...items.map((e) => e.topic)};
    allTopics.assignAll(topics.toList()..sort());
  }

  /// Tek bir soru eklemek istersen
  void addQuestion(Question q) {
    allQuestions.add(q);
    if (!allTopics.contains(q.topic)) {
      allTopics.add(q.topic);
      allTopics.sort();
    }
  }

  /// ID ile soru silme (opsiyonel)
  void removeQuestionById(String id) {
    allQuestions.removeWhere((e) => e.id == id);
  }

  /// Basit örnek aksiyonlar (SearchAddBar butonları için)
  void onAddQuestion() {
    // TODO: yeni soru ekleme akışını bağla (sheet/dialog)
  }

  void onRandomQuestion() {
    // TODO: rastgele soruya yönlendirme (UI tarafında getRandomQuestion() sonucu ile)
  }

  // ===========================
  // 🔹 FIREBASE ENTEGRASYONU
  // ===========================
  Future<void> loadQuestionsFromFirebase() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("questions").get();

      final items = snapshot.docs.map((doc) {
        return Question.fromFirestore(doc.data(), doc.id);
      }).toList();

      setAllQuestions(items);
    } catch (e) {
      print("🔥 Firestore load error: $e");
    }
  }
}
