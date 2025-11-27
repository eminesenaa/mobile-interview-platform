// ===================== File: lib/pages/practice/controllers/practice_controller.dart =====================
// Purpose:
// - Practice sayfasındaki soru akışını yönetir (yükleme, filtreleme, arama, random seçim).
// - Mevcut QuestionController API'sini korur + practice'e özgü ek filtre alanları sağlar.
// =========================================================================================================

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/question.dart';
import '../../../models/training_module.dart';
import '../../../models/training_module_question_ref.dart';
import '../../../models/training_section.dart';

class PracticeController extends GetxController {
  /// Tüm sorular
  final RxList<Question> allQuestions = <Question>[].obs;

  /// Arama metni
  final RxString searchQuery = ''.obs;

  /// Seçili konu (tekli). "All" tümünü gösterir.
  final RxString selectedTopic = 'All'.obs;

  /// Seçili zorluk (tekli, null => tümü)
  final Rxn<Difficulty> selectedDifficulty = Rxn<Difficulty>();

  /// Seçili durum (null => tümü)
  final Rxn<Status> selectedStatus = Rxn<Status>();

  /// Seçili soru tipi (tekli, null => tümü)
  final Rxn<QuestionType> selectedQuestionType = Rxn<QuestionType>();

  /// Çoklu seçim filtreleri (boş => tümü).
  final RxList<String> selectedTopicsMulti = <String>[].obs;
  final RxList<Difficulty> selectedDifficultiesMulti = <Difficulty>[].obs;
  final RxList<QuestionType> selectedQuestionTypesMulti = <QuestionType>[].obs;

  /// Kullanılabilir tüm topic’ler; veri geldikçe güncellenir.
  final RxList<String> allTopics = <String>['All'].obs;

  /// Training modules shown at the top of Practice page.
  /// Şimdilik mock data ile dolduruluyor, backend geldiğinde
  /// Firestore'dan okunacak.
  final RxList<TrainingModule> trainingModules = <TrainingModule>[].obs;

  /// Bugünün sorusu (örnek: ilk TODO olan)
  Question? get todaysQuestion =>
      allQuestions.firstWhereOrNull((q) => q.status == Status.todo);

  /// Aktif filtrelere göre süzülmüş liste
  List<Question> get filteredQuestions {
    var list = allQuestions.toList();

    // ===================== TOPIC =====================
    if (selectedTopicsMulti.isNotEmpty) {
      list = list.where((q) => selectedTopicsMulti.contains(q.topic)).toList();
    } else if (selectedTopic.value.isNotEmpty && selectedTopic.value != 'All') {
      list = list.where((q) => q.topic == selectedTopic.value).toList();
    }

    // ===================== DIFFICULTY =====================
    if (selectedDifficultiesMulti.isNotEmpty) {
      list = list
          .where(
            (q) => selectedDifficultiesMulti.contains(q.difficulty),
          )
          .toList();
    } else if (selectedDifficulty.value != null) {
      list =
          list.where((q) => q.difficulty == selectedDifficulty.value).toList();
    }

    // ===================== STATUS (tek seçim) =====================
    if (selectedStatus.value != null) {
      list = list.where((q) => q.status == selectedStatus.value).toList();
    }

    // ===================== QUESTION TYPE =====================
    if (selectedQuestionTypesMulti.isNotEmpty) {
      list = list
          .where(
            (q) => selectedQuestionTypesMulti.contains(q.type),
          )
          .toList();
    } else if (selectedQuestionType.value != null) {
      list = list.where((q) => q.type == selectedQuestionType.value).toList();
    }

    // ===================== SEARCH =====================
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

  // TEMP Progress test
  final RxMap<String, double> moduleProgressById = <String, double>{}.obs;

  // ===========================
  // 🔹 INIT
  // ===========================
  @override
  void onInit() {
    super.onInit();
    _loadMockTrainingModules();
    loadQuestionsFromFirebase(); // 🔥 Uygulama açıldığında 1 defa çağırılır
    // TEMP: Fake progress map (sadece test için)
    moduleProgressById['warmup_quick_win'] = 0.45; // %45 progress testi
    moduleProgressById['daily_data_structures'] = 0.2; // %20 progress testi
  }

  // ===========================
  // Eski API (korundu)
  // ===========================
  void updateSearch(String query) => searchQuery.value = query;

  // Tek seçimli eski API – başka sayfalar hâlâ kullanıyorsa bozulmasın diye duruyor.
  void updateFilters({
    String? topic,
    Difficulty? difficulty,
    Status? status,
    QuestionType? questionType,
  }) {
    // Topic null değilse güncelle (All dahil)
    if (topic != null) {
      selectedTopic.value = topic;
    }

    selectedDifficulty.value = difficulty;
    selectedStatus.value = status;
    selectedQuestionType.value = questionType;

    // Eski API kullanıldığında çoklu listeleri sıfırla
    selectedTopicsMulti.clear();
    selectedDifficultiesMulti.clear();
    selectedQuestionTypesMulti.clear();
  }

  /// Yeni çoklu seçim API'si – FilterPopup burayı kullanacak.
  void updateFiltersMulti({
    List<String>? topics,
    List<Difficulty>? difficulties,
    List<QuestionType>? questionTypes,
    Status? status,
  }) {
    selectedTopicsMulti
      ..clear()
      ..addAll(topics ?? const []);

    selectedDifficultiesMulti
      ..clear()
      ..addAll(difficulties ?? const []);

    selectedQuestionTypesMulti
      ..clear()
      ..addAll(questionTypes ?? const []);

    selectedStatus.value = status;

    // Kısa özetler için legacy alanları da güncelle
    selectedTopic.value =
        selectedTopicsMulti.isEmpty ? 'All' : selectedTopicsMulti.first;
    selectedDifficulty.value = selectedDifficultiesMulti.isEmpty
        ? null
        : selectedDifficultiesMulti.first;
    selectedQuestionType.value = selectedQuestionTypesMulti.isEmpty
        ? null
        : selectedQuestionTypesMulti.first;
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

  void setTopic(String v) {
    selectedTopic.value = v;
    selectedTopicsMulti.clear();
  }

  void setDifficulty(Difficulty? d) {
    selectedDifficulty.value = d;
    selectedDifficultiesMulti.clear();
  }

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
      final snapshot =
          await FirebaseFirestore.instance.collection("questions").get();

      if (snapshot.docs.isEmpty) {
        print("⚠️ Firestore: Hiç soru bulunamadı.");
        setAllQuestions([]);
        return;
      }

      final items = snapshot.docs
          .map((doc) {
            try {
              return Question.fromFirestore(doc.data(), doc.id);
            } catch (err) {
              print("⚠️ Mapping hatası (docId: ${doc.id}): $err");
              return null;
            }
          })
          .whereType<Question>()
          .toList();

      setAllQuestions(items);

      print("✅ Firestore'dan ${items.length} soru yüklendi.");
    } catch (e) {
      print("🔥 Firestore load error: $e");
    }
  }

