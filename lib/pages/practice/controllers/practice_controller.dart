import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/question.dart';
import '../../../models/training_module.dart';
import '../../../models/training_module_question_ref.dart';
import '../../../models/training_section.dart';

class PracticeController extends GetxController {
  final RxList<Question> allQuestions = <Question>[].obs;

  final RxString searchQuery = ''.obs;

  final RxString selectedTopic = 'All'.obs;
  final Rxn<Difficulty> selectedDifficulty = Rxn<Difficulty>();
  final Rxn<Status> selectedStatus = Rxn<Status>();
  final Rxn<QuestionType> selectedQuestionType = Rxn<QuestionType>();

  final RxList<String> selectedTopicsMulti = <String>[].obs;
  final RxList<Difficulty> selectedDifficultiesMulti = <Difficulty>[].obs;
  final RxList<QuestionType> selectedQuestionTypesMulti = <QuestionType>[].obs;

  final RxList<String> allTopics = <String>['All'].obs;

  final RxList<TrainingModule> trainingModules = <TrainingModule>[].obs;

  /// Kullanıcının çözdüğü soru id’leri
  final RxSet<String> solvedQuestionIds = <String>{}.obs;

  Question? get todaysQuestion =>
      allQuestions.firstWhereOrNull((q) {
        final id = _questionIdFromQuestion(q);
        return !solvedQuestionIds.contains(id);
      });

  // =========================
  // FILTERED QUESTIONS
  // =========================
  List<Question> get filteredQuestions {
    var list = allQuestions.toList();

    // TOPIC
    if (selectedTopicsMulti.isNotEmpty) {
      list = list.where((q) => selectedTopicsMulti.contains(q.topic)).toList();
    } else if (selectedTopic.value != 'All') {
      list = list.where((q) => q.topic == selectedTopic.value).toList();
    }

    // DIFFICULTY
    if (selectedDifficultiesMulti.isNotEmpty) {
      list = list
          .where((q) => selectedDifficultiesMulti.contains(q.difficulty))
          .toList();
    } else if (selectedDifficulty.value != null) {
      list = list.where((q) => q.difficulty == selectedDifficulty.value).toList();
    }

    // STATUS (user-based)
    if (selectedStatus.value != null) {
      if (selectedStatus.value == Status.solved) {
        list = list.where((q) {
          final qId = _questionIdFromQuestion(q);
          return solvedQuestionIds.contains(qId);
        }).toList();
      } else if (selectedStatus.value == Status.todo) {
        list = list.where((q) {
          final qId = _questionIdFromQuestion(q);
          return !solvedQuestionIds.contains(qId);
        }).toList();
      }
    }

    // QUESTION TYPE
    if (selectedQuestionTypesMulti.isNotEmpty) {
      list = list
          .where((q) => selectedQuestionTypesMulti.contains(q.type))
          .toList();
    } else if (selectedQuestionType.value != null) {
      list = list.where((q) => q.type == selectedQuestionType.value).toList();
    }

    // SEARCH
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((it) {
        final haystack =
            '${it.title} ${it.description ?? ''} ${it.topic} ${it.tags.join(" ")}'
                .toLowerCase();
        return haystack.contains(query);
      }).toList();
    }

