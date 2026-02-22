// lib/models/duel_result.dart

/// Düello sonucu modeli (Result sayfasında kullanılacak)
class DuelResult {
  final String winnerId;
  final Map<String, int> scoreMap;       // userId -> score
  final Map<String, int> xpGainedMap;    // userId -> xp
  final Map<String, double> accuracyMap; // userId -> doğruluk oranı
  final Duration totalDuration;

  DuelResult({
    required this.winnerId,
    required this.scoreMap,
    required this.xpGainedMap,
    required this.accuracyMap,
    required this.totalDuration,
  });
}