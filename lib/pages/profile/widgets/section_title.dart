import 'package:flutter/material.dart';
import 'package:interview_project/constants/colors.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
    );
  }
}
