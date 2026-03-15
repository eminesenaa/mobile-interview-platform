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
  final DuelType duelType;
  final DateTime? lobbyCountdownEndAt;

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
    this.duelType = DuelType.oneVsOne,
    this.lobbyCountdownEndAt,
    this.currentQuestionIndex = 0,
    this.status = DuelStatus.idle,
    this.questionPhase = DuelQuestionPhase.active,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
  });

  Question? get currentQuestion =>
      questions.isNotEmpty && currentQuestionIndex < questions.length
          ? questions[currentQuestionIndex]
          : null;

  bool get isLastQuestion =>
      questions.isEmpty ? true : currentQuestionIndex == questions.length - 1;

  bool get allPlayersAnswered =>
      players.every((player) => player.answeredCurrentQuestion);

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
    if (status != DuelStatus.inProgress) return;

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

    if (question.correctAnswer != null && question.options != null) {
      final String correctStr = question.correctAnswer!.trim();
      final opts = question.options!;
      final int? correctIndex = int.tryParse(correctStr);
      if (correctIndex != null) {
        isCorrect = selectedOptionIndex == correctIndex;
      } else {
        if (selectedOptionIndex < opts.length) {
          isCorrect = opts[selectedOptionIndex].trim() == correctStr;
        }
      }
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
    if (status != DuelStatus.finished) finalizeMatch();

    final scoreMap = <String, int>{};
    final xpMap = <String, int>{};
    final accuracyMap = <String, double>{};
    final comboMap = <String, int>{};

    for (final player in players) {
      scoreMap[player.userId] = player.score;
      xpMap[player.userId] = player.totalXpGained;
      accuracyMap[player.userId] =
          questions.isEmpty ? 0.0 : player.correctCount / questions.length;
      comboMap[player.userId] = player.comboCount;
    }

    final winner = players.reduce((a, b) => a.score >= b.score ? a : b);

    return DuelResult(
      winnerId: winner.userId,
      scoreMap: scoreMap,
      xpGainedMap: xpMap,
      accuracyMap: accuracyMap,
      comboMap: comboMap,
      totalDuration:
          (finishedAt ?? DateTime.now()).difference(startedAt ?? createdAt),
    );
  }
}
