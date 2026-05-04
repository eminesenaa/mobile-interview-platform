// ===================== File: lb_podium.dart =====================
// Purpose:
// Top 3 leaderboard podium (platform style)
//
// Features:
// - 1st center (highest)
// - 2nd left, 3rd right
// - Crown for 1st
// - Avatar on top
// - XP inside platform
// =================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../constants/constants.dart';

class LbPodium extends StatelessWidget {
  final List top3;

  const LbPodium({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.length < 3) return const SizedBox();

    final first = top3[0];
    final second = top3[1];
    final third = top3[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildItem(second, 2)),
        Expanded(child: _buildItem(first, 1, isWinner: true)),
        Expanded(child: _buildItem(third, 3)),
      ],
    );
  }

  Widget _buildItem(dynamic user, int rank, {bool isWinner = false}) {
    final height = switch (rank) {
      1 => 120.0,
      2 => 95.0,
      3 => 75.0,
      _ => 60.0,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height + 80,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // ================= PLATFORM =================
              Container(
                height: height,
                margin: const EdgeInsets.fromLTRB(6, 20, 6, 0),
                decoration: BoxDecoration(
                  color: _rankColor(rank),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.textLightPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(text: "$rank"),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Transform.translate(
                            offset: const Offset(1, -6), //  üsteli gibi yukarı alır
                            child: Text(
                              _rankSuffix(rank),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textLightPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= AVATAR =================
              Positioned(
                bottom: height - (isWinner ? -10 : -8),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: isWinner ? 28 : 24,
                      backgroundColor: AppColors.primarySoftBackground,
                      child: Text(
                        user.initials ?? "",
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // 👑 Crown
                    if (isWinner)
                      Positioned(
                        top: -20,
                        child: Icon(
                          PhosphorIcons.crownSimple(PhosphorIconsStyle.fill),
                          color: AppColors.rankGold,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // NAME
        Text(
          user.initials ?? "",
          style: AppTextStyles.bodyStrong,
        ),

        const SizedBox(height: 2),

        // XP TEXT
        Text(
          "${user.xp} XP",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.rankGold;
      case 2:
        return AppColors.rankSilver;
      case 3:
        return AppColors.rankBronze;
      default:
        return AppColors.primary;
    }
  }

  String _rankSuffix(int rank) {
    switch (rank) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }
}
