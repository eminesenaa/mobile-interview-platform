// lib/models/duel_result.dart

import 'duel_player.dart';

class DuelResult {
  final String winnerId;
  final Map<String, int> scoreMap; // userId -> score
  final Map<String, int> xpGainedMap; // userId -> xp
  final Map<String, double> accuracyMap; // userId -> doğruluk oranı
  final Map<String, int>? comboMap; // userId -> max combo
  final Duration totalDuration;
  final List<DuelPlayer> players;

  DuelResult({
    required this.winnerId,
    required this.scoreMap,
    required this.xpGainedMap,
    required this.accuracyMap,
    this.comboMap,
    required this.totalDuration,
    required this.players,
  });
}
