import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_player.dart';
import 'package:interview_project/pages/duello/widgets/player_mini_avatar.dart';

/// ===============================================================
/// 👥 LOBBY PLAYER SLOTS (CIRCLE LAYOUT)
/// ===============================================================
///
/// ✔ Max 5 player
/// ✔ Center + circle layout
/// ✔ Empty slots support
/// ✔ Host highlight
///
class LobbyPlayerSlots extends StatelessWidget {
  final List<DuelPlayer> players;
  final String? hostId;

  const LobbyPlayerSlots({
    super.key,
    required this.players,
    required this.hostId,
  });

  @override
  Widget build(BuildContext context) {
    /// Max 5 slot
    final List<DuelPlayer?> slots = List.generate(
      5,
      (index) => index < players.length ? players[index] : null,
    );

    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 🔝 TOP
            _buildSlot(slots[0], Offset(0, -110)),

            /// LEFT TOP
            _buildSlot(slots[1], Offset(-90, -40)),

            /// RIGHT TOP
            _buildSlot(slots[2], Offset(90, -40)),

            /// LEFT BOTTOM
            _buildSlot(slots[3], Offset(-70, 70)),

            /// RIGHT BOTTOM
            _buildSlot(slots[4], Offset(70, 70)),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// SINGLE SLOT
  /// ===============================================================
  Widget _buildSlot(DuelPlayer? player, Offset offset) {
    final bool isEmpty = player == null;
    final bool isHost = player?.userId == hostId;

    return Transform.translate(
      offset: offset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 👤 AVATAR / EMPTY SLOT
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              /// HOST GLOW
              boxShadow: isHost
                  ? [
                      BoxShadow(
                        color: AppColors.primaryAccent.withOpacity(0.6),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: isEmpty
                ? _buildEmptySlot()
                : PlayerMiniAvatar(
                    username: player.username,
                    avatarAsset: player.avatarUrl,
                    isMe: false,
                  ),
          ),

          const SizedBox(height: 6),

          /// NAME
          if (!isEmpty)
            Text(
              player!.username,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLightPrimary,
              ),
            ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// EMPTY SLOT UI
  /// ===============================================================
  Widget _buildEmptySlot() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textLightPrimary.withOpacity(0.3),
          width: 1.5,
        ),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          size: 18,
          color: AppColors.textLightPrimary.withOpacity(0.5),
        ),
      ),
    );
  }
}
