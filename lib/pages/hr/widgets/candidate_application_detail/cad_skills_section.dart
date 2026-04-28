// ===================== FILE: cad_skills_section.dart =====================
// Displays skills as chips
//
// IMPROVEMENTS:
// - Min height → container hep dolu görünür
// - Custom color palette (loop)
// - Chipler daha premium görünüm
// ========================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class CADSkillsSection extends StatelessWidget {
  final List<String> skills;

  const CADSkillsSection({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return _card(
      Container(
        width: double.infinity,

        /// 🔥 min height → az skill olsa bile dolu görünür
        constraints: const BoxConstraints(minHeight: 60),

        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(skills.length, (index) {
            final skill = skills[index];

            /// 🔥 color palette (loop)
            final color = _colors[index % _colors.length];

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.4),
                ),
              ),
              child: Text(
                skill,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 🔥 CUSTOM COLOR PALETTE (loop olacak)
  static const List<Color> _colors = [
    AppColors.cinnabar,
    AppColors.accentRoyalPlum,
    AppColors.stormyTeal,
    AppColors.accentCeladon,
    AppColors.accentSpicyOrange,
    AppColors.honeyBronze,
    AppColors.pinkCarnation,
    AppColors.topicTurquoise,
  ];

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
