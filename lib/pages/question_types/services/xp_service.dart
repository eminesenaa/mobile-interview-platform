/*
 * lib/services/xp/xp_service.dart
 * Tek soruluk XP hesaplama servisi
 * Practice + Exam için ortak kullanılır
 */

class XpService {
  /// Score: 0–5 arasında AI değerlendirmesi
  /// baseXp: question.xp (soru zorluk değeri)
  static int computeXp({
    required int baseXp,
    required int score, // AI score
  }) {
    final normalized = (score.clamp(0, 5)) / 5.0;
    return (normalized * baseXp).round();
  }

  /// İleride:
  /// - difficultyMultipler
  /// - coding için codeScore
  /// - adaptive xp
  /// gibi genişletmeler buraya eklenebilir.
}
