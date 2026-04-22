import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class RdCandidatesGroupLabel extends StatelessWidget {
  final String title;
  final Color color;

  const RdCandidatesGroupLabel({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = title.toLowerCase() == "accepted";

    return Row(
      children: [
        /// 🔥 ICON (DYNAMIC)
        Icon(
          isAccepted
              ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) // ✅ Accepted
              : PhosphorIcons.xCircle(PhosphorIconsStyle.fill), // ❌ Rejected
          size: 16,
          color: color,
        ),

        const SizedBox(width: 6),

        /// 🔥 TEXT
        Text(
          title.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
