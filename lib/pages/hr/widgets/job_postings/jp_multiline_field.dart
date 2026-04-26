import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class JPMultilineField extends StatefulWidget {
  final String hint;
  final String value;
  final Function(String) onChanged;

  const JPMultilineField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  State<JPMultilineField> createState() => _JPMultilineFieldState();
}

class _JPMultilineFieldState extends State<JPMultilineField> {
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
      maxLines: 6,
      minLines: 4,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted.withOpacity(0.7),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(14),
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