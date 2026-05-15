// ===================== File: select_questions_controller.dart =====================
// Purpose:
// Controller for "Select Questions from Database"
//
// Features:
// - Fetch questions from Firebase
// - Topic filtering (single + search)
// - Selection management (multi-select)
// - Clean & lightweight (no practice-specific logic)
//
// IMPORTANT:
// - No runner / no solved logic
// - No training module dependency
// - Fully UI-driven
// ================================================================================

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/question.dart';

class SelectQuestionsController extends GetxController {
  // =========================
  // DATA
  // =========================

  final RxList<Question> allQuestions = <Question>[].obs;

  // =========================
  // LOADING
  // =========================

  final RxBool isLoading = true.obs;

  // =========================
  // FILTER STATE
  // =========================

  final RxString searchQuery = ''.obs;
  final RxString selectedTopic = 'All'.obs;

  final RxList<String> allTopics = <String>['All'].obs;

  // ================= MULTI FILTER STATE =================

  final RxList<String> selectedTopicsMulti = <String>[].obs;
  final RxList<Difficulty> selectedDifficultiesMulti = <Difficulty>[].obs;
  final RxList<QuestionType> selectedQuestionTypesMulti = <QuestionType>[].obs;
  final Rxn<Status> selectedStatus = Rxn<Status>();

  // =========================
  // SELECTION STATE
  // =========================

  final RxSet<String> selectedQuestionIds = <String>{}.obs;

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();
    loadQuestionsFromFirebase();
  }

  // MOCK DATA SİLİNECEK
  void _loadMockQuestions() {
    isLoading.value = true;

    final mock = [
      Question(
        id: "q1",
        title: "What is VLAN?",
        description: "Explain what a Virtual LAN (VLAN) is and why it is used.",
        topic: "Network",
        subtopics: ["vlan", "network segmentation"],
        difficulty: Difficulty.medium,
        status: Status.todo,
        tags: ["network", "vlan"],
        type: QuestionType.shortAnswer,
      ),

      Question(
        id: "q2",
        title: "What does HTTP stand for?",
        description: "Choose the correct expansion of HTTP.",
        topic: "Web",
        subtopics: ["http", "protocols"],
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: ["web", "http"],
        type: QuestionType.mcq,
        options: [
          "HyperText Transfer Protocol",
          "High Transfer Text Protocol",
          "Hyper Transfer Text Process",
          "None of the above"
        ],
        correctAnswer: "HyperText Transfer Protocol",
      ),

      Question(
        id: "q3",
        title: "Find the output of this code",
        description: "What will be printed?\n\nint a = 5;\nint b = 2;\nprint(a ~/ b);",
        topic: "Programming",
        subtopics: ["dart", "operators"],
        difficulty: Difficulty.easy_medium,
        status: Status.todo,
        tags: ["dart", "logic"],
        type: QuestionType.mcq,
        options: ["2", "2.5", "3", "Error"],
        correctAnswer: "2",
      ),

      Question(
        id: "q4",
        title: "Fix the bug in the code",
        description: "The following code throws a null error. Fix it.",
        topic: "Programming",
        subtopics: ["null-safety"],
        difficulty: Difficulty.medium_hard,
        status: Status.todo,
        tags: ["debugging", "dart"],
        type: QuestionType.debugging,
        codeTemplate: "String? name;\nprint(name.length);",
      ),

      Question(
        id: "q5",
        title: "Implement a function to reverse a string",
        description: "Write a function that takes a string and returns its reverse.",
        topic: "Algorithms",
        subtopics: ["string", "basic algorithms"],
        difficulty: Difficulty.medium,
        status: Status.todo,
        tags: ["algorithm", "string"],
        type: QuestionType.coding,
        codeTemplate: "String reverse(String input) {\n  // TODO\n}",
        examples: [
          ExampleCase(input: "hello", output: "olleh"),
          ExampleCase(input: "dart", output: "trad"),
        ],
      ),
    ];

    allQuestions.assignAll(mock);

    final topics = mock.map((e) => e.topic).toSet().toList()..sort();

    allTopics.assignAll(['All', ...topics]);

    isLoading.value = false;
  }

  // =========================
  // FIREBASE LOAD
  // =========================

  Future<void> loadQuestionsFromFirebase() async {
    isLoading.value = true;

    try {
      final snap =
          await FirebaseFirestore.instance.collection('questions').get();

      final items =
          snap.docs.map((d) => Question.fromFirestore(d.data(), d.id)).toList();

      allQuestions.assignAll(items);

      // 🔥 Topics çıkar
      final uniqueTopics = items.map((e) => e.topic).toSet().toList()..sort();

      allTopics.assignAll(['All', ...uniqueTopics]);

      debugPrint('[SelectQuestions] ${items.length} questions loaded');
    } catch (e) {
      debugPrint('[SelectQuestions] Load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // FILTERED QUESTIONS
  // =========================

  List<Question> get filteredQuestions {
    var list = allQuestions.toList();

    // 🔹 Topic filter
    if (selectedTopic.value != 'All') {
      list = list.where((q) => q.topic == selectedTopic.value).toList();
    }

    // 🔹 Search filter
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      list = list.where((q) {
        final haystack =
            '${q.title} ${q.description ?? ''} ${q.topic} ${q.tags.join(" ")}'
                .toLowerCase();

        return haystack.contains(query);
      }).toList();
    }

    // 🔹 Multi topic
    if (selectedTopicsMulti.isNotEmpty) {
      list = list.where((q) => selectedTopicsMulti.contains(q.topic)).toList();
    } else if (selectedTopic.value != 'All') {
      list = list.where((q) => q.topic == selectedTopic.value).toList();
    }

    // 🔹 Difficulty
    if (selectedDifficultiesMulti.isNotEmpty) {
      list = list.where((q) => selectedDifficultiesMulti.contains(q.difficulty)).toList();
    }

    // 🔹 Question type
    if (selectedQuestionTypesMulti.isNotEmpty) {
      list = list.where((q) => selectedQuestionTypesMulti.contains(q.type)).toList();
    }

    return list;
  }

  // =========================
  // FILTER ACTIONS
  // =========================

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void updateTopic(String topic) {
    selectedTopic.value = topic;
  }

  void updateFiltersMulti({
    List<String>? topics,
    List<Difficulty>? difficulties,
    List<QuestionType>? questionTypes,
    Status? status,
  }) {
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

  // =========================
  // SELECTION LOGIC
  // =========================

  void toggleSelection(String id) {
    if (selectedQuestionIds.contains(id)) {
      selectedQuestionIds.remove(id);
    } else {
      selectedQuestionIds.add(id);
    }
  }

  bool isSelected(String id) {
    return selectedQuestionIds.contains(id);
  }

  // =========================
  // HELPERS
  // =========================

  int get selectedCount => selectedQuestionIds.length;

  List<String> get selectedIds => selectedQuestionIds.toList();

  void clearSelection() {
    selectedQuestionIds.clear();
  }
}
