// ===================== File: lib/controllers/question_controller.dart =====================
// Purpose: Soru listesini yönetir (yükleme, filtreleme, arama, ekleme).
//          GetX Controller kullanılarak reactive state yönetimi yapılır.
//
// Notlar:
// - UI (View) içinde çağırılır: final controller = Get.put(QuestionController());
// - Sorular reactive (`RxList`) tutulduğu için filtreleme/arama yapıldığında
//   UI otomatik güncellenir (Obx widget'ı sayesinde).
// ==========================================================================
import 'package:get/get.dart';
import '../models/question.dart';

class QuestionController extends GetxController {
  /// Tüm soruların listesi
  final RxList<Question> allQuestions = <Question>[].obs;

  final RxString selectedTopic = 'All'.obs;
  final Rx<Difficulty?> selectedDifficulty = Rx<Difficulty?>(null);
  final Rx<Status?> selectedStatus = Rx<Status?>(null);
  final RxString searchQuery = ''.obs;

  /// Filtrelenmiş soruların listesi
  List<Question> get filteredQuestions {
    return allQuestions.where((q) {
      final matchesTopic = selectedTopic.value == 'All' || q.topic == selectedTopic.value;
      final matchesDifficulty = selectedDifficulty.value == null || q.difficulty == selectedDifficulty.value;
      final matchesStatus = selectedStatus.value == null || q.status == selectedStatus.value;
      final matchesSearch = q.title.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesTopic && matchesDifficulty && matchesStatus && matchesSearch;
    }).toList();
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
        id: 'short1',
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
        options: ['language', 'sdk', 'framework', 'package', 'library'], // decoy + doğru
      ),

    ]);
  }

  /// Soruları filtrele (örn: konuya göre)
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


