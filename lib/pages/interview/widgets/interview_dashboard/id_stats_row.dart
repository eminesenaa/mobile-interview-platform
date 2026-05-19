// ===================== File: id_stats_row.dart =====================
// Purpose:
// Row of dashboard stat chips (premium style)
//
// Design:
// - Neutral chips
// - Colored indicator dots
// - Wrap for responsiveness
// ===================================================================

import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';
import 'id_stat_chip.dart';

class IdStatsRow extends StatelessWidget {
  final int applications;
  final int interviews;
  final int results;

  const IdStatsRow(
      {super.key,
      required this.applications,
      required this.interviews,
      required this.results});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        IdStatChip(
          text: "$applications applications active",
          color: AppColors.topicTurquoise,
        ),
        IdStatChip(
          text: "$interviews interview ready",
          color: AppColors.darkCyan,
        ),
        IdStatChip(
          text: "$results results pending",
          color: AppColors.honeyBronze,
        ),
      ],
    );
  }
}
