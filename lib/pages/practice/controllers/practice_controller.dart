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

  /// Kullanılabilir tüm topic’ler; veri geldikçe güncellenir.
  final RxList<String> allTopics = <String>['All'].obs;

  /// Bugünün sorusu (örnek: ilk TODO olan)
  Question? get todaysQuestion =>
      allQuestions.firstWhereOrNull((q) => q.status == Status.todo);

  /// Aktif filtrelere göre süzülmüş liste
  List<Question> get filteredQuestions {
    var list = allQuestions.toList();

    // Topic filtresi
    if (selectedTopic.value.isNotEmpty && selectedTopic.value != 'All') {
      list = list.where((q) => q.topic == selectedTopic.value).toList();
    }

    // Difficulty filtresi
    if (selectedDifficulty.value != null) {
      list = list.where((q) => q.difficulty == selectedDifficulty.value).toList();
    }

    // Status filtresi
    if (selectedStatus.value != null) {
      list = list.where((q) => q.status == selectedStatus.value).toList();
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
  // 🔹 INIT
  // ===========================
  @override
  void onInit() {
    super.onInit();
    loadQuestionsFromFirebase();   // 🔥 Uygulama açıldığında 1 defa çağırılır
  }
  // ===========================
  // Eski API (korundu)
  // ===========================
  void updateSearch(String query) => searchQuery.value = query;

  void updateFilters({String? topic, Difficulty? difficulty, Status? status}) {
    if (topic != null) selectedTopic.value = topic;
    if (difficulty != null) selectedDifficulty.value = difficulty;
    if (status != null) selectedStatus.value = status;
  }

  Question? getRandomQuestion() {
    final list = filteredQuestions;
    if (list.isEmpty) return null;
    list.shuffle();
    return list.first;
  }

  void loadDummyQuestions() {
    // Demo amaçlı örnekler. Firestore’dan yükleme için loadQuestionsFromFirebase kullanılacak.
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
    ]);
  }

  // ===========================
  // Yeni yardımcı setter’lar
  // ===========================
  void setSearchText(String v) => searchQuery.value = v;
  void setTopic(String v) => selectedTopic.value = v;
  void setDifficulty(Difficulty? d) => selectedDifficulty.value = d;
  void setStatus(Status? s) => selectedStatus.value = s;

  void setAllQuestions(List<Question> items) {
    allQuestions.assignAll(items);
    final topics = <String>{'All', ...items.map((e) => e.topic)};
    allTopics.assignAll(topics.toList()..sort());
  }

  void addQuestion(Question q) {
    allQuestions.add(q);
    if (!allTopics.contains(q.topic)) {
      allTopics.add(q.topic);
      allTopics.sort();
    }
  }

  void removeQuestionById(String id) {
    allQuestions.removeWhere((e) => e.id == id);
  }

  void onAddQuestion() {
    // TODO: yeni soru ekleme akışını bağla
  }

  void onRandomQuestion() {
    // TODO: rastgele soruya yönlendirme
  }

  // ===========================
  // 🔹 FIREBASE ENTEGRASYONU
  // ===========================
  Future<void> loadQuestionsFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("questions")
          .get();

      if (snapshot.docs.isEmpty) {
        print("⚠️ Firestore: Hiç soru bulunamadı.");
        setAllQuestions([]);
        return;
      }

      final items = snapshot.docs.map((doc) {
        try {
          return Question.fromFirestore(doc.data(), doc.id);
        } catch (err) {
          print("⚠️ Mapping hatası (docId: ${doc.id}): $err");
          return null;
        }
      }).whereType<Question>().toList();

      setAllQuestions(items);

      print("✅ Firestore'dan ${items.length} soru yüklendi.");
    } catch (e) {
      print("🔥 Firestore load error: $e");
    }
  }
}
