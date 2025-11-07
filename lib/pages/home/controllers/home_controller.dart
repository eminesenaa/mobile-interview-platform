// ===================== File: lib/pages/home/controllers/home_controller.dart =====================
import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/progress_controller.dart';
import '../../../controllers/question_controller.dart';
import '../../../models/question.dart';
import '../../../models/streak.dart';
import '../../../models/leaderboard.dart';
import "../services/leaderboard_service.dart";



class HomeController extends GetxController {
  final _rng = Random();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Services
  final LeaderboardService _leaderboardService = LeaderboardService();

  /// Popular questions
  final RxList<Question> popularQuestions = <Question>[].obs;

  /// Progress
  final ProgressController pc =
      Get.put<ProgressController>(ProgressController(), permanent: true);

  /// Streak state
  final streak = Rxn<Streak>();
  final isStreakLoading = false.obs;

  /// Leaderboard state
  final lbLoading = true.obs;
  final RxList<TopUser> top3 = <TopUser>[].obs;
  final Rxn<MeRank> me = Rxn<MeRank>();

  @override
  void onInit() {
    super.onInit();
    _loadPopularQuestions();
    listenToUserStreak();
    fetchLeaderboard();
  }

  // ------------------ STREAK ------------------
  void listenToUserStreak() {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      _db.collection('users').doc(uid).snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final streakData = data['streak'] ?? {};
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

  // ------------------ POPULAR QUESTIONS ------------------
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

  // ------------------ LEADERBOARD (Servis Tabanlı) ------------------
  Future<void> fetchLeaderboard() async {
    lbLoading.value = true;
    try {
      final data = await _leaderboardService.fetchLeaderboardData();

      // Servisten dönen verileri UI’ya aktar
      top3.assignAll(data['top3']);
      me.value = data['me'];

      print("🏁 Home leaderboard updated → Me: ${me.value?.name}, Δ${me.value?.delta}");
    } catch (e) {
      print('🔥 Home fetchLeaderboard error: $e');
    } finally {
      lbLoading.value = false;
    }
  }

  // ------------------ REFRESH ------------------
  Future<void> refreshAll() async {
    await Future.wait([
      fetchLeaderboard(),
      Future.delayed(const Duration(milliseconds: 400), _loadPopularQuestions),
    ]);
  }
}
