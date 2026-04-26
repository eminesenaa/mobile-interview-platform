import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

/// ===================== JP DETAIL HEADER =====================
/// Displays:
/// - Posting title
/// - Meta info (date + id)
/// - Status chip (Active blinking dot / Closed)
/// ============================================================

class JPDetailHeader extends StatefulWidget {
  final String title;
  final String meta;
  final bool isActive;

  const JPDetailHeader({
    super.key,
    required this.title,
    required this.meta,
    required this.isActive,
  });

  @override
  State<JPDetailHeader> createState() => _JPDetailHeaderState();
}

class _JPDetailHeaderState extends State<JPDetailHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    /// 🔥 ONLY DOT BLINKS (not whole chip)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.3,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// LEFT SIDE
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: AppTextStyles.headline),
            const SizedBox(height: 4),
            Text(widget.meta, style: AppTextStyles.bodySmall),
          ],
        ),

        /// RIGHT CHIP
        _statusChip(),
      ],
    );
  }

  Widget _statusChip() {
    final color = widget.isActive ? AppColors.success : AppColors.error;
    final text = widget.isActive ? "Active" : "Closed";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔥 BLINKING DOT (ONLY ACTIVE)
          if (widget.isActive)
            FadeTransition(
              opacity: _controller,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          if (widget.isActive) const SizedBox(width: 6),

          /// TEXT
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}