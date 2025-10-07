import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/progress_controller.dart';
import '../../../controllers/question_controller.dart';
import '../../../models/question.dart';
import '../../../models/streak.dart';

class HomeController extends GetxController {
  final _rng = Random();

  /// Today’s Popular Questions
  final RxList<Question> popularQuestions = <Question>[].obs;

  /// Progress (Your Progress bölümünü besler)
  final ProgressController pc =
      Get.put<ProgressController>(ProgressController(), permanent: true);

  // 🔥 STREAK SECTION START
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final streak = Rxn<Streak>();
  final isStreakLoading = false.obs;

  void listenToUserStreak() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      _db.collection('users').doc(uid).snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final streakData = data['streak'] ?? {}; // 🔹 nested streak objesi
          streak.value = Streak.fromMap({
            'lastStreakDate': streakData['lastStreakDate'],
            'longestStreak': streakData['longestStreak'],
            'streakCount': streakData['streakCount'],
            'streakHistory': streakData['streakHistory'],
          });
        }
      });
    } catch (e) {
      print('🔥 listenToUserStreak error: $e');
    }
  }
  // 🔥 STREAK SECTION END

  @override
  void onInit() {
    super.onInit();
    _loadPopularQuestions();
    listenToUserStreak(); // 🔥 streak dinleyicisini başlat
  }

  /// Easy / Medium / Hard’tan rastgele 1’er soru seç
  void _loadPopularQuestions() {
    final qc = Get.find<QuestionController>();

    Question? pickOne(Difficulty d) {
      final pool = qc.allQuestions.where((q) => q.difficulty == d).toList();
      if (pool.isEmpty) return null;
      return pool[_rng.nextInt(pool.length)];
    }

    final picks = <Question>[
      if (pickOne(Difficulty.easy) != null) pickOne(Difficulty.easy)!,
      if (pickOne(Difficulty.medium) != null) pickOne(Difficulty.medium)!,
      if (pickOne(Difficulty.hard) != null) pickOne(Difficulty.hard)!,
    ];

    popularQuestions.assignAll(picks);
  }

  /// Pull-to-refresh’te çağır
  Future<void> refreshAll() async {
    _loadPopularQuestions();
    // ileride: user/progress güncellemesi eklenebilir
  }
}
