// ===================== File: ap_filter_row.dart =====================
// Purpose:
// Displays filter chips row
//
// Features:
// - Horizontal scrollable row
// - Uses ApFilterChip
// ===================================================================

import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import 'ap_filter_chip.dart';

class ApFilterRow extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onSelect;

  const ApFilterRow({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ApFilterChip(
              label: filter,
              isSelected: selectedFilter == filter,
              onTap: () => onSelect(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
