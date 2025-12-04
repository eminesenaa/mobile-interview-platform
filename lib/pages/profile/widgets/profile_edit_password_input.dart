import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfilePasswordInput extends StatefulWidget {
  final String label;
  final Function(String) onChanged;

  const ProfilePasswordInput({
    super.key,
    required this.label,
    required this.onChanged,
  });

  @override
  State<ProfilePasswordInput> createState() => _ProfilePasswordInputState();
}

class _ProfilePasswordInputState extends State<ProfilePasswordInput> {
  bool hidden = true;

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
              Icon(PhosphorIcons.lockSimple(),
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  obscureText: hidden,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
              IconButton(
                icon: Icon(
                  hidden ? PhosphorIcons.eyeSlash() : PhosphorIcons.eye(),
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => hidden = !hidden),
              )
            ],
          ),
        ),
      ],
    );
  }
}
