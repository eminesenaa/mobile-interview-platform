class TopUser {
  final int rank;
  final int xp;
  final String initials;

  TopUser({
    required this.rank,
    required this.xp,
    required this.initials,
  });
}

class MeRank {
  final int rank;
  final String name;
  final int xp;
  final int delta; // örn: +3, -1, 0

  MeRank({
    required this.rank,
    required this.name,
    required this.xp,
    required this.delta,
  });
}

/// Tam liste için tek tip giriş
class LeaderboardEntry {
  final int rank;
  final String name;
  final String initials;
  final int xp;
  final int delta;
  final bool isMe;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.initials,
    required this.xp,
    required this.delta,
    this.isMe = false,
  });
}
