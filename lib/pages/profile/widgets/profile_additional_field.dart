// ===================== File: profile_additional_field.dart =====================

import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

/// Field türlerini belirtiyoruz.
/// TEXT → School, Company
/// DROPDOWN → Role
/// LOCATION → Country + City
enum AdditionalFieldType { text, dropdown, location }

class ProfileAdditionalField extends StatefulWidget {
  final String label;
  final AdditionalFieldType type;

  /// TEXT alanları
  final String? initialValue;

  /// LOCATION için ikinci değer (city)
  final String? initialValue2;

  /// DROPDOWN için seçenek listesi
  final List<String>? options;

  /// Tek değer (text / dropdown)
  final Function(String)? onChanged;

  /// Location için iki değer
  final Function(String country, String city)? onChangedLocation;

  /// Hint text (opsiyonel)
  final String? hint;

  const ProfileAdditionalField({
    super.key,
    required this.label,
    required this.type,
    this.initialValue,
    this.initialValue2,
    this.options,
    this.onChanged,
    this.onChangedLocation,
    this.hint,
  });

  @override
  State<ProfileAdditionalField> createState() => _ProfileAdditionalFieldState();
}

class _ProfileAdditionalFieldState extends State<ProfileAdditionalField> {
  late TextEditingController textController;
  late TextEditingController cityController;

  String? dropdownSelected;
  String? selectedCountry;

  @override
  void initState() {
    super.initState();

    textController = TextEditingController(text: widget.initialValue ?? "");
    dropdownSelected = widget.initialValue;

    cityController = TextEditingController(text: widget.initialValue2 ?? "");
    selectedCountry = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.bodyStrong),
        const SizedBox(height: 6),

        // ----------------------
        // TYPE: TEXT
        // ----------------------
        if (widget.type == AdditionalFieldType.text)
          TextField(
            controller: textController,
            onChanged: widget.onChanged,
            decoration: _inputDecoration(widget.hint),
          ),

        // ----------------------
        // TYPE: DROPDOWN
        // ----------------------
        if (widget.type == AdditionalFieldType.dropdown)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,

                // ❗ VALUE sadece items içinde varsa ver
                value: (dropdownSelected != null &&
                        widget.options != null &&
                        widget.options!.contains(dropdownSelected))
                    ? dropdownSelected
                    : null,

                hint: Text(widget.hint ?? "Select", style: AppTextStyles.body),

                items: widget.options?.map((o) {
                  return DropdownMenuItem(
                    value: o,
                    child: Text(o, style: AppTextStyles.body),
                  );
                }).toList(),

                onChanged: (v) {
                  setState(() => dropdownSelected = v);
                  widget.onChanged?.call(v!);
                },
              ),
            ),
          ),

        // ----------------------
        // TYPE: LOCATION (country + city)
        // ----------------------
        if (widget.type == AdditionalFieldType.location) ...[
          _buildCountryPicker(),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: cityController,
            onChanged: (v) =>
                widget.onChangedLocation?.call(selectedCountry ?? "", v),
            decoration: _inputDecoration("City"),
          ),
        ],
      ],
    );
  }

  // COUNTRY PICKER
  Widget _buildCountryPicker() {
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (c) {
            setState(() => selectedCountry = c.name);
            widget.onChangedLocation?.call(
              selectedCountry ?? "",
              cityController.text,
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              selectedCountry ?? "Select country",
              style: AppTextStyles.body.copyWith(
                color: selectedCountry == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surface,
      hintText: hint,
      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}
