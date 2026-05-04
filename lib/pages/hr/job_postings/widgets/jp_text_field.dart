import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class JPTextField extends StatefulWidget {
  final String hint;
  final String value;
  final IconData? suffixIcon;
  final Function(String) onChanged;

  const JPTextField({
    super.key,
    required this.hint,
    required this.value,
    this.suffixIcon,
    required this.onChanged,
  });

  @override
  State<JPTextField> createState() => _JPTextFieldState();
}

class _JPTextFieldState extends State<JPTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.value.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted.withOpacity(0.7),
        ),
        filled: true,
        fillColor: AppColors.surface,
        suffixIcon: widget.suffixIcon != null
            ? Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            widget.suffixIcon,
            size: 18,
            color: AppColors.textMuted,
          ),
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}