import 'package:flutter/material.dart';
import 'package:interview_project/models/duel_player.dart';
import 'leaderboard_item.dart';

class LeaderboardList extends StatelessWidget {
  final List<DuelPlayer> players;
  final String localUserId;

  const LeaderboardList({
    super.key,
    required this.players,
    required this.localUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox();

    /// 🔽 SCORE'A GÖRE SIRALA
    final sorted = [...players]..sort((a, b) => b.score.compareTo(a.score));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final player = sorted[index];

        return LeaderboardItem(
          player: player,
          rank: index + 1,
          isMe: player.userId == localUserId,
        );
      },
    );
  }
}
