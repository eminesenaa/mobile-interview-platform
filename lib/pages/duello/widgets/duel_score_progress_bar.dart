import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_player.dart';

/// Dinamik oyuncu sayısını destekleyen (2-5) progress bar widget'ı.
/// Her oyuncu için ayrı bir row gösterir: avatar + animasyonlu ilerleme çubuğu.
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
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: players.map((player) {
          final bool isLocal = player.userId == localUserId;
          final bool isLeader =
              maxCorrect > 0 && player.correctCount == maxCorrect;
          final double progress = totalQuestions == 0
              ? 0
              : (player.correctCount / totalQuestions).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _PlayerProgressRow(
              player: player,
              isLocal: isLocal,
              isLeader: isLeader,
              progress: progress,
              totalQuestions: totalQuestions,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Tek oyuncu satırı: mini avatar + animasyonlu bar + skor
class _PlayerProgressRow extends StatelessWidget {
  final DuelPlayer player;
  final bool isLocal;
  final bool isLeader;
  final double progress;
  final int totalQuestions;

  const _PlayerProgressRow({
    required this.player,
    required this.isLocal,
    required this.isLeader,
    required this.progress,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = player.avatarColor;
    final String initial = avatarInitial(player.username);
    final double avatarSize = isLocal ? 32 : 26;

    return Row(
      children: [
        // ── AVATAR ──
        AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: isLeader ? 1.15 : 1.0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Glow for leader
              if (isLeader)
                Container(
                  width: avatarSize + 10,
                  height: avatarSize + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

              // Outer ring for local user
              if (isLocal)
                Container(
                  width: avatarSize + 4,
                  height: avatarSize + 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

              // Avatar circle
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isLocal ? 13 : 11,
                    color: Colors.white,
                  ),
                ),
              ),

              // Leader icon
              if (isLeader)
                Positioned(
                  top: -8,
                  child: Text(
                    isLocal ? '🔥' : '👑',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // ── PROGRESS BAR ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username label
              Row(
                children: [
                  Text(
                    isLocal ? 'You' : player.username,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isLocal ? FontWeight.w700 : FontWeight.w500,
                      color: isLocal
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${player.correctCount}/${totalQuestions > 0 ? totalQuestions : '?'}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),

              // Animated bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: SizedBox(
                  height: isLocal ? 8 : 6,
                  child: Stack(
                    children: [
                      // Track background
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primarySoftBackground,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      // Filled portion
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withOpacity(0.7),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// AnimatedFractionallySizedBox — implicit animation for widthFactor
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve = Curves.linear,
    required this.widthFactor,
    required this.child,
  });

  @override
  AnimatedFractionallySizedBoxState createState() =>
      AnimatedFractionallySizedBoxState();
}

class AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: (_widthFactor?.evaluate(animation) ?? 0).clamp(0.0, 1.0),
      child: widget.child,
    );
  }
}
