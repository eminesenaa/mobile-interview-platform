// lib/utils/level_calculator.dart

/// XP'ye göre level hesaplama utility sınıfı
class LevelCalculator {
  /// Basit lineer sistem:
  /// Her 200 XP'de bir level artar
  static int calculate(int totalXp) {
    if (totalXp < 0) return 1;
    return (totalXp ~/ 200) + 1;
  }
}