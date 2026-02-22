import 'package:flutter/material.dart';
import '../../../models/duel_match.dart';
import 'player_avatar_widget.dart';
import 'package:interview_project/constants/constants.dart';

/// ===============================================================
/// DuelPlayersLayout
/// ---------------------------------------------------------------
/// - Matchmaking ekranında oyuncuları yerleştirir.
/// - 1v1 için karşılıklı layout.
/// - Multi için wrap layout.
/// ===============================================================
class DuelPlayersLayout extends StatelessWidget {
  final DuelMatch match;

  const DuelPlayersLayout({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final players = match.players;

    // 1v1 Layout
    if (players.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PlayerAvatarWidget(
            username: players[0].username,
            avatarAsset: players[0].avatarUrl,
            highlight: true,
          ),
          Text(
            "VS",
            style: AppTextStyles.displayLarge.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          PlayerAvatarWidget(
            username: players[1].username,
            avatarAsset: players[1].avatarUrl,
            highlight: true,
          ),
        ],
      );
    }

    // Multi Layout
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.lg,
      alignment: WrapAlignment.center,
      children: players
          .map(
            (p) => PlayerAvatarWidget(
              username: p.username,
              avatarAsset: p.avatarUrl,
              highlight: true,
            ),
          )
          .toList(),
    );
  }
}
