import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/duel_match.dart';
import '../../../models/duel_enums.dart';
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
  final String? hostUserId;
  final Color textColor;

  const DuelPlayersLayout({
    super.key,
    required this.match,
    this.hostUserId,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final players = match.players;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // 1v1 Layout
    if (players.length == 2 && match.duelType == DuelType.oneVsOne) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlayerAvatarWidget(
            username: players[0].username,
            avatarAsset: players[0].avatarUrl,
            highlight: true,
            isHost: hostUserId != null && players[0].userId == hostUserId,
            isMe: players[0].userId == currentUserId,
            textColor: textColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            "VS",
            style: AppTextStyles.displayLarge.copyWith(
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PlayerAvatarWidget(
            username: players[1].username,
            avatarAsset: players[1].avatarUrl,
            highlight: true,
            isHost: hostUserId != null && players[1].userId == hostUserId,
            isMe: players[1].userId == currentUserId,
            textColor: textColor,
          ),
        ],
      );
    }

    // Multi Layout
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.lg,
      alignment: WrapAlignment.center,
      children: List.generate(
        players.length,
        (index) => PlayerAvatarWidget(
          username: players[index].username,
          avatarAsset: players[index].avatarUrl,
          highlight: true,
          isHost: hostUserId != null && players[index].userId == hostUserId,
          isMe: players[index].userId == currentUserId,
          textColor: textColor,
        ),
      ),
    );
  }
}
