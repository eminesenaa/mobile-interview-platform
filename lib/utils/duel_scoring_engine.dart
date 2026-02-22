// lib/utils/duel_scoring_engine.dart

/// Düello puan ve XP hesaplama motoru
/// Bu sınıf stateless'tir.
/// Backend entegrasyonu olmadan test edilebilir.
class DuelScoringEngine {
  /// Doğru cevap başına temel puan
  static const int baseCorrectScore = 1;

  /// Doğru cevap başına temel XP
  static const int baseCorrectXp = 10;

  /// Kazanma bonusu XP
  static const int winBonusXp = 50;

  /// Hız bonusu hesaplama
  /// 0-10 sn   → +5 puan
  /// 10-20 sn  → +3 puan
  /// 20-30 sn  → +0 puan
  static int calculateSpeedBonus(int answerTimeSeconds) {
    if (answerTimeSeconds <= 10) {
      return 5;
    } else if (answerTimeSeconds <= 20) {
      return 3;
    } else {
      return 0;
    }
  }

  /// Tek soru için skor hesaplar
  static DuelScoreResult evaluateAnswer({
    required bool isCorrect,
    required int answerTimeSeconds,
  }) {
    if (!isCorrect) {
      return DuelScoreResult(
        scoreGained: 0,
        xpGained: 0,
      );
    }

    final speedBonus = calculateSpeedBonus(answerTimeSeconds);

    return DuelScoreResult(
      scoreGained: baseCorrectScore + speedBonus,
      xpGained: baseCorrectXp,
    );
  }

  /// Match sonunda kazanma bonusu hesaplama
  static int calculateWinBonusXp(bool isWinner) {
    return isWinner ? winBonusXp : 0;
  }
}

/// Tek bir sorudan kazanılan sonucu temsil eder
class DuelScoreResult {
  final int scoreGained;
  final int xpGained;

  DuelScoreResult({
    required this.scoreGained,
    required this.xpGained,
  });
}