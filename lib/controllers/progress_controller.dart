import 'package:get/get.dart' hide Progress;
import '../models/progress.dart';

class ProgressController extends GetxController {
  final Rx<Progress> progress = Progress.initial().obs;

  // Expose for UI
  int get totalXp => progress.value.totalXp;
  int get xpInLevel => progress.value.xpInLevel;
  int get xpCap => progress.value.xpCapInLevel;
  double get levelProgress => progress.value.levelProgress;
  List<int> get weeklyXp => progress.value.weeklyXpLast7;

  // Actions
  void addXp(int delta) {
    progress.value = progress.value.addXp(delta);
  }

  void rolloverToNewDay() {
    progress.value = progress.value.rolloverToNewDay();
  }
}
