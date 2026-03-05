import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_player.dart';

class DuelScoreProgressBar extends StatelessWidget {
  final List<DuelPlayer> players;
  final String localUserId;
  final int totalQuestions;

  const DuelScoreProgressBar({
    super.key,
    required this.players,
    required this.localUserId,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();

    final int maxCorrect =
        players.map((p) => p.correctCount).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          return SizedBox(
            height: 72,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Track
                Positioned(
                  top: 32,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoftBackground,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),

                // Avatarlar
                ..._buildAvatars(width, maxCorrect),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAvatars(double width, int maxCorrect) {
    final Map<double, int> posCounter = {};

    // Local user'ı en üste (z-index)
    final sorted = [...players]..sort((a, b) {
        if (a.userId == localUserId) return 1;
        if (b.userId == localUserId) return -1;
        return 0;
      });

    return sorted.map((player) {
      final double progress = totalQuestions == 0
          ? 0
          : (player.correctCount / totalQuestions).clamp(0.0, 1.0);

      final double xPos = progress * width;
      final double key = progress;
      final int stackIdx = posCounter[key] ?? 0;
      posCounter[key] = stackIdx + 1;

      // Aynı noktadakiler yatayda kaydır
      final double hOffset = stackIdx * 16.0;

      final bool isLocal = player.userId == localUserId;
      final bool isLeader = maxCorrect > 0 && player.correctCount == maxCorrect;

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        left: (xPos - 20 + hOffset).clamp(0.0, width - 40),
        top: 0,
        child: _AvatarBubble(
          player: player,
          isLocal: isLocal,
          isLeader: isLeader,
        ),
      );
    }).toList();
  }
}

class _AvatarBubble extends StatelessWidget {
  final DuelPlayer player;
  final bool isLocal;
  final bool isLeader;

  const _AvatarBubble({
    required this.player,
    required this.isLocal,
    required this.isLeader,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isLocal ? 44.0 : 36.0;
    final Color color = player.avatarColor;
    final String initial = avatarInitial(player.username);

    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: isLeader ? 1.15 : 1.0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Glow
          if (isLeader)
            Container(
              width: size + 14,
              height: size + 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.55),
                    blurRadius: 16,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),

          // Dış halka — local için daha belirgin
          Container(
            width: size + (isLocal ? 4 : 0),
            height: size + (isLocal ? 4 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isLocal ? Colors.white.withOpacity(0.9) : Colors.transparent,
              border: !isLocal
                  ? Border.all(color: color.withOpacity(0.6), width: 2)
                  : null,
            ),
          ),

          // Avatar dairesi
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: isLocal ? 16 : 13,
                color: Colors.white,
              ),
            ),
          ),

          // Lider ikonu
          if (isLeader)
            Positioned(
              top: -12,
              child: Text(
                isLocal ? '🔥' : '👑',
                style: const TextStyle(fontSize: 13),
              ),
            ),

          // "Sen" etiketi — sadece local için
          if (isLocal)
            Positioned(
              bottom: -14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
