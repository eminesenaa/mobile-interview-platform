// lib/pages/duello/controllers/duel_result_controller.dart

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/duel_result.dart';
import 'package:interview_project/services/firebase/duel_service.dart';

import '../../../models/duel_player.dart';

class DuelResultController extends GetxController {
  final isApplyingXp = true.obs;
  final xpApplyError = false.obs;

  late final DuelResult result;
  late final String localUserId;

  late final ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    result = Get.arguments as DuelResult;
    localUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    /// 🎉 CONFETTI INIT
    confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    /// 🎯 SADECE WINNER
    if (isWinner) {
      confettiController.play();
    }

    _applyXp();
  }
  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }

  // ── Getters ──
  bool get isWinner => result.winnerId == localUserId;

  int get myScore => result.scoreMap[localUserId] ?? 0;

  int get myXp => result.xpGainedMap[localUserId] ?? 0;

  double get myAccuracyPercent =>
      (result.accuracyMap[localUserId] ?? 0.0) * 100;

  int get myCombo => result.comboMap?[localUserId] ?? 0;

  DuelPlayer get me => result.players.firstWhere(
        (p) => p.userId == localUserId,
      );

  String get username => me.username;

  String? get avatarUrl => me.avatarUrl;

  int get myRank {
    final sorted = [...result.players]
      ..sort((a, b) => b.score.compareTo(a.score));

    return sorted.indexWhere((p) => p.userId == localUserId) + 1;
  }

  /// Kişiselleştirilmiş mesaj
  String get personalMessage {
    final acc = myAccuracyPercent;
    final combo = myCombo;

    if (isWinner) {
      if (acc == 100) return 'Flawless performance. No mistakes.';
      if (combo >= 5) return 'Unstoppable streak. Excellent focus.';
      if (acc >= 80) return 'Strong performance. You dominated.';
      return 'Well played. Solid win.';
    } else {
      if (acc == 0) return 'Tough round. Reset and try again.';
      if (acc >= 60) return 'Almost there. Just a bit more.';
      if (combo >= 3) return 'Good momentum. Keep pushing.';
      return 'Not your round. Next one is yours.';
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
