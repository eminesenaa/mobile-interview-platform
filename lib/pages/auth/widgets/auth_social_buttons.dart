import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';

/// Google & Apple login butonları
/// Şimdilik UI-only, logic controller üzerinden bağlanacak
class AuthSocialButtons extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  const AuthSocialButtons({
    super.key,
    required this.onGoogle,
    required this.onApple,
  });

  Widget _buildButton(PhosphorIconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: PhosphorIcon(
            icon,
            size: AppIconSizes.lg,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(PhosphorIcons.googleLogo(), onGoogle),
        const SizedBox(width: AppSpacing.lg),
        _buildButton(PhosphorIcons.appleLogo(), onApple),
      ],
    );
  }
}
