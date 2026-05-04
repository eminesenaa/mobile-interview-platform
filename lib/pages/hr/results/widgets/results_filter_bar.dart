import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class ResultsFilterBar extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const ResultsFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip("all", "All Time", PhosphorIcons.clock()),
          _chip("month", "This Month", PhosphorIcons.calendar()),
          _chip("30d", "Last 30d", PhosphorIcons.timer()),
          _chip("q1", "Q1 2025", PhosphorIcons.chartBar()),
        ],
      ),
    );
  }

  Widget _chip(String key, String label, IconData icon) {
    final isSelected = selected == key;

    return Padding(
      padding: const EdgeInsets.only(right: 8), // 🔥 spacing daha temiz
      child: GestureDetector(
        onTap: () => onChanged(key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
