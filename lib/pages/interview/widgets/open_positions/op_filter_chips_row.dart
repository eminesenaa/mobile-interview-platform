// ===================== File: op_filter_chips_row.dart =====================
// Purpose:
// Horizontal scrollable row of filter chips
//
// Features:
// - Scrollable
// - Dynamic list from controller
// ========================================================================

import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';
import 'op_filter_chip.dart';

class OpFilterChipsRow extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const OpFilterChipsRow({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: OpFilterChip(
              label: filter,
              isSelected: selectedFilter == filter,
              onTap: () => onFilterSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
