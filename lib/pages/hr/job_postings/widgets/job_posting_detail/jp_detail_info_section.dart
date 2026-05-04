import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

/// ===================== JOB INFO =====================
/// Displays key-value rows with:
/// - Left icon + label
/// - Right value
/// - Subtle divider between rows
/// ===================================================

class JPDetailInfoSection extends StatelessWidget {
  final Map<String, String> info;

  const JPDetailInfoSection({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final entries = info.entries.toList();

    return Column(
      children: List.generate(entries.length, (index) {
        final e = entries[index];
        final isLast = index == entries.length - 1;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// 🔥 LEFT: ICON + LABEL
                  Row(
                    children: [
                      Icon(
                        _getIcon(e.key),
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        e.key,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                  /// RIGHT VALUE
                  Flexible(
                    child: Text(
                      e.value,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyStrong,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔥 PREMIUM DIVIDER
            if (!isLast)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border.withOpacity(0.5),
              ),
          ],
        );
      }),
    );
  }

  /// ================= ICON MAPPING =================
  IconData _getIcon(String key) {
    switch (key.toLowerCase()) {
      case "position":
        return PhosphorIcons.briefcase();

      case "work type":
        return PhosphorIcons.laptop();

      case "location":
        return PhosphorIcons.mapPin();

      case "salary":
        return PhosphorIcons.currencyDollar();

      default:
        return PhosphorIcons.info();
    }
  }
}
