// ===================== FILE: cad_links_section.dart =====================
// Displays portfolio / github / linkedin links
// =======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class CADLinksSection extends StatelessWidget {
  final String? portfolio;
  final String? github;
  final String? linkedin;

  const CADLinksSection({
    super.key,
    this.portfolio,
    this.github,
    this.linkedin,
  });

  @override
  Widget build(BuildContext context) {
    return _card(
      Column(
        children: [
          if (portfolio != null)
            _row(PhosphorIcons.globe(), "Portfolio", portfolio!),
          if (github != null) _divider(),
          if (github != null)
            _row(PhosphorIcons.githubLogo(), "GitHub", github!),
          if (linkedin != null) _divider(),
          if (linkedin != null)
            _row(PhosphorIcons.linkedinLogo(), "LinkedIn", linkedin!),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: AppColors.border.withOpacity(0.6));

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
