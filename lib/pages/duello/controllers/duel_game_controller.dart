import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../models/duel_match.dart';
import '../../../models/duel_enums.dart';
import '../../../models/duel_player.dart';
import '../../../models/question.dart';
import '../duel_result_page.dart';

class DuelGameController extends GetxController {
  final DuelMatch initialMatch;
  DuelGameController(this.initialMatch);

  final match = Rx<DuelMatch?>(null);
  final remainingSeconds = 0.obs;
  final isLoadingQuestions = true.obs;
  final comboCount = 0.obs;

  // Reaktif player listesi — bot cevap verince UI güncellenir
  final players = <DuelPlayer>[].obs;
  final forceUpdate = 0.obs; // sadece rebuild tetiklemek için

  Timer? _questionTimer;
  final List<Timer> _botTimers = [];
  final _random = Random();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    match.value = initialMatch;
    players.assignAll(initialMatch.players);
    _initializeGame();
  }

  @override
  void onClose() {
    _questionTimer?.cancel();
    for (final t in _botTimers) t.cancel();
    _botTimers.clear();
    super.onClose();
  }

  // ─────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────
  Future<void> _initializeGame() async {
    final currentMatch = match.value;
    if (currentMatch == null) return;

    if (currentMatch.questions.isNotEmpty) {
      isLoadingQuestions.value = false;
    } else {
      isLoadingQuestions.value = true;
      try {
        final questions = await _fetchQuestionsFromFirestore(
          category: initialMatch.category ?? 'Mixed',
          count: 10,
        );
        currentMatch.questions.clear();
        currentMatch.questions.addAll(questions);
      } catch (e) {
        print('❌ [GAME] Fallback failed: $e');
      } finally {
        isLoadingQuestions.value = false;
        _syncPlayers();
      }
    }

    _startQuestion();
  }

  // ─────────────────────────────────────────
  // Player listesini reaktif obs ile senkronize et
  // ─────────────────────────────────────────
  void _syncPlayers() {
    final current = match.value?.players ?? [];
    players.value = current.map((p) => p.snapshot()).toList();
    forceUpdate.value++; // Obx'i kesin tetikler
  }

  // ─────────────────────────────────────────
  // SORU BAŞLAT
  // ─────────────────────────────────────────
  void _startQuestion() {
    final currentMatch = match.value!;
    if (currentMatch.questions.isEmpty) return;

    remainingSeconds.value = 10;
    currentMatch.questionPhase = DuelQuestionPhase.active;

    for (final p in currentMatch.players) {
      p.resetForNextQuestion();
    }

    _syncPlayers();
    match.refresh();
    _startTimer();
    _scheduleBotAnswers();
  }

  // ─────────────────────────────────────────
  // TIMER
  // ─────────────────────────────────────────
  void _startTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        _forceReveal();
      }
    });
  }

  // ─────────────────────────────────────────
  // BOT SİMÜLASYONU
  // ─────────────────────────────────────────
  void _scheduleBotAnswers() {
    for (final t in _botTimers) t.cancel();
    _botTimers.clear();

    final currentMatch = match.value!;
    final localId = _localUserId();
    final bots =
        currentMatch.players.where((p) => p.userId != localId).toList();

    for (final bot in bots) {
      // Her bot 2-15 sn arası cevap verir
      final delay = Duration(seconds: 2 + _random.nextInt(14));
      final t = Timer(delay, () {
        if (isClosed) return;
        if (currentMatch.questionPhase != DuelQuestionPhase.active) return;
        if (bot.answeredCurrentQuestion) return;

        final optionCount = currentMatch.currentQuestion?.options?.length ?? 4;
        final botOptionIndex = _random.nextInt(optionCount);

        // %60 doğru yapma şansı
        final isCorrect = _random.nextDouble() < 0.6;

        bot.answeredCurrentQuestion = true;
        bot.selectedOptionIndex = botOptionIndex;

        if (isCorrect) {
          bot.correctCount += 1;
          bot.score += 3;
        }

        // Reaktif güncelleme — UI anında görür
        _syncPlayers();
        match.refresh();

        if (currentMatch.allPlayersAnswered) {
          _questionTimer?.cancel();
          _forceReveal();
        }
      });
      _botTimers.add(t);
    }
  }

  // ─────────────────────────────────────────
  // KULLANICI CEVAP
  // ─────────────────────────────────────────
  void selectOption(int optionIndex) {
    final currentMatch = match.value!;
    if (currentMatch.questionPhase != DuelQuestionPhase.active) return;

    final localId = _localUserId();

    // Combo hesapla
    final question = currentMatch.currentQuestion;
    bool isCorrect = false;
    if (question?.correctAnswer != null && question?.options != null) {
      final correctStr = question!.correctAnswer!.trim();
      final correctIndex = int.tryParse(correctStr);
      if (correctIndex != null) {
        isCorrect = optionIndex == correctIndex;
      } else if (optionIndex < question.options!.length) {
        isCorrect = question.options![optionIndex].trim() == correctStr;
      }
    }

    if (isCorrect) {
      comboCount.value++;
    } else {
      comboCount.value = 0;
    }

    // Max combo kaydet
    final localPlayer = currentMatch.players.firstWhere(
      (p) => p.userId == localId,
      orElse: () => currentMatch.players.first,
    );
    if (comboCount.value > localPlayer.comboCount) {
      localPlayer.comboCount = comboCount.value;
    }

    currentMatch.submitAnswer(
      userId: localId,
      selectedOptionIndex: optionIndex,
      answerTimeSeconds: 30 - remainingSeconds.value,
    );

    _syncPlayers();
    match.refresh();

    if (currentMatch.allPlayersAnswered) {
      _questionTimer?.cancel();
      for (final t in _botTimers) t.cancel();
      _forceReveal();
    }
  }

  // ─────────────────────────────────────────
  // REVEAL
  // ─────────────────────────────────────────
  void _forceReveal() {
    final currentMatch = match.value!;
    currentMatch.questionPhase = DuelQuestionPhase.reveal;
    _syncPlayers();
    match.refresh();

    Future.delayed(const Duration(seconds: 2), _afterReveal);
  }

  void _afterReveal() {
    final currentMatch = match.value!;
    if (currentMatch.isLastQuestion) {
      currentMatch.finalizeMatch();
      final result = currentMatch.buildResult();
      Get.off(() => const DuelResultPage(), arguments: result);
    } else {
      currentMatch.moveToNextQuestion();
      _syncPlayers();
      match.refresh();
      _startQuestion();
    }
  }

  String _localUserId() =>
      FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  // ─────────────────────────────────────────
  // FIRESTORE FALLBACK
  // ─────────────────────────────────────────
  Future<List<Question>> _fetchQuestionsFromFirestore({
    required String category,
    required int count,
  }) async {
    Query query =
        _firestore.collection('questions').where('type', isEqualTo: 'MCQ');

    if (category != 'Mixed') {
      final topics = _getMappedTopics(category);
      if (topics.isNotEmpty) {
        query = query.where('topic', whereIn: topics.take(30).toList());
      }
    }

    final snapshot = await query.limit(count * 3).get();
    if (snapshot.docs.isEmpty) throw Exception('Soru bulunamadı.');

    final all = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Question.fromFirestore(data, doc.id).copyWith(
        description:
            (data['text'] ?? data['description'] ?? '').toString().trim(),
        options: data['options'] != null
            ? List<String>.from(
                (data['options'] as List).map((o) => o.toString().trim()))
            : [],
        correctAnswer: data['correctAnswer']?.toString().trim(),
      );
    }).where((q) {
      return q.type == QuestionType.mcq &&
          q.options != null &&
          q.options!.length >= 2 &&
          q.correctAnswer != null &&
          q.correctAnswer!.isNotEmpty;
    }).toList();

    all.shuffle();
    return all.take(count).toList();
  }

  List<String> _getMappedTopics(String cat) {
    switch (cat) {
      case 'Programming Languages':
        return ['C / C++', 'Java', 'Python'];
      case 'Algorithms & Data Structures':
        return ['Algorithms', 'Data Structures'];
      case 'Data & AI':
        return ['Data Science', 'Machine Learning', 'SQL'];
      case 'Systems & Networking':
        return ['Network', 'Git'];
      case 'Soft Skills':
        return ['Soft Skills'];
      default:
        return [];
    }
  }
}
