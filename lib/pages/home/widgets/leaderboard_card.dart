// ===================== File: lib/pages/home/widgets/leaderboard_card.dart =====================
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/leaderboard.dart';

class LeaderboardCard extends StatelessWidget {
  final List<TopUser> top3;
  final MeRank? me;
  final VoidCallback? onTap;
  final bool loading;

  const LeaderboardCard({
    super.key,
    required this.top3,
    required this.me,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: s.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: s.outlineVariant.withOpacity(.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Header ----
            Row(
              children: [
                Text(
                  'Leaderboard',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 8),

            // ---- Top 3 ----
            if (loading)
              const _Top3Skeleton()
            else
              Row(
                children: List.generate(top3.length, (i) {
                  final u = top3[i];
                  final tint = i == 0
                      ? s.primary
                      : i == 1
                          ? s.secondary
                          : s.tertiary;
                  return Expanded(child: _MiniChip(user: u, tint: tint));
                }),
              ),

            const SizedBox(height: 12),

            // ---- Current user (me) ----
            if (loading)
              const _MeRowSkeleton()
            else if (me != null)
              _MeRow(me: me!) // ✅ gerçek kullanıcı bilgisi varsa direkt göster
            else
              const _PlaceholderRow(), // ✅ veriler gelmeden önce basit placeholder
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 🔹 Mini User Chip (Top 3)
// ===============================================================
class _MiniChip extends StatelessWidget {
  final TopUser user;
  final Color tint;
  const _MiniChip({required this.user, required this.tint});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tint.withOpacity(.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 14, child: Text(user.initials)),
          const SizedBox(height: 6),
          Text(
            '#${user.rank}',
            style: t.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text('${user.xp} XP', style: t.labelSmall),
        ],
      ),
    );
  }
}

// ===============================================================
// 🔹 Current User Row
// ===============================================================
class _MeRow extends StatelessWidget {
  final MeRank me;
  const _MeRow({required this.me});
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final delta = me.delta;
    final icon = delta > 0
        ? Icons.arrow_upward
        : delta < 0
            ? Icons.arrow_downward
            : Icons.remove;
    final color = delta > 0
        ? Colors.green
        : delta < 0
            ? Colors.red
            : s.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: s.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '#${me.rank}',
            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              me.name,
              style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${me.xp} XP',
            style: t.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 2),
          Text(
            delta == 0 ? '0' : '${delta > 0 ? '+' : ''}$delta',
            style: t.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// 🔹 Skeletons & Placeholder
// ===============================================================
class _Top3Skeleton extends StatelessWidget {
  const _Top3Skeleton();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.05),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _MeRowSkeleton extends StatelessWidget {
  const _MeRowSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.05),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ===============================================================
// 🔹 Placeholder (before Firestore data arrives)
// ===============================================================
class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow();
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: s.surfaceVariant.withOpacity(.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('#–', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fetching your data...',
              style: t.bodyMedium?.copyWith(color: s.onSurfaceVariant),
            ),
          ),
          Text('– XP', style: t.bodyMedium?.copyWith(color: s.onSurfaceVariant)),
          const SizedBox(width: 8),
          const Icon(Icons.hourglass_empty, size: 16, color: Colors.grey),
          const SizedBox(width: 2),
          Text('0', style: t.labelMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}
