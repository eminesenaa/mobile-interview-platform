// lib/pages/home/widgets/leaderboard_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';
import 'package:interview_project/models/leaderboard.dart';

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({
    super.key,
    required this.top3,
    required this.me,
    required this.loading,
    this.onTap,
  });

  final List<TopUser> top3;
  final MeRank? me;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.low,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: loading
                ? _buildLoadingState()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Header ----
                      Row(
                        children: [
                          Text('Leaderboard', style: AppTextStyles.bodyStrong),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ---- Podium row ----
                      SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _PodiumBox(
                              user: top3.length > 1 ? top3[1] : null,
                              rank: 2,
                              height: 115,
                              width: 88,
                            ),
                            _PodiumBox(
                              user: top3.isNotEmpty ? top3[0] : null,
                              rank: 1,
                              height: 135,
                              width: 100,
                            ),
                            _PodiumBox(
                              user: top3.length > 2 ? top3[2] : null,
                              rank: 3,
                              height: 100,
                              width: 88,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // ---- Base line ----
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // ---- Me row ----
                      if (me != null) _MeRow(me: me!),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Leaderboard', style: AppTextStyles.bodyStrong),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _SkeletonPodiumBox(),
              _SkeletonPodiumBox(),
              _SkeletonPodiumBox(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SkeletonMeRow(),
      ],
    );
  }
}

// ===================== Podium Box =====================

class _PodiumBox extends StatelessWidget {
  const _PodiumBox({
    required this.user,
    required this.rank,
    required this.height,
    required this.width,
  });

  final TopUser? user;
  final int rank;
  final double height;
  final double width;

  String _safeInitials(TopUser? u) {
    if (u == null) return '--';
    final d = u as dynamic;
    try {
      final v = d.initials;
      if (v != null && v.toString().isNotEmpty) return v.toString();
    } catch (_) {}
    try {
      final v = d.shortName;
      if (v != null && v.toString().isNotEmpty) return v.toString();
    } catch (_) {}
    try {
      final v = d.name;
      if (v != null && v.toString().isNotEmpty) {
        final s = v.toString().trim();
        if (s.isEmpty) return '--';
        final parts = s.split(' ');
        if (parts.length == 1) {
          return s.length <= 2
              ? s.toUpperCase()
              : s.substring(0, 2).toUpperCase();
        }
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
    } catch (_) {}
    return '--';
  }

  String _safeXp(TopUser? u) {
    if (u == null) return '0 XP';
    final d = u as dynamic;
    try {
      final v = d.xp;
      if (v != null) return '${v.toString()} XP';
    } catch (_) {}
    try {
      final v = d.totalXp;
      if (v != null) return '${v.toString()} XP';
    } catch (_) {}
    return '0 XP';
  }

  String _ordinalLabel(int r) {
    switch (r) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '#$r';
    }
  }

  String _medalAssetFor(int r) {
    switch (r) {
      case 1:
        return 'assets/images/1st_medal.svg';
      case 2:
        return 'assets/images/2nd_medal.svg';
      case 3:
        return 'assets/images/3rd_medal.svg';
      default:
        return 'assets/images/1st_medal.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg;
    switch (rank) {
      case 1:
        bg = AppColors.primary;
        break;
      case 2:
        bg = AppColors.primaryAccent;
        break;
      case 3:
        bg = AppColors.paleSlate;
        break;
      default:
        bg = AppColors.surfaceMuted;
    }

    late final Color textColor;
    late final Color xpColor;

    if (rank == 1 || rank == 2) {
      textColor = Colors.white;
      xpColor = Colors.white.withOpacity(0.9);
    } else {
      textColor = AppColors.textSecondary;
      xpColor = AppColors.textSecondary;
    }

    final initials = _safeInitials(user);
    final xpText = _safeXp(user);
    final ordinal = _ordinalLabel(rank);
    final medalAsset = _medalAssetFor(rank);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Initials (bir tık aşağıda dursun diye top padding verdik)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              initials,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyStrong.copyWith(
                fontSize: 18,
                color: textColor,
              ),
            ),
          ),

          // Medal + ordinal (ordinal below the medal)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                medalAsset,
                width: 20,
                height: 20,
              ),
              const SizedBox(height: 2),
              Text(
                ordinal,
                style: AppTextStyles.bodySmall.copyWith(
                  color: textColor,
                ),
              ),
            ],
          ),

          // XP – daha okunabilir
          Text(
            xpText,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: xpColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== Skeleton Podium (loading) =====================

class _SkeletonPodiumBox extends StatelessWidget {
  const _SkeletonPodiumBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ===================== Me Row =====================

class _MeRow extends StatelessWidget {
  const _MeRow({required this.me});

  final MeRank me;

  int _safeRank(MeRank m) {
    final d = m as dynamic;
    try {
      final v = d.rank;
      if (v != null) return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}
    return 0;
  }

  String _safeName(MeRank m) {
    final d = m as dynamic;
    try {
      final v = d.name;
      if (v != null && v.toString().isNotEmpty) return v.toString();
    } catch (_) {}
    return 'You';
  }

  String _safeXp(MeRank m) {
    final d = m as dynamic;
    try {
      final v = d.xp;
      if (v != null) return '${v.toString()} XP';
    } catch (_) {}
    try {
      final v = d.totalXp;
      if (v != null) return '${v.toString()} XP';
    } catch (_) {}
    return '0 XP';
  }

  int _safeDelta(MeRank m) {
    final d = m as dynamic;
    try {
      final v = d.delta;
      if (v != null) return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}
    return 0;
  }

  String _deltaIconAsset(int delta) {
    if (delta > 0) {
      return 'assets/images/up_icon.svg';
    } else if (delta < 0) {
      return 'assets/images/down_icon.svg';
    } else {
      return 'assets/images/unchanged_icon.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = _safeRank(me);
    final name = _safeName(me);
    final xp = _safeXp(me);
    final delta = _safeDelta(me);

    final bool isUp = delta > 0;
    final bool isDown = delta < 0;

    final Color deltaColor = delta == 0
        ? AppColors.textMuted
        : (isUp ? AppColors.success : AppColors.error);

    final String deltaPrefix = delta > 0 ? '+' : '';
    final String iconAsset = _deltaIconAsset(delta);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.paleSlate.withOpacity(0.25),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            // Rank
            Text(
              '#$rank',
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),

            // Name
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // XP
            Text(
              xp,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),

            // XP ↔ delta grubu arası biraz daha boşluk
            const SizedBox(width: 10),

            // Delta number
            Text(
              '$deltaPrefix$delta',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13, // bir tık büyük
                fontWeight: FontWeight.w600, // daha kalın
                color: deltaColor,
              ),
            ),
            const SizedBox(width: 4),

            // Delta icon (XP'nin SAĞINDA)
            SvgPicture.asset(
              iconAsset,
              width: 12, // 14 → 12
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== Skeleton Me Row (loading) =====================

class _SkeletonMeRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 24,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
