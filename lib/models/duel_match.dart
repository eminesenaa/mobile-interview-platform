// lib/models/duel_match.dart

import '../utils/duel_scoring_engine.dart';
import 'duel_result.dart';
import 'question.dart';
import 'duel_player.dart';
import 'duel_enums.dart';

class DuelMatch {
  final String matchId;
  final List<DuelPlayer> players;
  final List<Question> questions;
  final String? category;

  int currentQuestionIndex;
  DuelStatus status;
  DuelQuestionPhase questionPhase;

  final DateTime createdAt;
  DateTime? startedAt;
  DateTime? finishedAt;

  DuelMatch({
    required this.matchId,
    required this.players,
    required this.questions,
    this.category,
    this.currentQuestionIndex = 0,
    this.status = DuelStatus.idle,
    this.questionPhase = DuelQuestionPhase.active,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
  });

  // --- GETTERS ---

  Question? get currentQuestion =>
      questions.isNotEmpty && currentQuestionIndex < questions.length
          ? questions[currentQuestionIndex]
          : null;

  bool get isLastQuestion =>
      questions.isEmpty ? true : currentQuestionIndex == questions.length - 1;

  bool get allPlayersAnswered =>
      players.every((player) => player.answeredCurrentQuestion);

  // --- METHODS ---

  void moveToNextQuestion() {
    if (!isLastQuestion) {
      currentQuestionIndex++;
      questionPhase = DuelQuestionPhase.active;
      for (final player in players) {
        player.resetForNextQuestion();
      }
    } else {
      finalizeMatch();
    }
  }

  void submitAnswer({
    required String userId,
    required int selectedOptionIndex,
    required int answerTimeSeconds,
  }) {
    // Sadece oyun devam ederken cevap kabul et
    if (status != DuelStatus.inProgress) return;

    // 🔥 KRİTİK GÜNCELLEME: "Bad state: No element" hatasını önlemek için orElse eklendi
    final player = players.firstWhere(
      (p) => p.userId == userId,
      orElse: () {
        print('⚠️ [Match] Player not found: $userId');
        return players.first;
      },
    );

    if (player.answeredCurrentQuestion) return;

    player.answeredCurrentQuestion = true;
    player.selectedOptionIndex = selectedOptionIndex;
    player.answerTimeSeconds = answerTimeSeconds;

    final question = currentQuestion;
    if (question == null) return;

    bool isCorrect = false;

    // 🔥 KRİTİK GÜNCELLEME: Karşılaştırma mantığı agresif trim ve null check ile güçlendirildi
    if (question.correctAnswer != null) {
      final String correctStr = question.correctAnswer.toString().trim();
      final String selectedStr = selectedOptionIndex.toString();

      // Hem index (0,1,2..) hem de metin bazlı kontrolü destekle
      isCorrect = (selectedStr == correctStr) ||
          (question.options != null &&
              selectedOptionIndex < question.options!.length &&
              question.options![selectedOptionIndex].trim() == correctStr);
    }

    final scoreResult = DuelScoringEngine.evaluateAnswer(
      isCorrect: isCorrect,
      answerTimeSeconds: answerTimeSeconds,
    );

    player.score += scoreResult.scoreGained;
    player.totalXpGained += scoreResult.xpGained;

    if (isCorrect) {
      player.correctCount += 1;
    }

    // Tüm oyuncular cevap verdiyse sonuçları göster
    if (allPlayersAnswered) {
      questionPhase = DuelQuestionPhase.reveal;
    } else {
      questionPhase = DuelQuestionPhase.waiting;
    }
  }

  void finalizeMatch() {
    if (status == DuelStatus.finished || players.isEmpty) return;

    status = DuelStatus.finished;
    finishedAt = DateTime.now();

    final maxScore =
        players.map((p) => p.score).reduce((a, b) => a > b ? a : b);
    final winners = players.where((p) => p.score == maxScore).toList();
    final fullBonus = DuelScoringEngine.calculateWinBonusXp(true);

    if (winners.length == 1) {
      winners.first.totalXpGained += fullBonus;
    } else {
      final halfBonus = fullBonus ~/ 2;
      for (final player in winners) {
        player.totalXpGained += halfBonus;
      }
    }
  }

  DuelResult buildResult() {
    if (status != DuelStatus.finished) {
      finalizeMatch();
    }

    final scoreMap = <String, int>{};
    final xpMap = <String, int>{};
    final accuracyMap = <String, double>{};

    for (final player in players) {
      scoreMap[player.userId] = player.score;
      xpMap[player.userId] = player.totalXpGained;
      accuracyMap[player.userId] =
          questions.isEmpty ? 0.0 : player.correctCount / questions.length;
    }

    // Kazananı belirle
    final winner = players.reduce((a, b) => a.score >= b.score ? a : b);

    return DuelResult(
      winnerId: winner.userId,
      scoreMap: scoreMap,
      xpGainedMap: xpMap,
      accuracyMap: accuracyMap,
      totalDuration:
          (finishedAt ?? DateTime.now()).difference(startedAt ?? createdAt),
    );
  }
}
