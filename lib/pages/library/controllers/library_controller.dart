// lib/pages/library/controllers/library_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../services/library_service.dart'; // Question & Difficulty modelin buradaysa yol doğru

enum LibraryTab { all, collections, exams }

class LibraryController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // reactive state
  final currentTab = LibraryTab.all.obs;

  // search
  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  // ---- DATA ----
  // Questions: artık gerçek Question modelini kullanıyoruz
  final RxList<Question> _allQuestions = <Question>[
    Question(
      id: 'q1',
      title: 'Reverse String',
      difficulty: Difficulty.easy,
      topic: 'Strings',
      description: '',
      status: Status.todo,
      tags: const [],
      type: QuestionType.mcq,
    ),
    Question(
      id: 'q2',
      title: 'Two Sum',
      difficulty: Difficulty.easy_medium,
      topic: 'Arrays',
      description: '',
      status: Status.todo,
      tags: const [],
      type: QuestionType.mcq,
    ),
    Question(
      id: 'q3',
      title: 'Binary Tree Paths',
      difficulty: Difficulty.medium,
      topic: 'Trees',
      description: '',
      status: Status.todo,
      tags: const [],
      type: QuestionType.mcq,
    ),
    Question(
      id: 'q4',
      title: 'LRU Cache',
      difficulty: Difficulty.medium_hard,
      topic: 'Design',
      description: '',
      status: Status.todo,
      tags: const [],
      type: QuestionType.mcq,
    ),
    Question(
      id: 'q5',
      title: 'Regex Matching',
      difficulty: Difficulty.hard,
      topic: 'Dynamic Programming',
      description: '',
      status: Status.todo,
      tags: const [],
      type: QuestionType.mcq,
    ),
  ].obs;

  // Collections: basit mock tip
  final RxList<_Collection> _collections = <_Collection>[
    _Collection(id: 's1', name: 'Data Structures', count: 12),
    _Collection(id: 's2', name: 'Algorithms', count: 8),
    _Collection(id: 's3', name: 'System Design', count: 5),
    _Collection(id: 'c4', name: 'Databases', count: 7),
    _Collection(id: 'c5', name: 'Operating Systems', count: 9),
    _Collection(id: 'c6', name: 'Networking', count: 6),
  ].obs;

  // ---- FILTERED VIEWS ----
  List<Question> get filteredQuestions {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return _allQuestions;
    return _allQuestions.where((e) {
      final inTitle = e.title.toLowerCase().contains(q);
      final inTopic = (e.topic).toLowerCase().contains(q);
      return inTitle || inTopic;
    }).toList();
  }

  List<_Collection> get filteredCollections {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return _collections;
    return _collections.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  // ---- LIFECYCLE ----
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentTab.value = LibraryTab.values[tabController.index];
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  // ---- UI ACTIONS ----
  void onSearchChanged(String v) {
    searchQuery.value = v;
  }

  void onSortPressed() {
    Get.snackbar('Sort', 'Sort & filter coming soon');
  }

  Future<void> onCreateCollectionPressed() async {
    final name = await _askText('New Collection', 'Collection name');
    if (name == null || name.trim().isEmpty) return;
    _collections.add(_Collection(id: UniqueKey().toString(), name: name.trim(), count: 0));
  }

  void onCollectionTap(String id) {
    Get.snackbar('Collection', 'Open collection $id');
  }

  Future<String?> _askText(String title, String hint) async {
    final ctrl = TextEditingController();
    return await Get.defaultDialog<String?>(
      title: title,
      content: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      textConfirm: 'Create',
      textCancel: 'Cancel',
      onConfirm: () => Get.back(result: ctrl.text),
      onCancel: () => Get.back(result: null),
    );
  }

  /// Soru 'All' listesinde mi?
  Future<bool> isSaved(String questionId) async {
    try {
      return await LibraryService.instance.isSavedToAll(questionId);
    } catch (_) {
      return false;
    }
  }

  /// Soru hangi koleksiyonlarda? (koleksiyon id listesi)
  Future<List<String>> getCollectionsOfQuestion(String questionId) async {
    try {
      return await LibraryService.instance.getCollectionsOfQuestion(questionId);
    } catch (_) {
      return <String>[];
    }
  }

  /// (İleride popup 'Apply' için kullanacağız) All toggle
  Future<void> saveToAll(String questionId) =>
      LibraryService.instance.saveToAll(questionId);

  Future<void> removeFromAll(String questionId) =>
      LibraryService.instance.removeFromAll(questionId);

  /// (İleride popup 'Apply' için) koleksiyon ekle/çıkar
  Future<void> saveToCollection(String questionId, String collectionId) =>
      LibraryService.instance.addToCollection(collectionId, questionId);

  Future<void> removeFromCollection(String questionId, String collectionId) =>
      LibraryService.instance.removeFromCollection(collectionId, questionId);
}

// basit collection mock modeli
class _Collection {
  final String id;
  final String name;
  final int count;
  _Collection({required this.id, required this.name, required this.count});
}
