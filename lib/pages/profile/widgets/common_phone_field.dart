import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

class CommonPhoneField extends StatefulWidget {
  final String iso; // "TR"
  final String dialCode; // "+90"
  final String raw; // "5301234567"

  final Function({
    required String iso,
    required String dialCode,
    required String raw,
  }) onChanged;

  final String label;

  const CommonPhoneField({
    super.key,
    required this.iso,
    required this.dialCode,
    required this.raw,
    required this.onChanged,
    this.label = "Phone Number",
  });

  @override
  State<CommonPhoneField> createState() => _CommonPhoneFieldState();
}

class _CommonPhoneFieldState extends State<CommonPhoneField> {
  late String iso;
  late String dialCode;
  late String raw;

  @override
  void initState() {
    super.initState();
    iso = widget.iso;
    dialCode = widget.dialCode;
    raw = widget.raw;
  }

  String _format(String raw, String iso) {
    if (raw.isEmpty) return "";
    try {
      final parsed =
          PhoneNumber.parse(raw, callerCountry: IsoCode.fromJson(iso));
      return parsed.formatNsn();
    } catch (_) {
      return raw;
    }
  }

  String _extractDigits(String input) {
    return input.replaceAll(RegExp(r"[^0-9]"), "");
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _format(raw, iso);
    final controller = TextEditingController(text: formatted);
    controller.selection = TextSelection.collapsed(offset: formatted.length);

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
            border: Border.all(
              color: AppColors.border.withOpacity(0.6), // diğer inputlarla aynı border tonu
              width: 1,
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (c) {
                      setState(() {
                        iso = c.countryCode;
                        dialCode = "+${c.phoneCode}";
                        raw = "";
                      });
                      widget.onChanged(
                        iso: iso,
                        dialCode: dialCode,
                        raw: "",
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Text(
                      Country.tryParse(iso)?.flagEmoji ?? "🏳️",
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dialCode,
                style: AppTextStyles.bodyStrong,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    final digits = _extractDigits(value);
                    raw = digits;

                    try {
                      final parsed = PhoneNumber.parse(
                        digits,
                        callerCountry: IsoCode.fromJson(iso),
                      );
                      final f = parsed.formatNsn();
                      if (f != value) {
                        controller.text = f;
                        controller.selection =
                            TextSelection.collapsed(offset: f.length);
                      }
                    } catch (_) {}

                    widget.onChanged(
                      iso: iso,
                      dialCode: dialCode,
                      raw: raw,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
