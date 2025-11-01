import 'package:flutter/material.dart';

import '../../../models/leaderboard.dart';

class LeaderboardListItem extends StatelessWidget {
  final LeaderboardEntry e;
  const LeaderboardListItem({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final trendIcon = e.delta > 0 ? Icons.arrow_upward : e.delta < 0 ? Icons.arrow_downward : Icons.remove;
    final trendColor = e.delta > 0 ? Colors.green : e.delta < 0 ? Colors.red : s.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: e.isMe ? s.primary.withOpacity(.45) : s.outlineVariant.withOpacity(.35),
          width: e.isMe ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              e.rank.toString().padLeft(2, '0'),
              style: t.titleSmall,
            ),
          ),
          const SizedBox(width: 8),

          // Avatar
          CircleAvatar(radius: 18, child: Text(e.initials)),
          const SizedBox(width: 12),

          // Name + XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      '${e.xp} XP',
                      style: t.labelMedium?.copyWith(color: s.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delta
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.delta == 0 ? '0' : (e.delta > 0 ? '+${e.delta}' : '${e.delta}'),
                style: t.labelMedium?.copyWith(color: trendColor),
              ),
              const SizedBox(width: 4),
              Icon(trendIcon, size: 16, color: trendColor),
            ],
          ),
        ],
      ),
    );
  }
}
