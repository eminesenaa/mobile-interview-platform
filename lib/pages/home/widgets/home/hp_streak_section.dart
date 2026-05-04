// ===================== File: hp_streak_section.dart =====================
// Purpose:
// Wrapper for existing StreakCard (TYPE SAFE VERSION)
// ======================================================================

import 'package:flutter/material.dart';
import 'hp_streak_card.dart';

class HpStreakSection extends StatelessWidget {
  final int current;
  final int longest;

  // ✅ FIX: doğru type
  final Map<String, bool> history;

  const HpStreakSection({
    super.key,
    required this.current,
    required this.longest,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return StreakCard(
      currentStreak: current,
      longestStreak: longest,
      history: history,
    );
  }
}
