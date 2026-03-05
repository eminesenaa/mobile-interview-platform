// ===================== File: lib/pages/library/controllers/library_controller.dart =====================

import 'dart:async';
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

enum LibraryTab { all, collections, modules }

enum CollectionSortMode {
  nameAsc,
  createdDesc,
}

class LibraryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TrainingProgressService _progressService = TrainingProgressService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late TabController tabController;
  final currentTab = LibraryTab.all.obs;
  StreamSubscription? _savedQuestionsSubscription;

  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString search = ''.obs;

  List<CollectionData> lastRawCollections = [];
  final RxnString autoSelectCollectionId = RxnString();

  final RxList<String> selectedTopics = <String>[].obs;
  final RxList<Difficulty> selectedDifficulties = <Difficulty>[].obs;
  final RxList<QuestionType> selectedQuestionTypes = <QuestionType>[].obs;
  final Rx<Status?> selectedStatus = Rx<Status?>(null);

  final RxBool isSelecting = false.obs;
  final RxList<String> selectedQuestionIds = <String>[].obs;
  final Rx<CollectionSortMode> sortMode = CollectionSortMode.createdDesc.obs;

  final RxBool isSelectingCollections = false.obs;
  final RxSet<String> selectedCollectionIds = <String>{}.obs;

  final RxList<Question> savedQuestions = <Question>[].obs;

  final RxList<TrainingModule> modules = <TrainingModule>[].obs;
  final RxMap<String, UserTrainingModuleProgress> modulesProgressMap =
      <String, UserTrainingModuleProgress>{}.obs;
  final RxBool isLoadingModules = false.obs;

  Stream<List<TrainingModule>> get modulesStream => modules.stream;

  // ============================================================
  // 🔄 LIFECYCLE
  // ============================================================
  @override
  void onInit() {
    super.onInit();

    // ✅ tabController her zaman initialize ediliyor — user olsa da olmasa da
    tabController = TabController(length: 3, vsync: this);

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        isSelecting.value = false;
        selectedQuestionIds.clear();
        isSelectingCollections.value = false;
        selectedCollectionIds.clear();
        searchCtrl.clear();
        searchQuery.value = '';
        search.value = '';

        if (tabController.index == 2) {
          fetchStartedModules();
        }
      }
    });

    searchCtrl.addListener(() {
      searchQuery.value = searchCtrl.text;
    });

    // User yoksa data fetch'i atla
    final user = AuthService.instance.currentUser;
    if (user == null) {
      debugPrint(
          "⚠️ LibraryController: no signed-in user, skipping data fetch.");
      return;
    }

    _savedQuestionsSubscription = savedQuestionsStream.listen((list) {
      savedQuestions.assignAll(list);
    });

    fetchStartedModules();
  }

  @override
  void onClose() {
    _savedQuestionsSubscription?.cancel();
    tabController.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  // ============================================================
  // COLLECTIONS
  // ============================================================
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
        filtered.sort((a, b) {
          final aTime = a.createdAt;
          final bTime = b.createdAt;
          if (aTime == null && bTime == null) return b.id.compareTo(a.id);
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        break;
    }
    return filtered;
  }

  // ============================================================
  // FILTER
  // ============================================================
  List<String> get dynamicTopics {
    return savedQuestions
        .map((q) => q.topic)
        .where((t) => t.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<Difficulty> get dynamicDifficulties =>
      savedQuestions.map((q) => q.difficulty).toSet().toList();

  List<QuestionType> get dynamicQuestionTypes =>
      savedQuestions.map((q) => q.type).toSet().toList();

  List<Status> get dynamicStatuses =>
      savedQuestions.map((q) => q.status).toSet().toList();

  bool get hasActiveFilters =>
      selectedTopics.isNotEmpty ||
      selectedDifficulties.isNotEmpty ||
      selectedQuestionTypes.isNotEmpty ||
      selectedStatus.value != null;

  void clearFilters() {
    selectedTopics.clear();
    selectedDifficulties.clear();
    selectedQuestionTypes.clear();
    selectedStatus.value = null;
  }

  List<String> get activeFilterLabels {
    final List<String> out = [];
    for (final t in selectedTopics) out.add(t);
    for (final d in selectedDifficulties) out.add(formatDifficultyLabel(d));
    for (final qt in selectedQuestionTypes)
      out.add(formatQuestionTypeLabel(qt));
    if (selectedStatus.value != null)
      out.add(formatStatusLabel(selectedStatus.value!));
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
  // 🔥 FETCH STARTED MODULES
  // ============================================================
  Future<void> fetchStartedModules() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      isLoadingModules.value = true;

      final progressList =
          await _progressService.getAllProgressForUser(user.uid);

      if (progressList.isEmpty) {
        modules.clear();
        modulesProgressMap.clear();
        return;
      }

      modulesProgressMap.clear();
      final startedIds = <String>{};
      for (var p in progressList) {
        modulesProgressMap[p.moduleId] = p;
        startedIds.add(p.moduleId);
      }

      final snap = await _db.collection('modules').get();
      final allModules = snap.docs
          .map((d) => TrainingModule.fromFirestore(d.data(), d.id))
          .toList();

      modules.assignAll(
          allModules.where((m) => startedIds.contains(m.id)).toList());
    } catch (e) {
      debugPrint("Error fetching started modules: $e");
    } finally {
      isLoadingModules.value = false;
    }
  }

  // ============================================================
  // MULTI-SELECT
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

  Future<void> removeFromCollection(
      String collectionId, String questionId) async {
    await LibraryService.instance
        .removeFromCollection(collectionId, questionId);
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
  // UI ACTIONS
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
  // STREAMS
  // ============================================================
  Stream<List<Question>> get savedQuestionsStream =>
      LibraryService.instance.savedQuestionsStream();

  Stream<List<CollectionData>> get collectionsStream =>
      LibraryService.instance.collectionsStream();

  List<Question> filterQuestions(List<Question> raw) {
    final q = searchQuery.value.trim().toLowerCase();
    return raw.where((item) {
      if (q.isNotEmpty && !item.title.toLowerCase().contains(q)) return false;
      if (selectedTopics.isNotEmpty && !selectedTopics.contains(item.topic))
        return false;
      if (selectedDifficulties.isNotEmpty &&
          !selectedDifficulties.contains(item.difficulty)) return false;
      if (selectedQuestionTypes.isNotEmpty &&
          !selectedQuestionTypes.contains(item.type)) return false;
      if (selectedStatus.value != null && item.status != selectedStatus.value)
        return false;
      return true;
    }).toList();
  }

  List<TrainingModule> filterModules(List<TrainingModule> all) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((m) =>
            m.title.toLowerCase().contains(q) ||
            m.subtitle.toLowerCase().contains(q))
        .toList();
  }

  // ============================================================
  // RUNNER
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
                        child: SaveQuestionToCollectionSheet(questionId: qId)),
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
        SafeArea(child: SaveQuestionToCollectionSheet(questionId: qId)),
        isScrollControlled: true,
      );
    }
  }

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

  void navigateToModuleDetail(TrainingModule module) async {
    PracticeController practiceController;

    if (Get.isRegistered<PracticeController>()) {
      practiceController = Get.find<PracticeController>();
    } else {
      practiceController = Get.put(PracticeController());
    }

    if (practiceController.sectionsByModule.isEmpty) {
      await practiceController.loadTrainingModulesFromFirestore();
      await practiceController.loadQuestionsFromFirebase();
    }

    final sections = practiceController.sectionsByModule[module.id] ?? [];
    final refs = practiceController.refsByModule[module.id] ?? [];

    Get.to(() => TrainingModuleDetailPage(
          module: module,
          sections: sections,
          questionRefs: refs,
        ));
  }
}
