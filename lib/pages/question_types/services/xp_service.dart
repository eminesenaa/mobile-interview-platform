/*
 * lib/services/xp/xp_service.dart
 * Tek soruluk XP hesaplama servisi
 * Practice + Exam için ortak kullanılır
 */

import 'package:interview_project/models/question.dart';

class XpService {
  /// score: AI değerlendirmesi (0–5)
  /// baseXp: question.xp (temel XP)
  /// difficulty: soru zorluğu (opsiyonel)
  /// type: soru tipi (opsiyonel)
  static int computeXp({
    required int baseXp,
    required int score,
    Difficulty? difficulty,
    QuestionType? type,
  }) {
    // 1️⃣ Score normalize (0–1)
    final normalizedScore = (score.clamp(0, 5)) / 5.0;

    // 2️⃣ Difficulty çarpanı
    final difficultyMultiplier =
        difficulty != null ? _difficultyMultiplier(difficulty) : 1.0;

    // 3️⃣ Question type çarpanı
    final typeMultiplier = type != null ? _typeMultiplier(type) : 1.0;

    // 4️⃣ Nihai XP
    final xp = baseXp * normalizedScore * difficultyMultiplier * typeMultiplier;

    return xp.round();
  }

  // ===========================
  // 🔹 Difficulty multipliers
  // ===========================
  static double _difficultyMultiplier(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 0.5;
      case Difficulty.easy_medium:
        return 0.8;
      case Difficulty.medium:
        return 1.0;
      case Difficulty.medium_hard:
        return 1.3;
      case Difficulty.hard:
        return 1.6;
    }
  }

  // ===========================
  // 🔹 Question type multipliers
  // ===========================
  static double _typeMultiplier(QuestionType t) {
    switch (t) {
      case QuestionType.mcq:
        return 0.8;

      case QuestionType.fillBlank:
        return 1.0;

      case QuestionType.shortAnswer:
        return 1.4;

      case QuestionType.debugging:
        return 1.4;

      case QuestionType.coding:
        return 1.6;
    }
  }
}
