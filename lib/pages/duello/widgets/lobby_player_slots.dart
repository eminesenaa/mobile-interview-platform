import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_player.dart';
import 'package:interview_project/pages/duello/widgets/player_avatar_widget.dart';

import '../controllers/private_room_controller.dart';

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

  LobbyPlayerSlots({
    super.key,
    required this.players,
    required this.hostId,
  });

  final controller = Get.find<PrivateRoomController>();

  @override
  Widget build(BuildContext context) {
    /// Max 5 slot
    final List<DuelPlayer?> slots = List.generate(
      5,
      (index) => index < players.length ? players[index] : null,
    );

    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 🔝 TOP
            _buildSlot(slots[0], Offset(0, -130)),

            /// LEFT TOP
            _buildSlot(slots[1], Offset(-110, -50)),

            /// RIGHT TOP
            _buildSlot(slots[2], Offset(110, -50)),

            /// LEFT BOTTOM
            _buildSlot(slots[3], Offset(-90, 90)),

            /// RIGHT BOTTOM
            _buildSlot(slots[4], Offset(90, 90)),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: isEmpty
                ?  const SizedBox()
                : PlayerAvatarWidget(
                    username: player.username,
                    avatarAsset: player.avatarUrl,
                    isHost: isHost,
                    isMe: player.userId == controller.userId,
                  ),
          ),
        ],
      ),
    );
  }
}
