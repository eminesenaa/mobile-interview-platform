// lib/pages/library/widgets/filter_chips_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';
import '../controllers/library_controller.dart';

class LibraryFilterChipsBar extends StatelessWidget {
  const LibraryFilterChipsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Obx(() {
      final chips =
          c.activeFilterLabels; // 🔥 Az sonra controller'a ekleyeceğiz

      if (chips.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: AppSpacing.md,          // normal sol padding
          right: AppSpacing.xs,         // 🔥 sağ padding küçültüldü
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        color: AppColors.background,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          // 🔥 soldan hizalama
          runAlignment: WrapAlignment.start,
          // 🔥 alt satırlar da soldan başlasın
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: chips
              .map(
                (label) => _FilterChip(
                  label: label,
                  onRemove: () => c.removeSingleFilter(label),
                ),
              )
              .toList(),
        ),
      );
    });
  }
}

// ============================================================
//  CHIP WIDGET
// ============================================================
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm, // bir tık daha büyük
      ),
      decoration: BoxDecoration(
        color: AppColors.chipBackground, // 🔥 Practice chip grisi
        borderRadius: BorderRadius.circular(AppRadius.md), // daha yuvarlak
        border: Border.all(color: AppColors.border), // daha soft
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.chip.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              PhosphorIcons.x(),
              size: 15,
              color: AppColors.textSecondary,
            ),
          )
        ],
      ),
    );
  }
}
