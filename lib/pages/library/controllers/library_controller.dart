// ===================== File: lib/pages/library/controllers/library_controller.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../models/training_module.dart';
import '../../../services/firebase/auth_service.dart';
import '../../practice/controllers/practice_controller.dart';
import '../../practice/training_module_detail_page.dart';
import '../../practice/widgets/filter_popup.dart';
import '../../runner/question_feed.dart';
import '../../runner/question_runner_page.dart';
import '../services/library_service.dart';
import '../widgets/save_question_to_collection_sheet.dart';

/// Library sayfasındaki 3 ana tab
enum LibraryTab { all, collections, modules }

///  COLLECTION SORT MODES
enum CollectionSortMode {
  nameAsc,
  createdDesc,
}

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

  // =======================
  // FILTER STATE (ALL TAB)
  // =======================

  // Çoklu seçim: allowed
  final RxList<String> selectedTopics = <String>[].obs;
  final RxList<Difficulty> selectedDifficulties = <Difficulty>[].obs;
  final RxList<QuestionType> selectedQuestionTypes = <QuestionType>[].obs;

  // Tek seçim: status
  final Rx<Status?> selectedStatus = Rx<Status?>(null);

  // =============================
  // MULTI-SELECT STATE (ALL TAB)
  // =============================
  final RxBool isSelecting = false.obs; // seçim modu açık mı?
  final RxList<String> selectedQuestionIds = <String>[].obs; // seçilenler

  /// Aktif sıralama modu (varsayılan: EN SON EKLENEN ÜSTTE)
  final Rx<CollectionSortMode> sortMode = CollectionSortMode.createdDesc.obs;

  // ============================================================
  // 🗂️ MULTI-SELECT (COLLECTIONS TAB)
  // ============================================================
  /// Collections tab'da seçim modu açık mı?
  final RxBool isSelectingCollections = false.obs;

  /// Seçilen collection ID'leri
  final RxSet<String> selectedCollectionIds = <String>{}.obs;

  // ============================================================
  // 🗑️ COLLECTIONS — MULTI SELECT MODE
  // ============================================================

  /// UI'da üç nokta menüsünden tetiklenir
  void startCollectionSelecting() {
    isSelectingCollections.value = true;
    selectedCollectionIds.clear();
  }

  void stopCollectionSelecting() {
    isSelectingCollections.value = false;
    selectedCollectionIds.clear();
  }

  void toggleSelectCollection(String id) {
    if (selectedCollectionIds.contains(id)) {
      selectedCollectionIds.remove(id);
    } else {
      selectedCollectionIds.add(id);
    }
  }

  void selectAllCollections() {
    selectedCollectionIds
        .assignAll(lastRawCollections.map((c) => c.id).toList());
  }

  // =============================
  // SAVED QUESTIONS (local cache)
  // =============================
  final RxList<Question> savedQuestions = <Question>[].obs;

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
    final q = searchQuery.value.trim().toLowerCase();

    List<CollectionData> filtered = q.isEmpty
        ? List.from(all)
        : all.where((c) => c.name.toLowerCase().contains(q)).toList();

    switch (sortMode.value) {
      case CollectionSortMode.nameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;

      case CollectionSortMode.createdDesc:
        // ⭐ Yeni sırala: createdAt varsa ona göre, yoksa id fallback
        filtered.sort((a, b) {
          final aTime = a.createdAt;
          final bTime = b.createdAt;

          // İkisi de null → fallback doc id
          if (aTime == null && bTime == null) {
            return b.id.compareTo(a.id);
          }

          // Sadece a null → b üstte
          if (aTime == null) return 1;

          // Sadece b null → a üstte
          if (bTime == null) return -1;

          // İkisi de tarihli → büyük olan (yeni) üstte
          return bTime.compareTo(aTime);
        });

        break;
    }

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

  // ================================
  // DYNAMIC FILTER OPTIONS (READ-ONLY)
  // Saved Questions içinden otomatik oluşur
  // ================================

  List<String> get dynamicTopics {
    return savedQuestions
        .map((q) => q.topic)
        .where((t) => t.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<Difficulty> get dynamicDifficulties {
    return savedQuestions
        .map((q) => q.difficulty)
        .where((d) => d != null)
        .map((d) => d!)
        .toSet()
        .toList();
  }

  List<QuestionType> get dynamicQuestionTypes {
    return savedQuestions
        .map((q) => q.type)
        .where((t) => t != null)
        .map((t) => t!)
        .toSet()
        .toList();
  }

  List<Status> get dynamicStatuses {
    return savedQuestions
        .map((q) => q.status)
        .where((s) => s != null)
        .map((s) => s!)
        .toSet()
        .toList();
  }

  bool get hasActiveFilters {
    return selectedTopics.isNotEmpty ||
        selectedDifficulties.isNotEmpty ||
        selectedQuestionTypes.isNotEmpty ||
        selectedStatus.value != null;
  }

  void clearFilters() {
    selectedTopics.clear();
    selectedDifficulties.clear();
    selectedQuestionTypes.clear();
    selectedStatus.value = null;
  }

  // ====================== FILTER CHIP LABELS ======================
  List<String> get activeFilterLabels {
    final List<String> out = [];

    for (final t in selectedTopics) {
      out.add(t);
    }

    for (final d in selectedDifficulties) {
      out.add(formatDifficultyLabel(d));
    }

    for (final qt in selectedQuestionTypes) {
      out.add(formatQuestionTypeLabel(qt));
    }

    if (selectedStatus.value != null) {
      out.add(formatStatusLabel(selectedStatus.value!));
    }

    return out;
  }

  void removeSingleFilter(String label) {
    selectedTopics.remove(label);
    selectedDifficulties.removeWhere((d) => formatDifficultyLabel(d) == label);
    selectedQuestionTypes
        .removeWhere((qt) => formatQuestionTypeLabel(qt) == label);

    if (selectedStatus.value != null &&
        formatStatusLabel(selectedStatus.value!) == label) {
      selectedStatus.value = null;
    }
  }

  void clearAllFilters() {
    selectedTopics.clear();
    selectedDifficulties.clear();
    selectedQuestionTypes.clear();
    selectedStatus.value = null;
  }

  String formatDifficultyLabel(Difficulty d) =>
      d.name.toUpperCase().replaceAll('_', ' ');

  String formatQuestionTypeLabel(QuestionType qt) =>
      qt.name.toUpperCase().replaceAll('_', ' ');

  String formatStatusLabel(Status s) =>
      s.name.toUpperCase().replaceAll('_', ' ');

  // ============================================================
  // 🔄 LIFECYCLE
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    // =========================================================
    // 🔐 USER SIGN-IN CHECK — user yoksa init’i tamamen atla
    // =========================================================
    final user = AuthService.instance.currentUser;
    if (user == null) {
      print("⚠️ LibraryController skipped — no signed-in user.");
      return;
    }

    // Listen to saved questions stream and keep local list updated
    savedQuestionsStream.listen((list) {
      savedQuestions.assignAll(list);
    });

    // Tab bar
    tabController = TabController(length: 3, vsync: this);
    // ⭐ TAB DEĞİŞİNCE SEARCH RESETLE
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        isSelecting.value = false;
        selectedQuestionIds.clear();
        // ⭐ COLLECTION SELECT RESET
        isSelectingCollections.value = false;
        selectedCollectionIds.clear();

        searchCtrl.clear();
        searchQuery.value = '';
        search.value = '';
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
  // 🟦 MULTI-SELECT MODE FUNCTIONS
  // ============================================================

  /// Seçim modunu başlat
  void startSelecting() {
    isSelecting.value = true;
    selectedQuestionIds.clear();
  }

  /// Bir soruyu seç / kaldır
  void toggleSelect(String qId) {
    if (selectedQuestionIds.contains(qId)) {
      selectedQuestionIds.remove(qId);
    } else {
      selectedQuestionIds.add(qId);
    }
  }

  /// Seçim modunu sonlandır
  void stopSelecting() {
    isSelecting.value = false;
    selectedQuestionIds.clear();
  }

  /// Seçilen soruları var olan koleksiyona taşı
  Future<void> moveSelectedToCollection(String collectionId) async {
    final items = selectedQuestionIds.toList();
    if (items.isEmpty) return;

    for (final qId in items) {
      await LibraryService.instance.addToCollection(collectionId, qId);
    }

    stopSelecting(); // seçim modu kapatılır
  }

  /// Yeni koleksiyon oluştur → seçilenleri ekle
  Future<void> createCollectionAndMoveSelected(String name) async {
    final newId = await createCollection(name);
    await moveSelectedToCollection(newId);
  }

  Future<void> deleteSelectedQuestions() async {
    final ids = selectedQuestionIds.toList();
    if (ids.isEmpty) return;

    for (final id in ids) {
      await LibraryService.instance.removeQuestionEverywhere(id);
    }

    stopSelecting();
  }

  /// Kullanıcı bir soruyu hangi koleksiyonlara eklemek istiyorsa
  /// save sheet'i açar, seçilen tüm koleksiyonları Firestore'a ekler.
  /// Ardından bookmark ikonunu ve ALL tab'ını yeniler.
  Future<void> openSaveSheetFor(String questionId) async {
    final result = await Get.bottomSheet(
      SaveQuestionToCollectionSheet(questionId: questionId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (result == null) return;

    final bool saveToLibrary = result["library"] == true;
    final List<String> collectionIds = List<String>.from(result["collections"]);

    // 🟦 1) Library'ye kaydet
    if (saveToLibrary) {
      await LibraryService.instance.saveToAll(questionId);
    }

    // 🟦 2) Seçilen koleksiyonlara kaydet
    for (final cId in collectionIds) {
      await LibraryService.instance.addToCollection(cId, questionId);
    }

    // 🟦 3) Bookmark UI güncelle
    await updateBookmarkState(questionId);

    // 🟦 4) ALL tab yenile
    await reloadSavedQuestions();
  }

  Future<void> updateBookmarkState(String questionId) async {
    final isSaved = await LibraryService.instance.isSavedOnce(questionId);

    final idx = savedQuestions.indexWhere((q) => q.id == questionId);

    if (isSaved && idx == -1) {
      // yeni ekleniyorsa listeye eklemen gerek ama soru datası sende yok
      // ALL sekmesinin Stream'i zaten otomatik güncelleyecek
      return;
    }

    if (!isSaved && idx != -1) {
      savedQuestions.removeAt(idx);
    }
  }

  Future<void> reloadSavedQuestions() async {
    savedQuestions.assignAll(
      await LibraryService.instance.savedQuestionsStream().first,
    );
  }

  Future<void> removeQuestionEverywhere(String questionId) async {
    // Service çağır → tüm saved + collection'lardan kaldırır
    await LibraryService.instance.removeQuestionEverywhere(questionId);

    // UI güncelle
    await updateBookmarkState(questionId);
    await reloadSavedQuestions();
  }

  Future<void> removeFromCollection(
      String collectionId, String questionId) async {
    await LibraryService.instance
        .removeFromCollection(collectionId, questionId);

    // UI güncellemesi
    await updateBookmarkState(questionId);
    await reloadSavedQuestions();
  }

  // ============================================================
  // 🗑️ DELETE SELECTED COLLECTIONS
  // ============================================================
  Future<void> deleteSelectedCollections() async {
    final ids = selectedCollectionIds.toList();
    if (ids.isEmpty) return;

    for (final id in ids) {
      await LibraryService.instance.deleteCollection(id);
    }

    stopCollectionSelecting();
  }

  /// Bir collection kartına tıklanınca seç / kaldır
  void toggleCollectionSelected(String id) {
    if (!isSelectingCollections.value) return;

    if (selectedCollectionIds.contains(id)) {
      selectedCollectionIds.remove(id);
    } else {
      selectedCollectionIds.add(id);
    }
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
    final name = await askText('New Collection', 'Collection name');
    if (name == null || name.trim().isEmpty) return;
    sortMode.value = CollectionSortMode.createdDesc;
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

  Future<String?> askText(String title, String hint) async {
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

  // =======================
  // OPEN FILTER POPUP
  // (Only for ALL TAB)
  // =======================

  void openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FilterPopup(
          // Dinamik seçenekler
          topics: dynamicTopics,
          difficulties: Difficulty.values,
          statuses: Status.values,
          questionTypes: QuestionType.values,

          // Mevcut seçimler
          selectedTopics: selectedTopics,
          selectedDifficulties: selectedDifficulties,
          selectedQuestionTypes: selectedQuestionTypes,
          selectedStatus: selectedStatus.value,

          // Kullanıcı Apply diyince controller’daki değerlere yaz
          onApply: ({
            required List<String> topics,
            required List<Difficulty> difficulties,
            required List<QuestionType> questionTypes,
            required Status? status,
          }) {
            selectedTopics.assignAll(topics);
            selectedDifficulties.assignAll(difficulties);
            selectedQuestionTypes.assignAll(questionTypes);
            selectedStatus.value = status;
          },
        );
      },
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
  List<Question> filterQuestions(List<Question> raw) {
    final q = searchQuery.value.trim().toLowerCase();

    return raw.where((item) {
      // Search filter
      if (q.isNotEmpty && !item.title.toLowerCase().contains(q)) {
        return false;
      }

      // Topic filter
      if (selectedTopics.isNotEmpty && !selectedTopics.contains(item.topic)) {
        return false;
      }

      // Difficulty filter
      if (selectedDifficulties.isNotEmpty &&
          !selectedDifficulties.contains(item.difficulty)) {
        return false;
      }

      // Question type filter
      if (selectedQuestionTypes.isNotEmpty &&
          !selectedQuestionTypes.contains(item.type)) {
        return false;
      }

      // Status filter
      if (selectedStatus.value != null && item.status != selectedStatus.value) {
        return false;
      }

      return true;
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
