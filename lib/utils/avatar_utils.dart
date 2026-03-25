import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AvatarUtils {
  static Color getColor(String? seed) {
    if (seed == null || seed.trim().isEmpty) {
      return AppColors.primary;
    }

    // Always use lowercased clean seed to ensure case doesn't change color
    final safeSeed = seed.trim().toLowerCase();

    final colors = [
      AppColors.cinnabar,
      AppColors.accentWinePlum,
      AppColors.accentRoyalPlum,
      AppColors.stormyTeal,
      AppColors.accentCeladon,
      AppColors.accentSpicyOrange,
      AppColors.honeyBronze,
    ];

    final index = safeSeed.codeUnits.fold(0, (a, b) => a + b) % colors.length;

    return colors[index];
  }

  static String getInitials(String? name, [String? surname]) {
    final cleanName = name?.trim() ?? '';
    final cleanSurname = surname?.trim() ?? '';

    // If both name and surname are provided
    if (cleanName.isNotEmpty && cleanSurname.isNotEmpty) {
      return '${cleanName[0]}${cleanSurname[0]}'.toUpperCase();
    }

    // If only one is provided (e.g., username in Duels/Private Room)
    final fallback = cleanName.isNotEmpty ? cleanName : cleanSurname;

    if (fallback.length >= 2) {
      // First and last letter as requested by user
      return '${fallback[0]}${fallback[fallback.length - 1]}'.toUpperCase();
    } else if (fallback.isNotEmpty) {
      return fallback[0].toUpperCase();
    }

    return '?';
  }
}
