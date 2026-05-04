import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class JPDropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final String hint;
  final Function(String) onChanged;

  const JPDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      isDense: true,
      hint: Text(
        hint,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted.withOpacity(0.7),
        ),
      ),
      dropdownColor: AppColors.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      items: items.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: e == items.last
                    ? Center(
                        child: Text(
                          e,
                          style: AppTextStyles.bodyStrong,
                        ),
                      )
                    : Text(
                        e,
                        style: AppTextStyles.bodyStrong,
                      ),
              ),

              if (e != items.last)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border.withOpacity(0.5),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
