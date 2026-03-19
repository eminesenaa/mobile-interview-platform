import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../utils/duel_category_style.dart';

/// ===============================================================
/// DuelCategoryCard
/// ---------------------------------------------------------------
/// A reusable category selection card used inside duel config modal.
///
/// Responsibilities:
/// - Displays category icon with dynamic color styling
/// - Handles selected / unselected UI states
/// - Provides smooth animated transitions
///
/// Notes:
/// - Uses design system constants (spacing, radius, durations)
/// - Avoids magic numbers for maintainability
/// ===============================================================
class DuelCategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;
  final double size;
  final VoidCallback? onTap;

  const DuelCategoryCard({
    super.key,
    required this.title,
    required this.color,
    required this.isSelected,
    this.size = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// Selected state background vs muted state
    final backgroundColor = isSelected
        ? color
        : color.withOpacity(0.2);

    /// Icon color changes depending on selection
    final iconColor = isSelected
        ? Colors.white
        : color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        alignment: Alignment.center,

        /// Category icon (from DuelCategoryStyle mapping)
        child: Icon(
          DuelCategoryStyle.getIcon(title),
          size: size * 0.32, // responsive scaling
          color: iconColor,
        ),
      ),
    );
  }
}