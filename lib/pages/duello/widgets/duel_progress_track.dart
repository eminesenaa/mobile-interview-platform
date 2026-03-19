import 'dart:math';
import 'package:flutter/material.dart';
import 'package:interview_project/pages/duello/widgets/player_mini_avatar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../constants/constants.dart';
import '../../../models/duel_player.dart';

class DuelProgressTrack extends StatelessWidget {
  final List<DuelPlayer> players;
  final String localUserId;
  final int totalQuestions;

  const DuelProgressTrack({
    super.key,
    required this.players,
    required this.localUserId,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 130,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              /// 🎨 TRACK
              CustomPaint(
                size: Size(constraints.maxWidth, 130),
                painter: _WavePainter(),
              ),

              /// 👥 PLAYERS
              ...players.map((player) {
                final progress = totalQuestions == 0
                    ? 0.0
                    : (player.correctCount / totalQuestions)
                        .toDouble()
                        .clamp(0.0, 1.0);

                final pos = _getPosition(
                  progress,
                  constraints.maxWidth,
                  130,
                );

                final isLocal = player.userId == localUserId;

                return Positioned(
                  left: pos.dx - 18,
                  top: pos.dy - 18,
                  child: PlayerMiniAvatar(
                    username: player.username,
                    avatarAsset: player.avatarUrl,
                    isMe: player.userId == localUserId,
                    isLeader: player.correctCount ==
                        players
                            .map((p) => p.correctCount)
                            .reduce((a, b) => a > b ? a : b),
                  ),
                );
              }),

              /// 🏁 FINISH FLAG
              Positioned(
                right: 4,
                top: _getPosition(1.0, constraints.maxWidth, 130).dy - 32,
                child: Icon(
                  PhosphorIcons.flagBannerFold(PhosphorIconsStyle.fill),
                  size: 26,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Offset _getPosition(double t, double width, double height) {
    final x = t * width;

    final y = height / 2 + sin(t * 2 * pi * 1.5) * 25;

    return Offset(x, y);
  }
}

/// 🎨 CURVE
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(0, size.height / 2);

    for (double i = 0; i <= size.width; i++) {
      final t = i / size.width;
      final y = size.height / 2 + sin(t * 2 * pi * 1.5) * 25;
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
