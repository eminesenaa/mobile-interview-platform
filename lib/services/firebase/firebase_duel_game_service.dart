// ===================== File: lib/services/firebase/firebase_duel_game_service.dart =====================
// Purpose: Gerçek zamanlı 1v1 düello oyun servisi.
//          Firestore üzerinden answer/submit, round ilerletme, disconnect yönetimi.
//          Matchmaking değil — oyun başladıktan sonraki lifecycle'ı yönetir.
// ================================================================================================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/duel_match.dart';
import '../../models/duel_player.dart';
import '../../models/duel_enums.dart';
import '../../models/question.dart';

class FirebaseDuelGameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot>? _matchSubscription;

  // ─────────────────────────────────────────
  // MATCH LISTENER — tek kaynak, onSnapshot
  // ─────────────────────────────────────────

  /// Firestore `matches/{matchId}` dokümanına real-time listener bağlar.
  /// Her güncelleme `DuelMatch` olarak stream'e eklenir.
  Stream<DuelMatch> listenToMatch(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .where((snap) => snap.exists)
        .map((snap) => _mapFirestoreToMatch(matchId, snap.data()!));
  }

  // ─────────────────────────────────────────
  // SUBMIT ANSWER — atomik Firestore yazımı
  // ─────────────────────────────────────────

  /// Oyuncunun cevabını `currentRoundAnswers/{userId}` altına yazar.
  /// Score ve correctCount alanlarını FieldValue.increment ile atomik günceller.
  Future<void> submitAnswer({
    required String matchId,
    required String userId,
    required int selectedOptionIndex,
    required int answerTimeSeconds,
    required bool isCorrect,
    required int scoreGained,
    required int xpGained,
  }) async {
    final matchRef = _firestore.collection('matches').doc(matchId);

    final answerData = {
      'currentRoundAnswers.$userId': {
        'selectedOptionIndex': selectedOptionIndex,
        'answerTimeSeconds': answerTimeSeconds,
        'isCorrect': isCorrect,
      },
    };

    // Oyuncunun players array'indeki score/correctCount atomik güncelleme
    // NOT: Firestore arrayUnion ile nested field güncelleyemez.
    // Bu nedenle per-player top-level alanlar kullanıyoruz.
    final Map<String, dynamic> updates = {
      ...answerData,
      'playerScores.$userId': FieldValue.increment(scoreGained),
      'playerCorrectCounts.$userId': FieldValue.increment(isCorrect ? 1 : 0),
      'playerXp.$userId': FieldValue.increment(xpGained),
    };

    await matchRef.update(updates);
  }

  // ─────────────────────────────────────────
  // CHECK & ADVANCE ROUND
  // ─────────────────────────────────────────

  /// Her iki oyuncu cevap verdi mi kontrol eder.
  /// Verdiyse → reveal fazına geçirir.
  Future<void> checkAndReveal({
    required String matchId,
    required int expectedPlayerCount,
  }) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    final snapshot = await matchRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final answers = data['currentRoundAnswers'] as Map<String, dynamic>? ?? {};

    if (answers.length >= expectedPlayerCount) {
      // Tüm oyuncular cevap verdi → reveal
      await matchRef.update({'questionPhase': 'reveal'});
    }
  }

  /// Reveal bittikten sonra bir sonraki soruya ilerletir.
  /// Son soruysa match'i sonlandırır.
  Future<void> advanceToNextQuestion({
    required String matchId,
    required int currentIndex,
    required int totalQuestions,
  }) async {
    final matchRef = _firestore.collection('matches').doc(matchId);

    if (currentIndex >= totalQuestions - 1) {
      // Son soru — match bitti
      await matchRef.update({
        'status': 'finished',
        'questionPhase': 'reveal',
        'finishedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Sonraki soru
      await matchRef.update({
        'currentQuestionIndex': currentIndex + 1,
        'questionPhase': 'active',
        'currentRoundAnswers': {}, // Temizle
      });
    }
  }

  // ─────────────────────────────────────────
  // DISCONNECT HANDLING
  // ─────────────────────────────────────────

  /// Oyuncu koptuğunda match'i iptal eder.
  Future<void> handleDisconnect(String matchId) async {
    try {
      await _firestore.collection('matches').doc(matchId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ [GAME SERVICE] Disconnect error: $e');
    }
  }

  // ─────────────────────────────────────────
  // FIRESTORE → MODEL MAPPING
  // ─────────────────────────────────────────

  DuelMatch _mapFirestoreToMatch(String matchId, Map<String, dynamic> data) {
    // Player'ları parse et
    final playersRaw = data['players'] as List? ?? [];
    final playerScores = data['playerScores'] as Map<String, dynamic>? ?? {};
    final playerCorrectCounts =
        data['playerCorrectCounts'] as Map<String, dynamic>? ?? {};
    final playerXp = data['playerXp'] as Map<String, dynamic>? ?? {};

    final players = playersRaw.map((p) {
      final uid = p['userId'] ?? '';
      return DuelPlayer(
        userId: uid,
        username: p['username'] ?? 'Player',
        avatarUrl: p['avatarUrl'],
        score: playerScores[uid] as int? ?? p['score'] ?? 0,
        correctCount:
            playerCorrectCounts[uid] as int? ?? p['correctCount'] ?? 0,
        totalXpGained: playerXp[uid] as int? ?? p['totalXpGained'] ?? 0,
        comboCount: p['comboCount'] ?? 0,
      );
    }).toList();

    // currentRoundAnswers → player'lara bind et
    final roundAnswers =
        data['currentRoundAnswers'] as Map<String, dynamic>? ?? {};
    for (final player in players) {
      final answer = roundAnswers[player.userId] as Map<String, dynamic>?;
      if (answer != null) {
        player.answeredCurrentQuestion = true;
        player.selectedOptionIndex = answer['selectedOptionIndex'] as int?;
        player.answerTimeSeconds = answer['answerTimeSeconds'] as int?;
      }
    }

    // Soruları parse et — sert MCQ filtresi
    final questions = (data['questions'] as List? ?? []).map((q) {
      final qMap = q as Map<String, dynamic>;
      return Question.fromFirestore(qMap, qMap['id'] ?? '').copyWith(
        description:
            (qMap['text'] ?? qMap['description'] ?? '').toString().trim(),
        options: qMap['options'] != null
            ? List<String>.from(
                (qMap['options'] as List).map((o) => o.toString().trim()))
            : [],
        correctAnswer: qMap['correctAnswer']?.toString().trim(),
        type: QuestionType.mcq,
      );
    }).where((q) {
      return q.options != null &&
          q.options!.length >= 2 &&
          q.correctAnswer != null &&
          q.correctAnswer!.isNotEmpty;
    }).toList();

    return DuelMatch(
      matchId: matchId,
      players: players,
      questions: questions,
      currentQuestionIndex: data['currentQuestionIndex'] ?? 0,
      status: DuelStatus.values.firstWhere(
          (e) => e.name == (data['status'] ?? 'idle'),
          orElse: () => DuelStatus.idle),
      questionPhase: DuelQuestionPhase.values.firstWhere(
          (e) => e.name == (data['questionPhase'] ?? 'active'),
          orElse: () => DuelQuestionPhase.active),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
    );
  }

  // ─────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────

  void dispose() {
    _matchSubscription?.cancel();
  }
}
