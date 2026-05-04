import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class UDSectionLabel extends StatelessWidget {
  final String title;

  const UDSectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }
}