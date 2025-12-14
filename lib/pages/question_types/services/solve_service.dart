/*
 * lib/services/solve/solve_service.dart
 * Practice soru sonuçlarını Firestore'a kaydeder
 * XP ekleme + improved score kontrolü + streak yönetimi
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../models/question.dart';
import '../../../models/streak.dart';
import '../../../controllers/auth_controller.dart';

class SolveService {
  static final _db = FirebaseFirestore.instance;

  /// Practice soru çözümü kaydı
  static Future<void> savePracticeResult({
    required Question question,
    required int score,
    required int earnedXp,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print("❌ SolveService: UID is NULL!");
        return;
      }

      final userRef = _db.collection('users').doc(uid);
      final solvedRef = userRef.collection('solved').doc(question.id);

      final snap = await solvedRef.get();
      final newScore = score.toDouble();

      if (snap.exists) {
        final data = snap.data() ?? {};
        final prevScore = (data['score'] as num?)?.toDouble() ?? 0.0;
        final prevXp = (data['xpEarned'] as num?)?.toInt() ?? 0;

        if (newScore > prevScore) {
          final xpDiff = earnedXp - prevXp;

          if (xpDiff > 0) {
            await userRef.set({
              'totalXp': FieldValue.increment(xpDiff),
            }, SetOptions(merge: true));
          }

          await solvedRef.set({
            'score': newScore,
            'xpEarned': earnedXp,
            'lastAttempt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          await solvedRef.set({
            'lastAttempt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } else {
        // İlk kez çözülüyor
        await userRef.set({
          'totalXp': FieldValue.increment(earnedXp),
        }, SetOptions(merge: true));

        await solvedRef.set({
          'status': 'solved',
          'score': newScore,
          'xpEarned': earnedXp,
          'solvedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Streak güncelle
      await _updateStreak(uid);
    } catch (e, st) {
      print("❌ SolveService Error: $e\n$st");
    }
  }

  /// Tek streak güncelleme fonksiyonu
  static Future<void> _updateStreak(String uid) async {
    try {
      final auth = Get.find<AuthController>();
      final currentUid = auth.user?.uid ?? uid;

      await Streak.updateStreak(currentUid);
      print("🔥 Streak updated for user=$currentUid");
    } catch (e, st) {
      print("❌ Streak update error: $e\n$st");
    }
  }
}
