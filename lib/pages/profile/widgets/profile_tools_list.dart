// ===================== File: profile/widgets/profile_tools_list.dart =====================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';

class ProfileToolsList extends StatelessWidget {
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenInterviewResults;
  final VoidCallback onEditProfile;
  final VoidCallback onCVPressed;
  final bool hasCV;
  final VoidCallback onViewCV;
  final VoidCallback onUploadCV;

  const ProfileToolsList({
    super.key,
    required this.onOpenProgress,
    required this.onOpenInterviewResults,
    required this.onEditProfile,
    required this.onCVPressed,
    required this.hasCV,
    required this.onViewCV,
    required this.onUploadCV,
  });

  Widget _item({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 26, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyStrong),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _item(
          icon: PhosphorIcons.chartBar(),
          title: "View Detailed Progress",
          subtitle: "Your full analytics overview",
          onTap: onOpenProgress,
        ),
        _item(
          icon: PhosphorIcons.clipboardText(),
          title: "Interview Results",
          subtitle: "See results when companies submit",
          onTap: onOpenInterviewResults,
        ),
        _item(
          icon: PhosphorIcons.userCircle(),
          title: "Edit Profile",
          subtitle: "Update your personal information",
          onTap: onEditProfile,
        ),
        _item(
          icon: PhosphorIcons.filePdf(),
          title: hasCV ? "View CV" : "Upload CV",
          subtitle:
              hasCV ? "Preview or update your CV" : "Add your CV (PDF only)",
          onTap: hasCV ? onViewCV : onUploadCV,
        ),
      ],
    );
  }
}
