// ===================== File: lib/pages/library/controllers/library_controller.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../models/training_module.dart';
import '../../practice/controllers/practice_controller.dart';
import '../../practice/training_module_detail_page.dart';
import '../../runner/question_feed.dart';
import '../../runner/question_runner_page.dart';
import '../services/library_service.dart';
import '../widgets/save_question_to_collection_sheet.dart';

/// Library sayfasındaki 3 ana tab
enum LibraryTab { all, collections, modules }

class LibraryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // ============================================================
  // 🧩 TAB CONTROLLER & REACTIVE STATE
  // ============================================================
  late TabController tabController;
  final currentTab = LibraryTab.all.obs;

  // ============================================================
  // 🔍 SEARCH STATE
  // ============================================================
  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Save Sheet için ayrı search alanı
  final RxString search = ''.obs;

  // Son gelen koleksiyon listesi (gerekirse caching için)
  List<CollectionData> lastRawCollections = [];

  // Yeni koleksiyon oluşturulunca otomatik seçilmesi için ID
  final RxnString autoSelectCollectionId = RxnString();

  // ============================================================
  // 📚 MODULES (Temporary Dummy Data — backend gelene kadar)
  // ============================================================
  final RxList<TrainingModule> modules = <TrainingModule>[].obs;

  // UI'da StreamBuilder ile kullanılacak
  Stream<List<TrainingModule>> get modulesStream => modules.stream;

  // ============================================================
  // 🔎 COLLECTION FILTERING
  // ============================================================
  List<CollectionData> filteredCollections(List<CollectionData> all) {
    final q = search.value.trim().toLowerCase();

    // 1) Search
    List<CollectionData> filtered = q.isEmpty
        ? List.from(all)
        : all.where((c) => c.name.toLowerCase().contains(q)).toList();

    // 2) Sorting
    filtered.sort(_collectionSorter);

    return filtered;
  }

  int _collectionSorter(CollectionData a, CollectionData b) {
    final nameA = a.name.trim();
    final nameB = b.name.trim();

    final startsNumA = _startsWithNumber(nameA);
    final startsNumB = _startsWithNumber(nameB);
    final startsAlphaA = _startsWithLetter(nameA);
    final startsAlphaB = _startsWithLetter(nameB);

    // 1) Numbers first
    if (startsNumA && !startsNumB) return -1;
    if (!startsNumA && startsNumB) return 1;

    // 2) Letters second
    if (startsAlphaA && !startsAlphaB) return -1;
    if (!startsAlphaA && startsAlphaB) return 1;

    // 3) Special characters last
    return nameA.toLowerCase().compareTo(nameB.toLowerCase());
  }

  bool _startsWithNumber(String s) {
    if (s.isEmpty) return false;
    return int.tryParse(s[0]) != null;
  }

  bool _startsWithLetter(String s) {
    if (s.isEmpty) return false;
    return s[0].toLowerCase().contains(RegExp(r'[a-zğüşöçı]'));
  }

  // ============================================================
  // 🔄 LIFECYCLE
  // ============================================================
  @override
  void onInit() {
    super.onInit();

    // Tab bar
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentTab.value = LibraryTab.values[tabController.index];
      }
    });

    // TEMP: dummy modules
    modules.value = dummyModules;

    // SearchController listener
    searchCtrl.addListener(() {
      searchQuery.value = searchCtrl.text;
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  // ============================================================
  // 🧩 UI ACTION HANDLERS
  // ============================================================
  void onSearchChanged(String v) {
    searchQuery.value = v;
  }

  void onSortPressed() {
    Get.snackbar('Sort', 'Sort & filter coming soon');
  }

  Future<void> onCreateCollectionPressed() async {
    final name = await _askText('New Collection', 'Collection name');
    if (name == null || name.trim().isEmpty) return;
    await LibraryService.instance.createCollection(name.trim());
  }

  // ============================================================
  // 📁 CREATE COLLECTION (Save Sheet için)
  // ============================================================
  Future<String> createCollection(String name) async {
    final newId = await LibraryService.instance.createCollection(name.trim());
    autoSelectCollectionId.value = newId;
    return newId;
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

  // ============================================================
  // 🔗 STREAMS
  // ============================================================
  Stream<List<Question>> get savedQuestionsStream =>
      LibraryService.instance.savedQuestionsStream();

  Stream<List<CollectionData>> get collectionsStream =>
      LibraryService.instance.collectionsStream();

  // ============================================================
  // 🔎 FILTER FUNCTIONS
  // ============================================================
  List<Question> filterQuestions(List<Question> all) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((question) {
      return question.title.toLowerCase().contains(q);
    }).toList();
  }

  List<TrainingModule> filterModules(List<TrainingModule> all) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((m) {
      return m.title.toLowerCase().contains(q) ||
          m.subtitle.toLowerCase().contains(q);
    }).toList();
  }

  // ============================================================
  // 🚀 RUNNER HELPERS (All Tab)
  // ============================================================
  void openRunnerAllTab(List<Question> questions, int startIndex) {
    final feed = QuestionFeed(
      questionIds: questions.map((q) => q.id).toList(),
      questions: questions,
      startIndex: startIndex,
      source: QuestionSourceContext(
        kind: QuestionSourceKind.libraryAll,
        label: 'Library • All',
      ),
    );
    Get.to(() => QuestionRunnerPage(feed: feed));
  }

  // ============================================================
  // ⭐ QUESTION SAVE / MOVEMENT OPTIONS
  // ============================================================
  Future<void> openQuestionOptions(Question q) async {
    final qId = q.id;

    final isSaved = await LibraryService.instance.isSavedOnce(qId);

    if (isSaved) {
      // Already saved → Show menu
      await Get.bottomSheet(
        SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove from My Library"),
                onTap: () async {
                  Get.back();
                  await LibraryService.instance.removeQuestionEverywhere(qId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined, color: Colors.blue),
                title: const Text("Move to Collection"),
                onTap: () async {
                  Get.back();
                  await Get.bottomSheet(
                    SafeArea(
                      child: SaveQuestionToCollectionSheet(questionId: qId),
                    ),
                    isScrollControlled: true,
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else {
      // Not saved → Directly open collection picker
      await Get.bottomSheet(
        SafeArea(
          child: SaveQuestionToCollectionSheet(questionId: qId),
        ),
        isScrollControlled: true,
      );
    }
  }

  // ============================================================
  // 🚀 RUNNER HELPERS (Collections Tab)
  // ============================================================
  void openRunnerFromCollection(
    List<Question> questions,
    int startIndex, {
    required String collectionId,
    String? collectionName,
  }) {
    final feed = QuestionFeed(
      questionIds: questions.map((q) => q.id).toList(),
      questions: questions,
      startIndex: startIndex,
      source: QuestionSourceContext(
        kind: QuestionSourceKind.collection,
        label: collectionName != null
            ? 'Collection: $collectionName'
            : 'Collection',
        refId: collectionId,
      ),
    );

    Get.to(() => QuestionRunnerPage(feed: feed));
  }

  // Yeni navigasyon fonksiyonu:
  void navigateToModuleDetail(TrainingModule module) {
    // GetX kullanıldığı varsayılarak Get.to kullanılır.
    // 'TrainingModuleDetailPage' import etmeyi unutmayın.
    // Eğer zaten PracticeController başka bir yerde (örneğin PracticePage'de) Get.put ile eklenmişse ve silinmemişse, Get onu tekrar eklemeyecektir.
// Silinmişse (ki LibraryPage'den açarken muhtemelen silinmiştir), tekrar eklenir.
// Bu, Module Detail Page'in çalışması için gereken Controller'ı garanti eder.
    if (Get.isRegistered<PracticeController>() == false) {
      Get.put(PracticeController());
    }

    Get.to(() => TrainingModuleDetailPage(module: module));
  }
}

// ============================================================
// 🧪 TEMP: Dummy training modules
// ============================================================
final List<TrainingModule> dummyModules = [
  TrainingModule(
    id: 'module_algorithms',
    title: 'Algorithms Basics',
    subtitle: 'Learn core algorithm concepts step-by-step',
    description:
        'This module introduces fundamental algorithm concepts including time complexity, searching, sorting and problem-solving strategies.',
    format: TrainingModuleFormat.crashCourse,
    coverImageUrl: null,
    totalQuestions: 20,
    estimatedMinutes: 45,
    isFeatured: true,
    sortOrder: 1,
  ),
  TrainingModule(
    id: 'module_data_structures',
    title: 'Data Structures Mastery',
    subtitle: 'Arrays, Linked Lists, Trees, Graphs & more',
    description:
        'Deep dive into essential data structures. Perfect for strengthening coding interview performance.',
    format: TrainingModuleFormat.interviewPrep,
    coverImageUrl: null,
    totalQuestions: 30,
    estimatedMinutes: 60,
    isFeatured: false,
    sortOrder: 2,
  ),
  TrainingModule(
    id: 'module_system_design',
    title: 'System Design Intro',
    subtitle: 'Understand basic high-level architecture',
    description:
        'System design for beginners. Learn how to design scalable applications with real-world interview examples.',
    format: TrainingModuleFormat.challenge,
    coverImageUrl: null,
    totalQuestions: 15,
    estimatedMinutes: 50,
    isFeatured: false,
    sortOrder: 3,
  ),
  TrainingModule(
    id: 'module_sql_crash',
    title: 'SQL Crash Course',
    subtitle: 'Master SQL queries fast',
    description:
        'A short and intensive path for learning SQL SELECT, JOIN, GROUP BY, aggregate functions and real interview tasks.',
    format: TrainingModuleFormat.crashCourse,
    coverImageUrl: null,
    totalQuestions: 18,
    estimatedMinutes: 40,
    isFeatured: true,
    sortOrder: 4,
  ),
  TrainingModule(
    id: 'module_js_30day',
    title: '30 Days JavaScript Challenge',
    subtitle: 'Daily JS tasks to build strong fundamentals',
    description:
        'A 30-day JavaScript challenge to make you comfortable with loops, functions, DOM, promises, async/await and more.',
    format: TrainingModuleFormat.challenge,
    coverImageUrl: null,
    totalQuestions: 30,
    estimatedMinutes: 120,
    isFeatured: false,
    sortOrder: 5,
  ),
];
