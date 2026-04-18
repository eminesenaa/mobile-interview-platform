import 'package:flutter/material.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/text_styles.dart';

class OngoingLiveBanner extends StatefulWidget {
  final String elapsed;

  const OngoingLiveBanner({
    super.key,
    required this.elapsed,
  });

  @override
  State<OngoingLiveBanner> createState() => _OngoingLiveBannerState();
}

class _OngoingLiveBannerState extends State<OngoingLiveBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )
      ..repeat(reverse: true);

    _opacity = Tween(begin: 1.0, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.strawberryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              FadeTransition(
                opacity: _opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.strawberryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "Live — Interview in progress",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.strawberryRed,
                ),
              ),
            ],
          ),
          Text(
            widget.elapsed,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.strawberryRed,
            ),
          ),
        ],
      ),
    );
  }
}
