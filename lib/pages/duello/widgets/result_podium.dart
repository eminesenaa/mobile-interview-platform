import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_player.dart';
import 'package:interview_project/pages/duello/widgets/player_mini_avatar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// ===============================================================
/// 🏆 RESULT PODIUM (MULTI MODE)
/// ===============================================================
///
/// ✔ 1. oyuncu en yüksekte
/// ✔ gerçek podium blokları
/// ✔ avatar blok üstünde
/// ✔ score blok içinde
/// ✔ responsive yapı
///
class ResultPodium extends StatelessWidget {
  final List<DuelPlayer> players;

  const ResultPodium({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox();

    /// 🔽 SCORE'A GÖRE SIRALA
    final sorted = [...players]..sort((a, b) => b.score.compareTo(a.score));

    final top1 = sorted.length > 0 ? sorted[0] : null;
    final top2 = sorted.length > 1 ? sorted[1] : null;
    final top3 = sorted.length > 2 ? sorted[2] : null;

    return Column(
      children: [
        /// 🔝 ÜSTTEN BOŞLUK (EMULATOR FARKLARINI DENGELER)
        const SizedBox(height: AppSpacing.xl),

        /// 🏆 PODIUM ROW
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (top2 != null) Expanded(child: _buildPodiumItem(top2, 2)),
            if (top1 != null)
              Expanded(child: _buildPodiumItem(top1, 1, isWinner: true)),
            if (top3 != null) Expanded(child: _buildPodiumItem(top3, 3)),
          ],
        ),
      ],
    );
  }

  /// ===============================================================
  /// 🧱 SINGLE PODIUM ITEM
  /// ===============================================================
  Widget _buildPodiumItem(
    DuelPlayer player,
    int rank, {
    bool isWinner = false,
  }) {
    /// 🧠 PODIUM HEIGHTS
    final double height = switch (rank) {
      1 => 120,
      2 => 90,
      3 => 70,
      _ => 60,
    };

    final double avatarOffset = 30;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height + 60, // avatar için alan açıyoruz
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              /// 🧱 PODIUM (ARKA)
              Container(
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: _rankColor(rank),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    player.score.toString(),
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              /// 👤 AVATAR (ÜSTTE)
              Positioned(
                top: AppSpacing.sm,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Transform.scale(
                      scale: isWinner ? 1.5 : 1.4,
                      child: PlayerMiniAvatar(
                        username: player.username,
                        avatarAsset: player.avatarUrl,
                        isMe: false,
                      ),
                    ),
                    if (isWinner)
                      Positioned(
                        top: - (AppSpacing.lg + AppSpacing.xs),
                        child: Icon(
                          PhosphorIcons.crownSimple(PhosphorIconsStyle.fill),
                          size: 20,
                          color: AppColors.honeyBronze,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        /// USERNAME
        Text(
          player.username,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyStrong.copyWith(
            color: AppColors.textLightPrimary,
          ),
        ),
      ],
    );
  }

  /// 🎨 RANK COLORS
  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.honeyBronze;
      case 2:
        return AppColors.paleSlate;
      case 3:
        return AppColors.accentSpicyOrange;
      default:
        return AppColors.primaryAccent;
    }
  }
}
