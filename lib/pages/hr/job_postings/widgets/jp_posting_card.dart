import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class JPPostingCard extends StatelessWidget {
  final String title;
  final String level;
  final String location;
  final String workType;

  final int applicants;
  final int accepted;
  final int pending;
  final String status;

  final VoidCallback onTap;

  const JPPostingCard({
    super.key,
    required this.title,
    required this.level,
    required this.location,
    required this.workType,
    required this.applicants,
    required this.accepted,
    required this.pending,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(level);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.bodyStrong),
                _statusChip(),
              ],
            ),

            const SizedBox(height: 8),

            /// ================= LEVEL =================
            _levelChip(level, levelColor),

            const SizedBox(height: 6),

            /// ================= LOCATION + WORK TYPE =================
            Row(
              children: [
                Icon(
                  PhosphorIcons.mapPin(),
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    location,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  PhosphorIcons.briefcase(),
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(workType, style: AppTextStyles.bodySmall),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
            ),

            const SizedBox(height: AppSpacing.md),

            /// ================= STATS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$applicants applicants", style: AppTextStyles.bodySmall),
                Row(
                  children: [
                    Text(
                      "$accepted accepted",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "$pending pending",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 🔥 STATUS CHIP (Animated blinking dot INSIDE)
  // =========================================================
  Widget _statusChip() {
    final isActive = status == "active";
    final isClosed = status == "closed";
    final isReady = isClosed && pending == 0;

    if (isActive) {
      return _BlinkingDotChip(); // 🔥 sadece active
    }

    // 🔥 READY TO INTERVIEW (NEW STATE)
    if (isReady) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cherryBlossom.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cherryBlossom.withOpacity(0.4)),
        ),
        child: Text(
          "Ready",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.cherryBlossom,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // 🔥 CLOSED CHIP (UPDATED COLOR)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Closed",
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================================================
  // 🎯 LEVEL CHIP
  // =========================================================
  Widget _levelChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================================================
  // 🎨 LEVEL COLOR SYSTEM
  // =========================================================
  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case "intern":
        return AppColors.darkCyan;
      case "junior":
        return AppColors.darkMagenta;
      case "mid-level":
        return AppColors.topicTurquoise;
      case "senior":
        return AppColors.pinkCarnation;
      default:
        return AppColors.honeyBronze;
    }
  }
}

/// ===============================================================
/// 🔴 BLINKING DOT CHIP (Reusable)
/// ===============================================================
class _BlinkingDotChip extends StatefulWidget {
  @override
  State<_BlinkingDotChip> createState() => _BlinkingDotChipState();
}

class _BlinkingDotChipState extends State<_BlinkingDotChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 1, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: _opacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "Active",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
