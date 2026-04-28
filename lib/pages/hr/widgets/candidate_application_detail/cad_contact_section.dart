// ===================== FILE: cad_contact_section.dart =====================
// Displays candidate contact info with icons
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class CADContactSection extends StatelessWidget {
  final String email;
  final String phone;
  final String location;

  const CADContactSection({
    super.key,
    required this.email,
    required this.phone,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return _card(
      Column(
        children: [
          _row(PhosphorIcons.envelope(), "Email", email),
          _divider(),
          _row(PhosphorIcons.phone(), "Phone", phone),
          _divider(),
          _row(PhosphorIcons.mapPin(), "Location", location),
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
          Text(value, style: AppTextStyles.bodyStrong),
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
