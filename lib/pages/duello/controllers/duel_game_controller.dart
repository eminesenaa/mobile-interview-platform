import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../models/duel_match.dart';
import '../../../models/duel_enums.dart';
import '../../../models/duel_player.dart';
import '../../../models/question.dart';
import '../../../services/firebase/firebase_duel_game_service.dart';
import '../../../utils/duel_scoring_engine.dart';
import '../duel_result_page.dart';

class DuelGameController extends GetxController {
  final DuelMatch initialMatch;
  DuelGameController(this.initialMatch);

  // ─────────────────────────────────────────
  // REACTIVE STATE
  // ─────────────────────────────────────────
  final match = Rx<DuelMatch?>(null);
  final remainingSeconds = 0.obs;
  final isLoadingQuestions = true.obs;
  final comboCount = 0.obs;

  // Reaktif player listesi — Firestore'dan gelen her snapshot UI'ı günceller
  final players = <DuelPlayer>[].obs;
  final forceUpdate = 0.obs;

  // ─────────────────────────────────────────
  // SERVICES & INTERNALS
  // ─────────────────────────────────────────
  final _gameService = FirebaseDuelGameService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _questionTimer;
  StreamSubscription<DuelMatch>? _matchSubscription;

  /// Local user'ın bu round'da cevap verip vermediği (Firestore'a yazılıncaya kadar guard)
  bool _hasSubmittedThisRound = false;

  /// Reveal sonrası advanceQuestion çağrılıp çağrılmadığını track et
  bool _isAdvancing = false;

  /// reveal timer referansı
  Timer? _revealTimer;

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
    _revealTimer?.cancel();
    _matchSubscription?.cancel();
    _gameService.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────
  // INIT — Soruları yükle, listener bağla
  // ─────────────────────────────────────────
  Future<void> _initializeGame() async {
    final currentMatch = match.value;
    if (currentMatch == null) return;

    // Sorular zaten match dokümanında varsa doğrudan kullan
    if (currentMatch.questions.isNotEmpty) {
      isLoadingQuestions.value = false;
    } else {
      // Fallback: Firestore'dan çek
      isLoadingQuestions.value = true;
      try {
        final questions = await _fetchQuestionsFromFirestore(
          category: initialMatch.category ?? 'Mixed',
          count: 10,
        );
        currentMatch.questions.clear();
        currentMatch.questions.addAll(questions);
      } catch (e) {
        print('❌ [GAME] Question fetch failed: $e');
      } finally {
        isLoadingQuestions.value = false;
        _syncPlayers();
      }
    }

    // 🔥 Real-time Firestore listener — tek kaynak
    _startFirestoreListener();
    _startTimer();
  }

