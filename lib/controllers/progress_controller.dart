// ===================== File: lib/controllers/progress_controller.dart =====================
// Purpose: Kullanıcının ilerleme durumunu (XP, level, accuracy, solved, streak, vb.)
//          Firestore'dan gerçek zamanlı olarak dinler ve UI'a aktarır.
// Notes:
// - Firestore: users/{uid}
// - Dinlenen alanlar: xp, level, todayXp, weeklyXp, streakDays, savedCount, correct, totalSolved
// ==============================================================================

import 'package:get/get.dart' hide Progress;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress.dart';
import '../services/sfx/sound_service.dart';

class ProgressController extends GetxController {
  final Rx<Progress> progress = Progress.initial().obs;

  // Firestore’dan anlık alanlar
  final RxInt totalXp = 0.obs;
  final RxInt level = 1.obs;
  final RxInt todayXp = 0.obs;
  final RxInt weeklyXp = 0.obs;
  final RxInt streakDays = 0.obs;
  final RxInt savedCount = 0.obs;
  final RxInt correct = 0.obs;
  final RxInt totalSolved = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenUserProgress(); // 🔥 Firestore listener
  }

  void _listenUserProgress() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() ?? {};

      // Firestore’daki değerleri güncelle
      totalXp.value = (data['totalXp'] ?? data['xp'] ?? 0) as int;

      // 🔊 Level up detection
      final oldLevel = level.value;
      level.value = (data['level'] ?? 1) as int;
      if (level.value > oldLevel && oldLevel > 0) {
        SoundService.play(SoundEffect.levelUp);
      }

      todayXp.value = (data['todayXp'] ?? 0) as int;
      weeklyXp.value = (data['weeklyXp'] ?? 0) as int;
      streakDays.value = (data['streakDays'] ?? 0) as int;
      savedCount.value = (data['savedCount'] ?? 0) as int;
      correct.value = (data['correct'] ?? 0) as int;
      totalSolved.value = (data['totalSolved'] ?? 0) as int;

      // Progress modelini güncelle
      progress.value = progress.value.copyWith(
        totalXp: totalXp.value,
        // Eğer Progress modelinde varsa ekle:
        todayEarnedXp: todayXp.value,
        weeklyEarnedXp: weeklyXp.value,
        questionStats: progress.value.questionStats.copyWith(
          correct: correct.value,
          total: totalSolved.value,
        ),
      );
    });
  }

  // Local ekleme (opsiyonel, fallback)
  void addXp(int delta) {
    progress.value = progress.value.addXp(delta);
    totalXp.value = progress.value.totalXp;
  }

  void rolloverToNewDay() {
    progress.value = progress.value.rolloverToNewDay();
  }
}