  /// TODO: Backend hazır olduğunda bu method yerine Firestore'dan
  /// gerçek training modules listesini çeken servis kullanılacak.
  void _loadMockTrainingModules() {
    trainingModules.assignAll([
      const TrainingModule(
        id: 'warmup_quick_win',
        title: 'Warm-up • Quick Win',
        subtitle: 'Solve 5 starter questions in 10 minutes.',
        description:
            'Short warm-up plan to get you into flow before diving into harder interview questions.',
        format: TrainingModuleFormat.challenge,
        totalQuestions: 5,
        estimatedMinutes: 10,
        isFeatured: true,
        sortOrder: 1,
      ),
      const TrainingModule(
        id: 'daily_data_structures',
        title: 'Daily Data Structures',
        subtitle: 'Practice arrays, stacks and queues every day.',
        description: 'Two-week crash plan focused on core data structures.',
        format: TrainingModuleFormat.crashCourse,
        totalQuestions: 14,
        estimatedMinutes: 20,
        isFeatured: true,
        sortOrder: 2,
      ),
    ]);
  }

  /// TEMP: TrainingModule detail sayfası için mock section listesi.
  /// Backend bağlanana kadar sadece front'u test etmek için kullanıyoruz.
  List<TrainingSection> buildMockSectionsFor(TrainingModule module) {
    return [
      TrainingSection(
        id: '${module.id}_sec1',
        moduleId: module.id,
        title: 'Warm-up basics',
        description: 'Get into flow with a few easy questions.',
        order: 1,
        type: TrainingSectionType.topicBased,
        // questionCount / estimatedMinutes varsa modelde, istersen doldur:
        // questionCount: 3,
        // estimatedMinutes: 5,
      ),
      TrainingSection(
        id: '${module.id}_sec2',
        moduleId: module.id,
        title: 'Level up',
        description: 'Slightly more challenging follow-up questions.',
        order: 2,
        type: TrainingSectionType.topicBased,
        // questionCount: 2,
        // estimatedMinutes: 5,
      ),
    ];
  }

  /// TEMP: Mock sections içindeki sorular için referans oluşturur.
  /// Şimdilik ilk 5 practice sorusunu kullanıyoruz.
  List<TrainingModuleQuestionRef> buildMockQuestionRefsFor(
    TrainingModule module,
    List<TrainingSection> sections,
  ) {
    if (sections.isEmpty || allQuestions.isEmpty) return [];

    final questions = allQuestions.take(5).toList();
    final refs = <TrainingModuleQuestionRef>[];

    var order = 0;
    for (var i = 0; i < questions.length; i++) {
      // İlk 3 soru 1. section, kalanlar 2. section’a
      final sectionIndex = i < 3 || sections.length == 1 ? 0 : 1;
      final section = sections[sectionIndex];

      refs.add(
        TrainingModuleQuestionRef(
          moduleId: module.id,
          sectionId: section.id,
          questionId: _questionIdFromQuestion(questions[i]),
          order: ++order,
          id: '',
          difficulty: questions[i].difficulty,
        ),
      );
    }

    return refs;
  }
}

String _questionIdFromQuestion(Question q) {
  try {
    final dynamic v = (q as dynamic).id;
    if (v != null) return v.toString();
  } catch (_) {}

  try {
    final dynamic v = (q as dynamic).docId;
    if (v != null) return v.toString();
  } catch (_) {}

  return q.title.toString();
}