  // ─────────────────────────────────────────
  // FIRESTORE LISTENER — single source of truth
  // ─────────────────────────────────────────
  void _startFirestoreListener() {
    final matchId = initialMatch.matchId;
    if (matchId.isEmpty) return;

    _matchSubscription?.cancel();
    _matchSubscription = _gameService.listenToMatch(matchId).listen(
      (updatedMatch) {
        if (isClosed) return;

        final previousPhase = match.value?.questionPhase;
        final previousIndex = match.value?.currentQuestionIndex ?? 0;

        // Firestore'dan gelen state → local state'i güncelle
        match.value = updatedMatch;
        players.value = updatedMatch.players.map((p) => p.snapshot()).toList();
        forceUpdate.value++;

        // ── STATUS DEĞİŞİMLERİ ──

        // 1. Match iptal edildi (rakip çıktı)
        if (updatedMatch.status == DuelStatus.cancelled) {
          _questionTimer?.cancel();
          Get.snackbar(
            'Düello İptal',
            'Rakibiniz ayrıldı.',
            snackPosition: SnackPosition.BOTTOM,
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (!isClosed) Get.back();
          });
          return;
        }

        // 2. Match bitti
        if (updatedMatch.status == DuelStatus.finished) {
          _questionTimer?.cancel();
          final result = updatedMatch.buildResult();
          Get.off(() => const DuelResultPage(), arguments: result);
          return;
        }

        // 3. Reveal fazına geçildi — timer durdur
        if (updatedMatch.questionPhase == DuelQuestionPhase.reveal &&
            previousPhase != DuelQuestionPhase.reveal) {
          _questionTimer?.cancel();
          _scheduleAdvance(updatedMatch);
        }

        // 4. Yeni soruya geçildi — timer sıfırla
        if (updatedMatch.questionPhase == DuelQuestionPhase.active &&
            updatedMatch.currentQuestionIndex != previousIndex) {
          _hasSubmittedThisRound = false;
          _isAdvancing = false;
          _startTimer();
        }
      },
      onError: (error) {
        print('❌ [GAME] Firestore listener error: $error');
      },
    );
  }

  // ─────────────────────────────────────────
  // PLAYER SYNC
  // ─────────────────────────────────────────
  void _syncPlayers() {
    final current = match.value?.players ?? [];
    players.value = current.map((p) => p.snapshot()).toList();
    forceUpdate.value++;
  }

  // ─────────────────────────────────────────
  // TIMER — lokal countdown
  // ─────────────────────────────────────────
  void _startTimer() {
    _questionTimer?.cancel();
    remainingSeconds.value = 10;

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        // Süre doldu — eğer local user henüz cevap vermediyse boş bırak
        // Firestore tarafında diğer oyuncunun cevabı zaten var/yok
        // Reveal'ı tetikle (sadece bir taraf tetikler, idempotent)
        _triggerRevealIfNeeded();
      }
    });
  }

  // ─────────────────────────────────────────
  // KULLANICI CEVAP — Firestore'a yaz
  // ─────────────────────────────────────────
  void selectOption(int optionIndex) {
    final currentMatch = match.value;
    if (currentMatch == null) return;
    if (currentMatch.questionPhase != DuelQuestionPhase.active) return;
    if (_hasSubmittedThisRound) return;

    _hasSubmittedThisRound = true;
    final localId = _localUserId();
    final question = currentMatch.currentQuestion;
    if (question == null) return;

    // Doğru/yanlış hesapla
    bool isCorrect = false;
    if (question.correctAnswer != null && question.options != null) {
      final correctStr = question.correctAnswer!.trim();
      final correctIndex = int.tryParse(correctStr);
      if (correctIndex != null) {
        isCorrect = optionIndex == correctIndex;
      } else if (optionIndex < question.options!.length) {
        isCorrect = question.options![optionIndex].trim() == correctStr;
      }
    }

    // Combo takibi (lokal)
    if (isCorrect) {
      comboCount.value++;
    } else {
      comboCount.value = 0;
    }

    // Skor hesapla
    final answerTime = 10 - remainingSeconds.value;
    final scoreResult = DuelScoringEngine.evaluateAnswer(
      isCorrect: isCorrect,
      answerTimeSeconds: answerTime,
    );

    // 🔥 Firestore'a atomik yaz
    _gameService
        .submitAnswer(
      matchId: currentMatch.matchId,
      userId: localId,
      selectedOptionIndex: optionIndex,
      answerTimeSeconds: answerTime,
      isCorrect: isCorrect,
      scoreGained: scoreResult.scoreGained,
      xpGained: scoreResult.xpGained,
    )
        .then((_) {
      // Cevap yazıldı → tüm oyuncular cevap verdi mi kontrol et
      _gameService.checkAndReveal(
        matchId: currentMatch.matchId,
        expectedPlayerCount: currentMatch.players.length,
      );
    });
  }

  // ─────────────────────────────────────────
  // REVEAL & ADVANCE
  // ─────────────────────────────────────────

  /// Süre dolduğunda veya tüm oyuncular cevap verdiğinde reveal tetikle
  void _triggerRevealIfNeeded() {
    final currentMatch = match.value;
    if (currentMatch == null) return;
    if (currentMatch.questionPhase == DuelQuestionPhase.reveal) return;

    // Firestore'da phase'i reveal yap (idempotent)
    _firestore.collection('matches').doc(currentMatch.matchId).update({
      'questionPhase': 'reveal',
    });
  }

  /// Reveal fazı başladıktan 2.5 sn sonra sonraki soruya ilerlet
  void _scheduleAdvance(DuelMatch currentMatch) {
    if (_isAdvancing) return;
    _isAdvancing = true;

    _revealTimer?.cancel();
    _revealTimer = Timer(const Duration(milliseconds: 2500), () {
      if (isClosed) return;

      _gameService.advanceToNextQuestion(
        matchId: currentMatch.matchId,
        currentIndex: currentMatch.currentQuestionIndex,
        totalQuestions: currentMatch.questions.length,
      );
    });
  }

  // ─────────────────────────────────────────
  // DISCONNECT
  // ─────────────────────────────────────────
  Future<void> disconnectFromMatch() async {
    final currentMatch = match.value;
    if (currentMatch == null) return;
    await _gameService.handleDisconnect(currentMatch.matchId);
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  String _localUserId() =>
      FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  // ─────────────────────────────────────────
  // FIRESTORE SORU ÇEKME (FALLBACK)
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
