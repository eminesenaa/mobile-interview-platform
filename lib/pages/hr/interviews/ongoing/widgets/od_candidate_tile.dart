import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class OngoingCandidateTile extends StatefulWidget {
  final Map<String, dynamic> candidate;

  const OngoingCandidateTile({
    super.key,
    required this.candidate,
  });

  @override
  State<OngoingCandidateTile> createState() => _OngoingCandidateTileState();
}

class _OngoingCandidateTileState extends State<OngoingCandidateTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _opacity = Tween(begin: 1.0, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    final name = widget.candidate["name"];
    final status = widget.candidate["status"];
    final subtitle = widget.candidate["subtitle"];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.low,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(name[0]),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyStrong),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          _StatusChip(status),
        ],
      ),
    );
  }

  Widget _StatusChip(String status) {
    Color color;

    switch (status) {
      case "active":
        color = AppColors.error;
        break;
      case "waiting":
        color = AppColors.warning;
        break;
      case "done":
        color = AppColors.success;
        break;
      default:
        color = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SADECE ACTIVE İÇİN BLINK
          if (status == "active") ...[
            FadeTransition(
              opacity: _opacity,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          Text(
            status.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
