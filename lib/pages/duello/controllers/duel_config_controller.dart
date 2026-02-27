import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/question.dart';

class DuelConfigController extends GetxController {
  final String modeTitle;

  DuelConfigController(this.modeTitle);

  final selectedIndex = 0.obs;
  final isLoading = true.obs;

  /// Macro categories (UI'da gösterilecek)
  final macroCategories = [
    "Mixed",
    "Programming",
    "Algorithms",
    "Data & AI",
    "Databases",
    "Systems",
    "Soft Skills",
  ];

  /// Firestore’dan gelen gerçek topicler
  final rawTopics = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTopics();
  }

  Future<void> loadTopics() async {
    try {
      isLoading.value = true;

      final snap =
          await FirebaseFirestore.instance.collection('questions').get();

      final questions =
          snap.docs.map((d) => Question.fromFirestore(d.data(), d.id)).toList();

      final uniqueTopics = questions
          .map((q) => q.topic)
          .where((t) => t != null && t!.isNotEmpty)
          .map((t) => t!)
          .toSet()
          .toList();

      rawTopics.assignAll(uniqueTopics);
    } catch (e) {
      print("Duel topic load error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(int index) {
    selectedIndex.value = index;
  }

  String get selectedMacro => macroCategories[selectedIndex.value];

  /// Macro → gerçek topic mapping
  List<String> getMappedTopics() {
    switch (selectedMacro) {
      case "Programming":
        return rawTopics
            .where((t) =>
                t.contains("C") || t.contains("Java") || t.contains("Python"))
            .toList();

      case "Algorithms":
        return rawTopics
            .where(
                (t) => t.contains("Algorithm") || t.contains("Data Structure"))
            .toList();

      case "Data & AI":
        return rawTopics
            .where((t) => t.contains("Data Science") || t.contains("Machine"))
            .toList();

      case "Databases":
        return rawTopics.where((t) => t.contains("SQL")).toList();

      case "Systems":
        return rawTopics
            .where((t) => t.contains("Network") || t.contains("Git"))
            .toList();

      case "Soft Skills":
        return rawTopics.where((t) => t.contains("Soft")).toList();

      case "Mixed":
      default:
        return rawTopics;
    }
  }
}
