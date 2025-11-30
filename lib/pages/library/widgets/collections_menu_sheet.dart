import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../constants/constants.dart';
import '../controllers/library_controller.dart';
import 'package:get/get.dart';

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
      child: Column(
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
            onTap: () {
              Navigator.pop(context);
              c.sortMode.value = CollectionSortMode.nameAsc;
            },
          ),

          _MenuItem(
            icon: PhosphorIcons.clock(),
            title: "Sort by Created (Newest First)",
            onTap: () {
              Navigator.pop(context);
              c.sortMode.value = CollectionSortMode.createdDesc;
            },
          ),
        ],
      ),
    );
  }
}

/// -----------------------
///  REUSABLE MENU ITEM
/// -----------------------
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
    );
  }
}
