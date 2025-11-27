// ===================== File: lib/pages/library/controllers/library_controller.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../services/library_service.dart';

enum LibraryTab { all, collections, exams }

class LibraryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // reactive state
  final currentTab = LibraryTab.all.obs;

  // search
  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxString search =
      ''.obs; // SAVE SHEET search bar bunun üzerinden çalışacak

  List<CollectionData> lastRawCollections = [];

  // Yeni oluşturulan collection'ın ID'sini tutar
  final RxnString autoSelectCollectionId = RxnString();

  // ===============================================================
  // 🔎 FILTERED COLLECTIONS — Stream'den gelen listeyi filtreler
  // ===============================================================
  List<CollectionData> filteredCollections(List<CollectionData> all) {
    final q = search.value.trim().toLowerCase();
    // 1) Search filter
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

    // 1) Sayı ile başlayanlar en üstte
    if (startsNumA && !startsNumB) return -1;
    if (!startsNumA && startsNumB) return 1;

    // 2) Harf ile başlayanlar ikinci grup
    if (startsAlphaA && !startsAlphaB) return -1;
    if (!startsAlphaA && startsAlphaB) return 1;

    // 3) Özel karakterler en altta
    // özel karakter → ne sayı ne harf
    // aynı gruptalarsa alfabetik karşılaştır
    return nameA.toLowerCase().compareTo(nameB.toLowerCase());
  }

  bool _startsWithNumber(String s) {
    if (s.isEmpty) return false;
    final first = s[0];
    return int.tryParse(first) != null;
  }

  bool _startsWithLetter(String s) {
    if (s.isEmpty) return false;
    final first = s[0].toLowerCase();
    return first.contains(RegExp(r'[a-zğüşöçı]')); // Türkçe destekli <3
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
    await LibraryService.instance.createCollection(name.trim());
  }

  // =======================================================
  // ✨ Save Sheet'in modern popup'ı için eklenen method
  // =======================================================
  Future<String> createCollection(String name) async {
    final newId = await LibraryService.instance.createCollection(name.trim());
    autoSelectCollectionId.value = newId; // ⭐ otomatik seçilecek ID

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

  // ---- STREAMS ----

  /// 🔹 All tab için kayıtlı sorular
  Stream<List<Question>> get savedQuestionsStream {
    return LibraryService.instance.savedQuestionsStream();
  }

  /// 🔹 Collections tab için koleksiyonlar
  Stream<List<CollectionData>> get collectionsStream {
    return LibraryService.instance.collectionsStream();
  }
}
