// ===================== FILE: cad_resume_section.dart =====================
// Displays resume file card
// ========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

class CADResumeSection extends StatelessWidget {
  final String fileName;

  const CADResumeSection({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return _card(
      Row(
        children: [
          Icon(PhosphorIcons.filePdf(), color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(fileName)),
          TextButton(onPressed: () {}, child: const Text("Download"))
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
