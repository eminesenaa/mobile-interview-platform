/// ===============================================================
/// ND TOPIC SLIDER
/// ---------------------------------------------------------------
/// - Clean modern slider
/// - Custom color support (external palette)
/// - Section label style
/// ===============================================================

import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class NdTopicSlider extends StatelessWidget {
  final String topic;
  final double value;
  final Function(double) onChanged;

  /// dışarıdan renk verilecek
  final Color color;

  const NdTopicSlider({
    super.key,
    required this.topic,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// =========================
        /// LABEL (SECTION STYLE 🔥)
        /// =========================
        Text(
          topic.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        /// =========================
        /// SLIDER
        /// =========================
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,

            /// bar
            activeTrackColor: color,
            inactiveTrackColor: AppColors.border,

            /// thumb
            thumbColor: color,

            /// overlay
            overlayColor: color.withOpacity(0.15),

            /// 🔥 value indicator (üstte çıkan balon)
            valueIndicatorColor: color,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),

            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            label: "${value.toInt()}%",
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
