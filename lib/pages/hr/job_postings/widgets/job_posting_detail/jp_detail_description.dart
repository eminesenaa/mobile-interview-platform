import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

/// ===================== DESCRIPTION =====================
/// Shows:
/// - description text
/// - requirements (bullet list)
/// =======================================================

class JPDetailDescription extends StatelessWidget {
  final String description;
  final List<String> requirements;

  const JPDetailDescription({
    super.key,
    required this.description,
    required this.requirements,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DESCRIPTION",
          style: AppTextStyles.label.copyWith(fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...requirements.map((r) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• "),
                Expanded(child: Text(r)),
              ],
            )),
      ],
    );
  }
}
