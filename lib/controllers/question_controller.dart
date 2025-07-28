import 'package:get/get.dart';
import '../models/question.dart';

class QuestionController extends GetxController {
  final RxList<Question> allQuestions = <Question>[].obs;

  // 🎯 Filtreler enum oldu
  final RxString selectedTopic = 'All'.obs;
  final Rx<Difficulty?> selectedDifficulty = Rx<Difficulty?>(null);
  final Rx<Status?> selectedStatus = Rx<Status?>(null);
  final RxString searchQuery = ''.obs;

  List<Question> get filteredQuestions {
    return allQuestions.where((q) {
      final matchesTopic = selectedTopic.value == 'All' || q.topic == selectedTopic.value;
      final matchesDifficulty = selectedDifficulty.value == null || q.difficulty == selectedDifficulty.value;
      final matchesStatus = selectedStatus.value == null || q.status == selectedStatus.value;
      final matchesSearch = q.title.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesTopic && matchesDifficulty && matchesStatus && matchesSearch;
    }).toList();
  }

  void loadDummyQuestions() {
    allQuestions.addAll([
      Question(
        id: 'mcq1',
        title: 'What is Flutter?',
        topic: 'Mobile Development',
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
        difficulty: Difficulty.medium,
        status: Status.todo,
        tags: ['variables', 'final'],
        type: QuestionType.shortAnswer,
      ),
      Question(
        id: 'code1',
        title: 'Write a function to reverse a linked list.',
        topic: 'Data Structures',
        difficulty: Difficulty.hard,
        status: Status.todo,
        tags: ['linked list'],
        type: QuestionType.coding,
      ),
    ]);
  }

  void updateFilters({String? topic, Difficulty? difficulty, Status? status}) {
    if (topic != null) selectedTopic.value = topic;
    if (difficulty != null) selectedDifficulty.value = difficulty;
    if (status != null) selectedStatus.value = status;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  Question? getRandomQuestion() {
    final list = filteredQuestions;
    if (list.isEmpty) return null;
    list.shuffle();
    return list.first;
  }
}
