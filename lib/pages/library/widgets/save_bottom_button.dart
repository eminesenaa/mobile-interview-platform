// lib/pages/library/widgets/save_bottom_button.dart
import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

class SaveBottomButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;

  const SaveBottomButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withOpacity(.35),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        "Save",
        style: AppTextStyles.button.copyWith(color: Colors.white),
      ),
    );
  }
}
