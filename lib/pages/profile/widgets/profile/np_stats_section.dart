// ===================== File: np_stats_section.dart =====================
// Purpose:
// Clean modern stat cards (white background + colored accents)
//
// Fixes:
// - Removed colored background
// - Circle aligned to corner (no inner padding feel)
// - Color only on icon + value
// =====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class NpStatsSection extends StatelessWidget {
  final int xp;
  final int streak;

  const NpStatsSection({
    super.key,
    required this.xp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: PhosphorIcons.lightning(PhosphorIconsStyle.fill),
            value: _formatNumber(xp),
            label: "TOTAL XP",
            color: AppColors.honeyBronze,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIcons.fire(PhosphorIconsStyle.fill),
            value: streak.toString(),
            label: "DAY STREAK",
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ",",
        );
  }
}

// =====================================================
// 🔥 STAT CARD
// =====================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // ================= CORNER DECORATION =================
          Positioned(
            right: -25,
            top: -40,
            child: Container(
              clipBehavior: Clip.hardEdge,
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ================= CONTENT =================
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= ICON =================
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // ================= TEXT =================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: AppTextStyles.title.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
