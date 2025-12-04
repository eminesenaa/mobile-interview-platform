// ===================== File: profile_text_input_field.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

/// MASTER TEXT INPUT WIDGET
/// Tüm text input alanlarını tek bir widgetla kontrol eder.
///
/// Destekler:
/// - label
/// - icon
/// - hint
/// - RxString reactive text
/// - keyboardType
/// - obscureText (password)
/// - readOnly + onTap (picker modal gibi)
/// - multi-line
/// - consistent UI across the app
class ProfileTextInputField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final RxString rxValue;

  final String? hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;

  const ProfileTextInputField({
    super.key,
    required this.label,
    required this.rxValue,
    this.icon,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  State<ProfileTextInputField> createState() => _ProfileTextInputFieldState();
}

class _ProfileTextInputFieldState extends State<ProfileTextInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.rxValue.value);

    /// RxString değiştiğinde text alanını güncelle
    ever(widget.rxValue, (value) {
      if (_controller.text != value) {
        _controller.text = value;
        _controller.selection =
            TextSelection.collapsed(offset: _controller.text.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.bodyStrong),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 10),
              ],

              Expanded(
                child: TextField(
                  controller: _controller,
                  readOnly: widget.readOnly,
                  maxLines: widget.maxLines,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => widget.rxValue.value = v,
                  onTap: widget.onTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
