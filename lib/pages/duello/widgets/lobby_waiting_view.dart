import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_match.dart';
import 'package:interview_project/pages/duello/controllers/private_room_controller.dart';
import 'package:interview_project/pages/duello/widgets/duel_category_card.dart';
import 'package:interview_project/utils/duel_category_style.dart';

import 'lobby_player_slots.dart';
import 'lobby_room_code.dart';
import 'lobby_start_button.dart';

/// ===============================================================
/// 🧠 LOBBY WAITING VIEW
/// ===============================================================
///
/// ✔ Room code
/// ✔ Category
/// ✔ Player slots (grid)
/// ✔ Status
/// ✔ Start button (host only)
///
class LobbyWaitingView extends StatelessWidget {
  final PrivateRoomController controller;

  const LobbyWaitingView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final match = controller.match.value!;
    final playerCount = match.players.length;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),

        /// 🔑 ROOM CODE
        LobbyRoomCode(password: match.password ?? 'XXXXXX'),

        const SizedBox(height: AppSpacing.xl),

        /// 🧩 CATEGORY
        DuelCategoryCard(
          title: match.category ?? 'Mixed',
          color: DuelCategoryStyle.getColor(match.category ?? 'Mixed'),
          isSelected: true,
        ),

        const SizedBox(height: AppSpacing.xl),

        /// 👥 PLAYER SLOTS
        Expanded(
          child: LobbyPlayerSlots(
            players: match.players,
            hostId:
                match.players.isNotEmpty ? match.players.first.userId : null,
          ),
        ),

        /// 📊 STATUS
        Text(
          '$playerCount/5 Players Joined',
          style: AppTextStyles.bodyStrong.copyWith(
            color: AppColors.textLightPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        /// 🚀 START BUTTON
        LobbyStartButton(
          isHost: controller.isHost.value,
          playerCount: playerCount,
          onStart: controller.startGame,
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
