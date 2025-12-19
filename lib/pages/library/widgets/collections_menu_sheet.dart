import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../controllers/library_controller.dart';

/// Modern, Apple Notes tarzında bottom sheet menu.
class CollectionsMenuSheet extends StatelessWidget {
  const CollectionsMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        boxShadow: AppShadows.medium,
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.lg,
      ),
      child: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Grab handle ----
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),

            // ==== Select Collections ====
            _MenuItem(
              icon: PhosphorIcons.checkSquareOffset(),
              title: "Select Collections",
              selected: false,
              onTap: () {
                Navigator.pop(context);
                c.startCollectionSelecting();
              },
            ),

            const Divider(height: 1, color: AppColors.border),

            // ==== A → Z ====
            _MenuItem(
              icon: PhosphorIcons.textAa(),
              title: "Sort by Name (A → Z)",
              selected:
                  c.sortMode.value == CollectionSortMode.nameAsc,
              onTap: () {
                Navigator.pop(context);
                c.sortMode.value = CollectionSortMode.nameAsc;
              },
            ),

            // ==== Newest ====
            _MenuItem(
              icon: PhosphorIcons.clock(),
              title: "Sort by Created (Newest First)",
              selected:
                  c.sortMode.value == CollectionSortMode.createdDesc,
              onTap: () {
                Navigator.pop(context);
                c.sortMode.value = CollectionSortMode.createdDesc;
              },
            ),
          ],
        );
      }),
    );
  }
}

/// -----------------------
///  REUSABLE MENU ITEM
/// -----------------------
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: selected
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.6),
                    width: 1, // ⭐ ince border
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.bodyStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
