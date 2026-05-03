// ===================== File: iw_pulse_animation.dart =====================
// Purpose:
// Ripple pulse animation around center icon
// ========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../constants/colors.dart';


class IwPulseAnimation extends StatefulWidget {
  const IwPulseAnimation({super.key});

  @override
  State<IwPulseAnimation> createState() => _IwPulseAnimationState();
}

class _IwPulseAnimationState extends State<IwPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildCircle(double delay) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final value = (controller.value + delay) % 1;

        return Transform.scale(
          scale: 0.8 + value,
          child: Opacity(
            opacity: (1 - value),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.4),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          buildCircle(0),
          buildCircle(0.3),
          buildCircle(0.6),

          // ================= CENTER ICON =================
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primarySoftBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.clock(),
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
