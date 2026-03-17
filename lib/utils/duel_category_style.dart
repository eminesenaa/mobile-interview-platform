import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:interview_project/constants/colors.dart';

/// ===============================================================
/// DuelCategoryStyle
/// ---------------------------------------------------------------
/// Kategoriye göre:
/// - Renk
/// - Icon
/// - (ileride gradient, glow vs.)
/// merkezi olarak yönetilir.
/// ===============================================================
class DuelCategoryStyle {
  static Color getColor(String category) {
    switch (category) {
      case "Mixed":
        return AppColors.cinnabar;

      case "Programming":
        return AppColors.accentWinePlum;

      case "Algorithms":
        return AppColors.accentRoyalPlum;

      case "Data & AI":
        return AppColors.stormyTeal;

      case "Databases":
        return AppColors.accentCeladon;

      case "Systems":
        return AppColors.accentSpicyOrange;

      case "Soft Skills":
        return AppColors.honeyBronze;

      default:
        return AppColors.primary;
    }
  }

  static IconData getIcon(String category) {
    switch (category) {
      case "Mixed":
        return PhosphorIcons.shuffle();

      case "Programming":
        return PhosphorIcons.code();

      case "Algorithms":
        return PhosphorIcons.treeStructure();

      case "Data & AI":
        return PhosphorIcons.brain();

      case "Databases":
        return PhosphorIcons.database();

      case "Systems":
        return PhosphorIcons.network();

      case "Soft Skills":
        return PhosphorIcons.users();

      default:
        return PhosphorIcons.question();
    }
  }
}
