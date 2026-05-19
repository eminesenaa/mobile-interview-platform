import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class NdTopNSlider extends StatelessWidget {
  final int value;
  final int max;
  final Function(int) onChanged;

  const NdTopNSlider({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeMax = max > 1 ? max : 1;
    final safeValue = value.clamp(1, safeMax);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Top Candidates".toUpperCase(),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            Text(
              "Top $safeValue".toUpperCase(),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,

            /// aktif kısım (mavi bar)
            activeTrackColor: AppColors.primary,

            /// pasif kısım (arka çizgi)
            inactiveTrackColor: AppColors.border,

            /// thumb (yuvarlak nokta)
            thumbColor: AppColors.primary,

            /// basınca çıkan efekt
            overlayColor: AppColors.primary.withOpacity(0.15),
          ),
          child: Slider(
            value: safeValue.toDouble(),
            min: 1,
            max: safeMax.toDouble(),
            divisions: safeMax > 1 ? safeMax - 1 : null,
            onChanged: max > 1 ? (v) => onChanged(v.toInt()) : null,
          ),
        ),
      ],
    );
  }
}
