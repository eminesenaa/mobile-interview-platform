import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/question.dart';
import '../../../models/training_module.dart';
import '../../../models/training_section.dart';
import '../../../models/training_module_question_ref.dart';

class PracticeController extends GetxController {
  // =========================
  // QUESTION POOL
  // =========================
  final RxList<Question> allQuestions = <Question>[].obs;

  // =========================
  // TRAINING STRUCTURE
  // =========================
  final RxList<TrainingModule> trainingModules = <TrainingModule>[].obs;
  final RxMap<String, List<TrainingSection>> sectionsByModule =
      <String, List<TrainingSection>>{}.obs;
  final RxMap<String, List<TrainingModuleQuestionRef>> refsByModule =
      <String, List<TrainingModuleQuestionRef>>{}.obs;

  // =========================
  // PRACTICE FILTER STATE
  // =========================
  final RxString searchQuery = ''.obs;
  final RxString selectedTopic = 'All'.obs;
  final Rxn<Difficulty> selectedDifficulty = Rxn<Difficulty>();
  final Rxn<Status> selectedStatus = Rxn<Status>();
  final Rxn<QuestionType> selectedQuestionType = Rxn<QuestionType>();

  final RxList<String> selectedTopicsMulti = <String>[].obs;
  final RxList<Difficulty> selectedDifficultiesMulti = <Difficulty>[].obs;
  final RxList<QuestionType> selectedQuestionTypesMulti = <QuestionType>[].obs;

  final RxList<String> allTopics = <String>['All'].obs;

  // =========================
  // SHUFFLE
  // =========================
  final RxBool shuffleEnabled = true.obs;
  final RxInt shuffleSeed = DateTime.now().millisecondsSinceEpoch.obs;

  // =========================
  // USER STATE
  // =========================
  final RxSet<String> solvedQuestionIds = <String>{}.obs;

  // =========================
  // UI COMPAT (PROGRESS PLACEHOLDER)
  // =========================
  final RxMap<String, double> moduleProgressById = <String, double>{}.obs;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();
    loadQuestionsFromFirebase();
    loadTrainingModulesFromFirestore();
    loadSolvedQuestionsForUser();
  }

  // =========================
  // FILTERED QUESTIONS
  // =========================
  List<Question> get filteredQuestions {
    var list = allQuestions.toList();

    if (selectedTopicsMulti.isNotEmpty) {
      list = list.where((q) => selectedTopicsMulti.contains(q.topic)).toList();
    } else if (selectedTopic.value != 'All') {
      list = list.where((q) => q.topic == selectedTopic.value).toList();
    }

    if (selectedDifficultiesMulti.isNotEmpty) {
      list = list
          .where((q) => selectedDifficultiesMulti.contains(q.difficulty))
          .toList();
    } else if (selectedDifficulty.value != null) {
      list =
          list.where((q) => q.difficulty == selectedDifficulty.value).toList();
    }

    if (selectedStatus.value != null) {
      list = list.where((q) {
        final id = _questionIdFromQuestion(q);
        return selectedStatus.value == Status.solved
            ? solvedQuestionIds.contains(id)
            : !solvedQuestionIds.contains(id);
      }).toList();
    }

    if (selectedQuestionTypesMulti.isNotEmpty) {
      list = list
          .where((q) => selectedQuestionTypesMulti.contains(q.type))
          .toList();
    } else if (selectedQuestionType.value != null) {
      list = list.where((q) => q.type == selectedQuestionType.value).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((q) {
        final haystack =
            '${q.title} ${q.description ?? ''} ${q.topic} ${q.tags.join(" ")}'
                .toLowerCase();
        return haystack.contains(query);
      }).toList();
    }

    if (shuffleEnabled.value) {
      list.shuffle(Random(shuffleSeed.value));
    }

    return list;
  }

  // =========================
  // FILTER API (UI UYUMLU)
  // =========================
  void updateSearch(String query) => searchQuery.value = query;

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
  }

  Future<void> updateFiltersMulti({
    List<String>? topics,
    List<Difficulty>? difficulties,
    List<QuestionType>? questionTypes,
    Status? status,
  }) async {
    selectedTopicsMulti
      ..clear()
      ..addAll(topics ?? []);
    selectedDifficultiesMulti
      ..clear()
      ..addAll(difficulties ?? []);
    selectedQuestionTypesMulti
      ..clear()
      ..addAll(questionTypes ?? []);

    selectedStatus.value = status;
  }

  Question? getRandomQuestion() {
    final list = filteredQuestions;
    if (list.isEmpty) return null;
    return list.first;
  }

  // =========================
  // FIREBASE LOADERS
  // =========================
  Future<void> loadQuestionsFromFirebase() async {
    final snap = await FirebaseFirestore.instance.collection('questions').get();
    final items =
        snap.docs.map((d) => Question.fromFirestore(d.data(), d.id)).toList();
    allQuestions.assignAll(items);

    final topics = <String>{'All', ...items.map((e) => e.topic)};
    allTopics.assignAll(topics.toList()..sort());
  }

  Future<void> loadTrainingModulesFromFirestore() async {
    final db = FirebaseFirestore.instance;

    final moduleSnap =
        await db.collection('modules').orderBy('sortOrder').get();
    final modules = moduleSnap.docs
        .map((d) => TrainingModule.fromFirestore(d.data(), d.id))
        .toList();
    trainingModules.assignAll(modules);

    final snap = await db.collection('modules').get();
    print('🔥 MODULE COUNT: ${snap.docs.length}');

    for (final module in modules) {
      final sectionSnap = await db
          .collection('modules')
          .doc(module.id)
          .collection('sections')
          .orderBy('order')
          .get();

      final sections = sectionSnap.docs
          .map((d) => TrainingSection.fromFirestore(d.data(), d.id))
          .toList();

      sectionsByModule[module.id] = sections;

      final List<TrainingModuleQuestionRef> allRefs = [];

      for (final section in sections) {
        final refSnap = await db
            .collection('modules')
            .doc(module.id)
            .collection('sections')
            .doc(section.id)
            .collection('questions')
            .orderBy('order')
            .get();

        allRefs.addAll(
          refSnap.docs.map(
            (d) => TrainingModuleQuestionRef.fromFirestore(d.data(), d.id),
          ),
        );
      }

      refsByModule[module.id] = allRefs;

      // geçici progress placeholder
      moduleProgressById[module.id] = 0.0;
    }
  }

  Future<void> loadSolvedQuestionsForUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('solved')
        .get();

    solvedQuestionIds
      ..clear()
      ..addAll(snap.docs.map((d) => d.id));
  }
}

// =========================
// HELPER
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
