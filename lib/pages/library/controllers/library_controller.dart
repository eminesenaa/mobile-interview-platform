// ===================== File: lib/pages/library/controllers/library_controller.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../services/library_service.dart';

enum LibraryTab { all, collections, exams }

class LibraryController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // reactive state
  final currentTab = LibraryTab.all.obs;

  // search
  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

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
