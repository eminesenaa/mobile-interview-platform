import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';
import '../../../models/duel_enums.dart';

/// ===============================================================
/// DuelPlayerCountBadge
/// ---------------------------------------------------------------
/// - Shows current player count in matchmaking (e.g. 1/5)
/// - Minimal UI: no background, no border
/// - Large, readable, game-style indicator
/// ===============================================================
class DuelPlayerCountBadge extends StatelessWidget {
  final int playerCount;
  final DuelType duelType;

  const DuelPlayerCountBadge({
    super.key,
    required this.playerCount,
    required this.duelType,
  });

  @override
  Widget build(BuildContext context) {
    final maxPlayers = duelType == DuelType.multi ? 5 : 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIcons.usersThree(),
          color: Colors.white,
          size: AppSpacing.xxl + AppSpacing.md, // 🔥 büyütüldü
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          "$playerCount/$maxPlayers",
          style: AppTextStyles.displayLarge.copyWith(
            color: Colors.white,
            fontSize: 22, // 🔥 büyütüldü
          ),
        ),
      ],
    );
  }
}
