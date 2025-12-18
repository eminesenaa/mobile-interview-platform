// ===================== File: lib/pages/library/controllers/library_controller.dart =====================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/question.dart';
import '../../../models/training_module.dart';
import '../../../models/user_training_progress.dart';

import '../../../services/firebase/auth_service.dart';
import '../../practice/services/training_progress_service.dart';

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
  // SERVICES
  // ============================================================
  final TrainingProgressService _progressService = TrainingProgressService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
  // 📚 MODULES (REAL DATA)
  // ============================================================
  /// Kullanıcının başladığı gerçek modüller
  final RxList<TrainingModule> modules = <TrainingModule>[].obs;
  
  /// Modül ID -> İlerleme verisi (Progress bar için)
  final RxMap<String, UserTrainingModuleProgress> modulesProgressMap = 
      <String, UserTrainingModuleProgress>{}.obs;

  /// Yükleniyor durumu
  final RxBool isLoadingModules = false.obs;

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

  // ================================
  // DYNAMIC FILTER OPTIONS (READ-ONLY)
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
        .toSet()
        .toList();
  }

  List<QuestionType> get dynamicQuestionTypes {
    return savedQuestions
        .map((q) => q.type)
        .toSet()
        .toList();
  }

  List<Status> get dynamicStatuses {
    return savedQuestions
        .map((q) => q.status)
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
    selectedQuestionTypes.removeWhere((qt) => formatQuestionTypeLabel(qt) == label);
    if (selectedStatus.value != null && formatStatusLabel(selectedStatus.value!) == label) {
      selectedStatus.value = null;
    }
  }

  void clearAllFilters() {
    selectedTopics.clear();
    selectedDifficulties.clear();
    selectedQuestionTypes.clear();
    selectedStatus.value = null;
  }

  String formatDifficultyLabel(Difficulty d) => d.name.toUpperCase().replaceAll('_', ' ');
  String formatQuestionTypeLabel(QuestionType qt) => qt.name.toUpperCase().replaceAll('_', ' ');
  String formatStatusLabel(Status s) => s.name.toUpperCase().replaceAll('_', ' ');

  // ============================================================
  // 🔄 LIFECYCLE
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    final user = AuthService.instance.currentUser;
    if (user == null) {
      debugPrint("⚠️ LibraryController skipped — no signed-in user.");
      return;
    }

    // Listen to saved questions stream and keep local list updated
    savedQuestionsStream.listen((list) {
      savedQuestions.assignAll(list);
    });

    // Tab bar
    tabController = TabController(length: 3, vsync: this);
    
    // ⭐ TAB DEĞİŞİKLİĞİ DİNLEYİCİSİ
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        // Genel resetler
        isSelecting.value = false;
        selectedQuestionIds.clear();
        isSelectingCollections.value = false;
        selectedCollectionIds.clear();
        searchCtrl.clear();
        searchQuery.value = '';
        search.value = '';

        // 🔥 Eğer Modules sekmesine geçildiyse veriyi tazele
        if (tabController.index == 2) {
           fetchStartedModules();
        }
      }
    });

    // Initial fetch for modules
    fetchStartedModules();

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
  // 🔥 FETCH STARTED MODULES (BACKEND INTEGRATION)
  // ============================================================
  Future<void> fetchStartedModules() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    
    try {
      isLoadingModules.value = true;
      
      // 1. Kullanıcının progress kayıtlarını çek
      final progressList = await _progressService.getAllProgressForUser(user.uid);
      
      if (progressList.isEmpty) {
        modules.clear();
        modulesProgressMap.clear();
        return;
      }

      // 2. Progress map'ini ve ID listesini hazırla
      modulesProgressMap.clear();
      final startedIds = <String>{};
      for (var p in progressList) {
        modulesProgressMap[p.moduleId] = p;
        startedIds.add(p.moduleId);
      }

      // 3. Modülleri 'modules' koleksiyonundan çek
      final snap = await _db.collection('modules').get();
      final allModules = snap.docs
          .map((d) => TrainingModule.fromFirestore(d.data(), d.id))
          .toList();

      // Sadece başlanmış olanları filtrele
      final startedModules = allModules
          .where((m) => startedIds.contains(m.id))
          .toList();

      modules.assignAll(startedModules);

    } catch (e) {
      debugPrint("Error fetching started modules: $e");
    } finally {
      isLoadingModules.value = false;
    }
  }

  // ============================================================
  // 🟦 MULTI-SELECT MODE FUNCTIONS
  // ============================================================

  void startSelecting() {
    isSelecting.value = true;
    selectedQuestionIds.clear();
  }

  void toggleSelect(String qId) {
    if (selectedQuestionIds.contains(qId)) {
      selectedQuestionIds.remove(qId);
    } else {
      selectedQuestionIds.add(qId);
    }
  }

  void stopSelecting() {
    isSelecting.value = false;
    selectedQuestionIds.clear();
  }

  Future<void> moveSelectedToCollection(String collectionId) async {
    final items = selectedQuestionIds.toList();
    if (items.isEmpty) return;
    for (final qId in items) {
      await LibraryService.instance.addToCollection(collectionId, qId);
    }
    stopSelecting();
  }

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

  Future<void> openSaveSheetFor(String questionId) async {
    final result = await Get.bottomSheet(
      SaveQuestionToCollectionSheet(questionId: questionId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (result == null) return;
    final bool saveToLibrary = result["library"] == true;
    final List<String> collectionIds = List<String>.from(result["collections"]);
    if (saveToLibrary) await LibraryService.instance.saveToAll(questionId);
    for (final cId in collectionIds) {
      await LibraryService.instance.addToCollection(cId, questionId);
    }
    await updateBookmarkState(questionId);
    await reloadSavedQuestions();
  }

  Future<void> updateBookmarkState(String questionId) async {
    final isSaved = await LibraryService.instance.isSavedOnce(questionId);
    final idx = savedQuestions.indexWhere((q) => q.id == questionId);
    if (isSaved && idx == -1) return;
    if (!isSaved && idx != -1) savedQuestions.removeAt(idx);
  }

  Future<void> reloadSavedQuestions() async {
    savedQuestions.assignAll(
      await LibraryService.instance.savedQuestionsStream().first,
    );
  }

  Future<void> removeQuestionEverywhere(String questionId) async {
    await LibraryService.instance.removeQuestionEverywhere(questionId);
    await updateBookmarkState(questionId);
    await reloadSavedQuestions();
  }

  Future<void> removeFromCollection(String collectionId, String questionId) async {
    await LibraryService.instance.removeFromCollection(collectionId, questionId);
    await updateBookmarkState(questionId);
    await reloadSavedQuestions();
  }

  Future<void> deleteSelectedCollections() async {
    final ids = selectedCollectionIds.toList();
    if (ids.isEmpty) return;
    for (final id in ids) {
      await LibraryService.instance.deleteCollection(id);
    }
    stopCollectionSelecting();
  }

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
  void onSearchChanged(String v) => searchQuery.value = v;

  void onSortPressed() => Get.snackbar('Sort', 'Sort & filter coming soon');

  Future<void> onCreateCollectionPressed() async {
    final name = await askText('New Collection', 'Collection name');
    if (name == null || name.trim().isEmpty) return;
    sortMode.value = CollectionSortMode.createdDesc;
    await LibraryService.instance.createCollection(name.trim());
  }

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

  void openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FilterPopup(
          topics: dynamicTopics,
          difficulties: Difficulty.values,
          statuses: Status.values,
          questionTypes: QuestionType.values,
          selectedTopics: selectedTopics,
          selectedDifficulties: selectedDifficulties,
          selectedQuestionTypes: selectedQuestionTypes,
          selectedStatus: selectedStatus.value,
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
      if (q.isNotEmpty && !item.title.toLowerCase().contains(q)) return false;
      if (selectedTopics.isNotEmpty && !selectedTopics.contains(item.topic)) return false;
      if (selectedDifficulties.isNotEmpty && !selectedDifficulties.contains(item.difficulty)) return false;
      if (selectedQuestionTypes.isNotEmpty && !selectedQuestionTypes.contains(item.type)) return false;
      if (selectedStatus.value != null && item.status != selectedStatus.value) return false;
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
        label: collectionName != null ? 'Collection: $collectionName' : 'Collection',
        refId: collectionId,
      ),
    );
    Get.to(() => QuestionRunnerPage(feed: feed));
  }

  // ============================================================
  // 🔥 NAVIGATE TO MODULE DETAIL (PracticeController Logic)
  // ============================================================
  void navigateToModuleDetail(TrainingModule module) async {
    // 1. PracticeController'a eriş (Yoksa yarat)
    PracticeController practiceController;
    
    if (Get.isRegistered<PracticeController>()) {
      practiceController = Get.find<PracticeController>();
    } else {
      practiceController = Get.put(PracticeController());
    }

    // 2. Eğer PracticeController'ın verisi henüz yüklenmediyse bekle
    // (Practice sayfası hiç açılmadıysa boş olabilir)
    if (practiceController.sectionsByModule.isEmpty) {
      // Veriyi yükle
      await practiceController.loadTrainingModulesFromFirestore();
      await practiceController.loadQuestionsFromFirebase();
    }

    // 3. Modüle ait section ve referansları PracticeController hafızasından çek
    final sections = practiceController.sectionsByModule[module.id] ?? [];
    final refs = practiceController.refsByModule[module.id] ?? [];

    // 4. Detay sayfasına dolu paketle git
    Get.to(() => TrainingModuleDetailPage(
      module: module,
      sections: sections,      // 🔥 ARTIK DOLU GİDECEK
      questionRefs: refs,      // 🔥 ARTIK DOLU GİDECEK
    ));
  }
}