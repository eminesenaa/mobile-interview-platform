// ===================== File: ir_filter_row.dart =====================
// Purpose:
// Horizontal list of filter chips
// ===================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';
import 'ir_filter_chip.dart';

class IrFilterRow extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onSelect;

  const IrFilterRow({
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
        children: filters.map((f) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: IrFilterChip(
              label: f,
              isSelected: f == selectedFilter,
              onTap: () => onSelect(f),
            ),
          );
        }).toList(),
      ),
    );
  }
}
