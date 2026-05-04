// ===================== FILE: cad_header.dart =====================
// Purpose:
// Top section of candidate application detail
//
// FIX:
// - Fully centered layout
// - Text align center
// ================================================================

import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class CADHeader extends StatelessWidget {
  final String name;
  final String position;
  final String status;

  const CADHeader({
    super.key,
    required this.name,
    required this.position,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // 🔥 FIX
      children: [
        /// ================= AVATAR =================
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            _initials(name),
            style: AppTextStyles.headline.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// ================= NAME =================
        Text(
          name,
          textAlign: TextAlign.center, // 🔥 FIX
          style: AppTextStyles.headline,
        ),

        const SizedBox(height: 4),

        /// ================= POSITION =================
        Text(
          position,
          textAlign: TextAlign.center, // 🔥 FIX
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: 10),

        /// ================= STATUS CHIP =================
        _statusChip(),
      ],
    );
  }

  Widget _statusChip() {
    late Color color;

    switch (status) {
      case "accepted":
        color = AppColors.success;
        break;
      case "rejected":
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(" ");
    if (parts.length == 1) return parts[0][0];
    return parts[0][0] + parts[1][0];
  }
}