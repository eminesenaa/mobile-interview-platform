import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';

/// Auth ekranları için özel tasarlanmış text field
/// - Icon destekli
/// - Design system uyumlu
/// - Password visibility toggle opsiyonel
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final PhosphorIconData icon;
  final bool isPassword;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? obscure : false,
      style: AppTextStyles.bodyStrong,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.bodySmall,
        filled: true,
        fillColor: AppColors.surfaceMuted,

        // Sol ikon
        prefixIcon: PhosphorIcon(
          widget.icon,
          size: AppIconSizes.md,
          color: AppColors.textMuted,
        ),

        // Password ise sağda göster/gizle ikonu
        suffixIcon: widget.isPassword
            ? IconButton(
          onPressed: () {
            setState(() => obscure = !obscure);
          },
          icon: PhosphorIcon(
            obscure
                ? PhosphorIcons.eye()
                : PhosphorIcons.eyeSlash(),
            size: AppIconSizes.md,
            color: AppColors.textMuted,
          ),
        )
            : null,

        // Border ayarları
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
