// ===================== File: ir_empty_state.dart =====================
// Purpose:
// Displayed when no widgets found
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class IrEmptyState extends StatelessWidget {
  const IrEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            PhosphorIcons.folderOpen(),
            size: 40,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "No interview results found",
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
