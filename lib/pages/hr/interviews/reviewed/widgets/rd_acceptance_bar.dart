import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class RdAcceptanceBar extends StatelessWidget {
  final int accepted;
  final int rejected;

  const RdAcceptanceBar({
    super.key,
    required this.accepted,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    final total = accepted + rejected;
    final acceptedRatio = total == 0 ? 0.0 : accepted / total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$accepted Accepted",
                style: TextStyle(color: AppColors.success)),
            Text("$rejected Rejected",
                style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              Expanded(
                flex: (acceptedRatio * 100).toInt(),
                child: Container(
                  height: 8,
                  color: AppColors.success,
                ),
              ),
              Expanded(
                flex: (100 - (acceptedRatio * 100)).toInt(),
                child: Container(
                  height: 8,
                  color: AppColors.error.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
