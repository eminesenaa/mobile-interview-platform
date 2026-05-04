// ===================== File: np_account_section.dart =====================
// Purpose:
// Account actions section
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';
import 'np_action_tile.dart';

class NpAccountSection extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onResults;
  final VoidCallback onSettings;

  const NpAccountSection({
    super.key,
    required this.onEdit,
    required this.onResults,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Account".toUpperCase(),
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
            )),
        const SizedBox(height: AppSpacing.md),
        NpActionTile(
          title: "Edit Profile",
          subtitle: "Update your information",
          icon: PhosphorIcons.pencilSimple(),
          onTap: onEdit,
        ),
        const SizedBox(height: AppSpacing.sm),
        NpActionTile(
          title: "Interview Results",
          subtitle: "View your interview outcomes",
          icon: PhosphorIcons.clipboardText(),
          onTap: onResults,
        ),
        const SizedBox(height: AppSpacing.sm),
        NpActionTile(
          title: "Settings",
          subtitle: "App preferences",
          icon: PhosphorIcons.gear(),
          onTap: onSettings,
        ),
      ],
    );
  }
}
