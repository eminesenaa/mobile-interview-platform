import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';

class CountSlider extends StatelessWidget {
  final RxInt count; // controller.count
  const CountSlider({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primary;

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbColor: primary,
            activeTrackColor: primary,
            inactiveTrackColor: primary.withValues(alpha: .20),
            overlayColor: primary.withValues(alpha: .10),
            trackHeight: 4,

            valueIndicatorColor: primary,
            valueIndicatorTextStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Slider(
            value: count.value.clamp(5, 20).toDouble(),
            min: 5,
            max: 20,
            divisions: 15,
            label: '${count.value}', // label gösterildiği sürece baloncuk görünür
            onChanged: (v) => count.value = v.round(),
          ),
        ),

        Text('Count: ${count.value}'),
      ],
    ));
  }
}