    return list;
  }

  // progress map (mock)
  final RxMap<String, double> moduleProgressById = <String, double>{}.obs;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();
    _loadMockTrainingModules();
    loadQuestionsFromFirebase();
    loadSolvedQuestionsForUser();

    moduleProgressById['warmup_quick_win'] = 0.45;
    moduleProgressById['daily_data_structures'] = 0.2;
  }

  // =========================
  // FILTER SETTERS
  // =========================
  void updateSearch(String query) => searchQuery.value = query;

  Future<void> refreshSolved() async {
    await loadSolvedQuestionsForUser();
  }

  Future<void> updateFilters({
    String? topic,
    Difficulty? difficulty,
    Status? status,
    QuestionType? questionType,
  }) async {
    if (topic != null) selectedTopic.value = topic;
    selectedDifficulty.value = difficulty;
    selectedStatus.value = status;
    selectedQuestionType.value = questionType;

    selectedTopicsMulti.clear();
    selectedDifficultiesMulti.clear();
    selectedQuestionTypesMulti.clear();

    await refreshSolved();
  }

  Future<void> updateFiltersMulti({
    List<String>? topics,
    List<Difficulty>? difficulties,
    List<QuestionType>? questionTypes,
    Status? status,
  }) async {
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

    selectedTopic.value =
        selectedTopicsMulti.isEmpty ? 'All' : selectedTopicsMulti.first;
    selectedDifficulty.value =
        selectedDifficultiesMulti.isEmpty ? null : selectedDifficultiesMulti.first;
    selectedQuestionType.value =
        selectedQuestionTypesMulti.isEmpty ? null : selectedQuestionTypesMulti.first;

    await refreshSolved();
  }

  Question? getRandomQuestion() {
    final list = filteredQuestions;
    if (list.isEmpty) return null;
    list.shuffle();
    return list.first;
  }

  void setAllQuestions(List<Question> items) {
    allQuestions.assignAll(items);
    final topics = <String>{'All', ...items.map((e) => e.topic)};
    allTopics.assignAll(topics.toList()..sort());
  }

  // =========================
  // FIREBASE
  // =========================
  Future<void> loadSolvedQuestionsForUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('solved')
          .get();

      solvedQuestionIds
        ..clear()
        ..addAll(snapshot.docs.map((d) => d.id));
    } catch (e) {
      print('🔥 Error loading solved: $e');
    }
  }

  Future<void> loadQuestionsFromFirebase() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("questions").get();

      final items = snapshot.docs
          .map((doc) {
            try {
              return Question.fromFirestore(doc.data(), doc.id);
            } catch (_) {
              return null;
            }
          })
          .whereType<Question>()
          .toList();

      setAllQuestions(items);
    } catch (e) {
      print("🔥 Firestore load error: $e");
    }
  }

  // =========================
  // MOCK TRAINING MODULES
  // =========================
  void _loadMockTrainingModules() {
    trainingModules.assignAll([
      const TrainingModule(
        id: 'warmup_quick_win',
        title: 'Warm-up • Quick Win',
        subtitle: 'Solve 5 starter questions.',
        description: 'Short warm-up before real practice.',
        format: TrainingModuleFormat.challenge,
        totalQuestions: 5,
        estimatedMinutes: 10,
        isFeatured: true,
        sortOrder: 1,
      ),
      const TrainingModule(
        id: 'daily_data_structures',
        title: 'Daily Data Structures',
        subtitle: 'Arrays, stacks, queues.',
        description: 'Daily structured practice.',
        format: TrainingModuleFormat.crashCourse,
        totalQuestions: 14,
        estimatedMinutes: 20,
        isFeatured: true,
        sortOrder: 2,
      ),
    ]);
  }

  // =========================
  // MOCK DETAIL BUILDERS
  // =========================
  List<TrainingSection> buildMockSectionsFor(TrainingModule module) {
    return [
      TrainingSection(
        id: '${module.id}_sec1',
        moduleId: module.id,
        title: 'Warm-up basics',
        description: 'Easy starter questions.',
        order: 1,
        type: TrainingSectionType.topicBased,
      ),
      TrainingSection(
        id: '${module.id}_sec2',
        moduleId: module.id,
        title: 'Level up',
        description: 'More challenging questions.',
        order: 2,
        type: TrainingSectionType.topicBased,
      ),
    ];
  }

  List<TrainingModuleQuestionRef> buildMockQuestionRefsFor(
    TrainingModule module,
    List<TrainingSection> sections,
  ) {
    if (sections.isEmpty || allQuestions.isEmpty) return [];

    final refs = <TrainingModuleQuestionRef>[];
    final questions = allQuestions.take(5).toList();

    var order = 0;
    for (var i = 0; i < questions.length; i++) {
      final section = sections[i < 3 ? 0 : 1];

      refs.add(
        TrainingModuleQuestionRef(
          id: '',
          moduleId: module.id,
          sectionId: section.id,
          questionId: _questionIdFromQuestion(questions[i]),
          order: ++order,
          difficulty: questions[i].difficulty,
        ),
      );
    }

    return refs;
  }
}

// =========================
// HELPERS
// =========================
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
