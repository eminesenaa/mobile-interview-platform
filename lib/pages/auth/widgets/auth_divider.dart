import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

/// Social login öncesi kullanılan ayırıcı
/// "or continue with" görünümü için
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.border),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          "or continue with",
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(
          child: Divider(color: AppColors.border),
        ),
      ],
    );
  }
}
