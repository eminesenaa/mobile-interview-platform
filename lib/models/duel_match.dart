// lib/models/duel_match.dart

import '../utils/duel_scoring_engine.dart';
import 'duel_result.dart';
import 'question.dart';
import 'duel_player.dart';
import 'duel_enums.dart';

/// Bir düellonun tamamını temsil eden ana model
class DuelMatch {
  final String matchId;
  final List<DuelPlayer> players;
  final List<Question> questions;

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
    this.currentQuestionIndex = 0,
    this.status = DuelStatus.idle,
    this.questionPhase = DuelQuestionPhase.active,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
  });

  /// Şu anki aktif soru
  Question get currentQuestion => questions[currentQuestionIndex];

  /// Son soru mu kontrolü
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  /// Tüm oyuncular cevapladı mı kontrolü
  bool get allPlayersAnswered =>
      players.every((player) => player.answeredCurrentQuestion);

  /// Bir sonraki soruya geçmek için index artırır
  void moveToNextQuestion() {
    if (!isLastQuestion) {
      currentQuestionIndex++;
      questionPhase = DuelQuestionPhase.active;

      // Yeni soru başladığında oyuncu state resetlenir
      for (final player in players) {
        player.resetForNextQuestion();
      }
    } else {
      status = DuelStatus.finished;
      finishedAt = DateTime.now();
    }
  }

  /// Oyuncunun bir soruya verdiği cevabı değerlendirir
  /// - Cevabı kilitler
  /// - Doğruluğu kontrol eder (MCQ için)
  /// - Puan ve XP hesaplar
  /// - Eğer herkes cevapladıysa reveal fazına geçer
  void submitAnswer({
    required String userId,
    required int selectedOptionIndex,
    required int answerTimeSeconds,
  }) {
    if (status != DuelStatus.inProgress) return;

    final player = players.firstWhere((p) => p.userId == userId);

    // Eğer zaten cevap verdiyse tekrar işleme alma
    if (player.answeredCurrentQuestion) return;

    player.answeredCurrentQuestion = true;
    player.selectedOptionIndex = selectedOptionIndex;
    player.answerTimeSeconds = answerTimeSeconds;

    final question = currentQuestion;

    bool isCorrect = false;

    // Şu an sadece MCQ destekliyoruz
    if (question.correctAnswer != null) {
      isCorrect = selectedOptionIndex == question.correctAnswer;
    }

    final scoreResult = DuelScoringEngine.evaluateAnswer(
      isCorrect: isCorrect,
      answerTimeSeconds: answerTimeSeconds,
    );

    // Player skor güncelleme
    player.score += scoreResult.scoreGained;
    player.totalXpGained += scoreResult.xpGained;

    if (isCorrect) {
      player.correctCount += 1;
    }

    // Eğer herkes cevapladıysa reveal fazına geç
    if (allPlayersAnswered) {
      questionPhase = DuelQuestionPhase.reveal;
    } else {
      questionPhase = DuelQuestionPhase.waiting;
    }
  }

  /// Reveal fazı tamamlandığında çağrılır
  /// - Eğer son soru değilse bir sonraki soruya geçer
  /// - Eğer son soruysa match'i bitirir
  void revealComplete() {
    if (questionPhase != DuelQuestionPhase.reveal) return;

    if (!isLastQuestion) {
      moveToNextQuestion();
    } else {
      finalizeMatch();
    }
  }

  /// Match'i sonlandırır
  /// - Winner belirler
  /// - Win bonus XP ekler
  /// - Beraberlikte yarım bonus verir
  /// - Status'u finished yapar
  void finalizeMatch() {
    if (status == DuelStatus.finished) return;

    status = DuelStatus.finished;
    finishedAt = DateTime.now();

    // En yüksek skoru bul
    final maxScore =
        players.map((p) => p.score).reduce((a, b) => a > b ? a : b);

    final winners = players.where((p) => p.score == maxScore).toList();

    final fullBonus = DuelScoringEngine.calculateWinBonusXp(true);

    if (winners.length == 1) {
      // Tek kazanan → tam bonus
      winners.first.totalXpGained += fullBonus;
    } else {
      // Beraberlik → yarım bonus
      final halfBonus = fullBonus ~/ 2;
      for (final player in winners) {
        player.totalXpGained += halfBonus;
      }
    }
  }

  /// Match sonucunu üretir (Result ekranında kullanılacak)
  DuelResult buildResult() {
    if (status != DuelStatus.finished) {
      throw Exception('Match henüz bitmedi.');
    }

    final scoreMap = <String, int>{};
    final xpMap = <String, int>{};
    final accuracyMap = <String, double>{};

    for (final player in players) {
      scoreMap[player.userId] = player.score;
      xpMap[player.userId] = player.totalXpGained;

      final totalQuestionsCount = questions.length;
      final accuracy = totalQuestionsCount == 0
          ? 0.0
          : player.correctCount / totalQuestionsCount;

      accuracyMap[player.userId] = accuracy;
    }

    // Winner belirleme (ilk max olan)
    final winner = players.reduce(
      (a, b) => a.score >= b.score ? a : b,
    );

    final duration = finishedAt!.difference(startedAt ?? createdAt);

    return DuelResult(
      winnerId: winner.userId,
      scoreMap: scoreMap,
      xpGainedMap: xpMap,
      accuracyMap: accuracyMap,
      totalDuration: duration,
    );
  }
}
