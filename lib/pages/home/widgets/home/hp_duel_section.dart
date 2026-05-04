// ===================== File: hp_duel_section.dart =====================
// Purpose:
// Wrapper for Duel Card
// ======================================================================

import 'package:flutter/material.dart';
import 'hp_duel_card.dart';


class HpDuelSection extends StatelessWidget {
  final VoidCallback onTap;

  const HpDuelSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HpDuelCard(onTap: onTap);
  }
}
