import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../controllers/progress_controller.dart';
import '../../../controllers/question_controller.dart';
import '../../../models/question.dart';
import '../../../models/streak.dart';
import '../../../models/leaderboard.dart';
import '../services/leaderboard_service.dart';

class HomeController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Services
  final LeaderboardService _leaderboardService = LeaderboardService();

  /// Popular questions (DAILY – GLOBAL)
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

  /// Internal flag (HOT RESTART fix)
  bool _popularLoadedOnce = false;

  /// 🔥 Leaderboard stream subscription
  StreamSubscription? _leaderboardSubscription;

  // ------------------ LIFECYCLE ------------------
  @override
  void onInit() {
    super.onInit();

    final qc = Get.find<QuestionController>();

    if (qc.allQuestions.isNotEmpty) {
      loadDailyPopularQuestions();
    } else {
      ever(qc.allQuestions, (_) {
        if (!_popularLoadedOnce && qc.allQuestions.isNotEmpty) {
          loadDailyPopularQuestions();
        }
      });
    }

    _checkStreakOnAppStart().then((_) {
      listenToUserStreak();
    });

    listenToLeaderboard();
  }

  @override
  void onClose() {
    _leaderboardSubscription?.cancel();
    super.onClose();
  }

  // ------------------ DATE KEY ------------------
  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // ------------------ STREAK CHECK ON APP START ------------------
  Future<void> _checkStreakOnAppStart() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await Streak.checkAndResetStreakIfNeeded(uid);
    } catch (e) {
      print('🔥 _checkStreakOnAppStart error: $e');
    }
  }

  // ------------------ STREAK ------------------
  void listenToUserStreak() {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      _db.collection('users').doc(uid).snapshots().listen((doc) {
        if (!doc.exists || doc.data() == null) return;

        final streakData = doc.data()!['streak'] ?? {};
        streak.value = Streak.fromMap({
          'lastStreakDate': streakData['lastStreakDate'],
          'longestStreak': streakData['longestStreak'],
          'streakCount': streakData['streakCount'],
          'streakHistory': streakData['streakHistory'],
        });
      });
    } catch (e) {
      print('🔥 listenToUserStreak error: $e');
    }
  }

  // ------------------ POPULAR QUESTIONS (DAILY / GLOBAL) ------------------
  Future<void> loadDailyPopularQuestions() async {
    try {
      final qc = Get.find<QuestionController>();
      if (qc.allQuestions.isEmpty) return;

      final todayKey = _todayKey();
      final docRef = _db.collection('daily_popular_questions').doc(todayKey);

      final snap = await docRef.get();

      // ---- BUGÜN VARSA → SABİT LİSTEYİ KULLAN ----
      if (snap.exists && snap.data() != null) {
        final ids = List<String>.from(snap['questionIds']);

        final questionMap = {
          for (var q in qc.allQuestions) q.id: q,
        };

        popularQuestions.assignAll(
          ids
              .where(questionMap.containsKey)
              .map((id) => questionMap[id]!)
              .toList(),
        );

        _popularLoadedOnce = true;
        return;
      }

      // ---- BUGÜN YOKSA → OLUŞTUR ----
      final easy = qc.allQuestions
          .where((q) => q.difficulty == Difficulty.easy)
          .toList();
      final medium = qc.allQuestions
          .where((q) => q.difficulty == Difficulty.medium)
          .toList();
      final hard = qc.allQuestions
          .where((q) => q.difficulty == Difficulty.hard)
          .toList();

      Question? pick(List<Question> list) =>
          list.isEmpty ? null : list[Random().nextInt(list.length)];

      final selected = <Question>[
        if (pick(easy) != null) pick(easy)!,
        if (pick(medium) != null) pick(medium)!,
        if (pick(hard) != null) pick(hard)!,
      ];

      await docRef.set({
        'date': todayKey,
        'questionIds': selected.map((q) => q.id).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      popularQuestions.assignAll(selected);
      _popularLoadedOnce = true;
    } catch (e) {
      print('🔥 loadDailyPopularQuestions error: $e');
    }
  }

  // ------------------ LEADERBOARD (REALTIME) ------------------
  void listenToLeaderboard() {
    lbLoading.value = true;

    try {
      _leaderboardSubscription =
          _leaderboardService.watchLeaderboardData().listen((data) {
        top3.assignAll(data['top3']);
        me.value = data['me'];
        lbLoading.value = false;
      }, onError: (e) {
        print('🔥 Leaderboard stream error: $e');
        lbLoading.value = false;
      });
    } catch (e) {
      print('🔥 listenToLeaderboard error: $e');
      lbLoading.value = false;
    }
  }

  /// 🔹 Manuel refresh (opsiyonel - pull-to-refresh için)
  Future<void> fetchLeaderboard() async {
    lbLoading.value = true;
    try {
      final data = await _leaderboardService.fetchLeaderboardData();
      top3.assignAll(data['top3']);
      me.value = data['me'];
    } catch (e) {
      print('🔥 Home fetchLeaderboard error: $e');
    } finally {
      lbLoading.value = false;
    }
  }

  // ------------------ REFRESH ------------------
  Future<void> refreshAll() async {
    // Streak kontrolü
    await _checkStreakOnAppStart();

    // Leaderboard zaten realtime, sadece popular questions'ı refresh edelim
    await loadDailyPopularQuestions();
  }
}
