import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

/// ===============================================================
/// ND AI GENERATE BUTTON
/// ===============================================================
class NdAiGenerateButton extends StatelessWidget {
  final VoidCallback onTap;

  const NdAiGenerateButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          "Generate with AI",
          style: AppTextStyles.textButton,
        ),
      ),
    );
  }
}
