// lib/pages/duello/controllers/duel_result_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/duel_result.dart';
import 'package:interview_project/services/firebase/duel_service.dart';

class DuelResultController extends GetxController {
  final isApplyingXp = true.obs;
  final xpApplyError = false.obs;

  late final DuelResult result;
  late final String localUserId;

  @override
  void onInit() {
    super.onInit();
    result = Get.arguments as DuelResult;
    localUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _applyXp();
  }

  // ── Getters ──
  bool get isWinner => result.winnerId == localUserId;
  int get myScore => result.scoreMap[localUserId] ?? 0;
  int get myXp => result.xpGainedMap[localUserId] ?? 0;
  double get myAccuracyPercent =>
      (result.accuracyMap[localUserId] ?? 0.0) * 100;
  int get myCombo => result.comboMap?[localUserId] ?? 0;

  /// Kişiselleştirilmiş mesaj
  String get personalMessage {
    final acc = myAccuracyPercent;
    final combo = myCombo;

    if (isWinner) {
      if (acc == 100) return 'Perfect score! Unbeatable! 🏆';
      if (combo >= 5) return 'On a hot streak! 🔥';
      if (acc >= 80) return 'Dominant victory! 💪';
      return 'Victory! Well played! 🎉';
    } else {
      if (acc == 0) return 'Keep going, you\'ll get there! 💙';
      if (acc >= 60) return 'So close! Keep pushing! ⚡';
      if (combo >= 3) return 'Great combo, bad luck! 😤';
      return 'Defeated... but not done! 🔄';
    }
  }

  Future<void> _applyXp() async {
    try {
      isApplyingXp.value = true;
      xpApplyError.value = false;
      await DuelService().applyXpToUsers(result);
      print('✅ [RESULT] XP Firestore\'a başarıyla yazıldı.');
    } catch (e) {
      print('❌ [RESULT] XP yazma hatası: $e');
      xpApplyError.value = true;
    } finally {
      isApplyingXp.value = false;
    }
  }

  Future<void> retryApplyXp() => _applyXp();
}
