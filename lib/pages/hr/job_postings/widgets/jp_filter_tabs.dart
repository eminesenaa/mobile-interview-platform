import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class JPFilterTabs extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const JPFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tab("active", "Active Postings"),
        _tab("closed", "Closed Postings"),
      ],
    );
  }

  Widget _tab(String key, String label) {
    final isSelected = selected == key;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(key),
        child: Container(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodyStrong.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
