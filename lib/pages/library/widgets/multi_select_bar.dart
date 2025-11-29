// ===================== File: lib/pages/library/widgets/multi_select_bar.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';
import '../controllers/library_controller.dart';
import 'new_collection_dialog.dart';
import 'save_question_to_collection_sheet.dart';

class LibraryMultiSelectBar extends StatelessWidget {
  const LibraryMultiSelectBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Obx(() {
      if (!c.isSelecting.value) return const SizedBox.shrink();

      final count = c.selectedQuestionIds.length;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // -------- LEFT: COUNT --------
            Text(
              "$count selected",
              style: AppTextStyles.bodyStrong,
            ),

            const Spacer(),

            // -------- MOVE TO COLLECTION --------
            _ActionBtn(
              label: "Move",
              onTap: () async {
                final selectedCollectionId =
                    await _openMultiCollectionPicker(context, c);

                if (selectedCollectionId != null) {
                  await c.moveSelectedToCollection(selectedCollectionId);
                }
              },
            ),

            const SizedBox(width: AppSpacing.sm),

            // -------- NEW COLLECTION --------
            _ActionBtn(
              label: "New",
              onTap: () async {
                // 1) Dialog açılır
                final name = await Get.dialog<String?>(
                  NewCollectionDialog(),
                  barrierDismissible: true,
                );

                if (name == null || name.trim().isEmpty) return;

                final c = Get.find<LibraryController>();

                // 2) Backend createCollection tamamlanana kadar stream update bekle
                String? newId;

                await for (final list in c.collectionsStream) {
                  // controller createCollection sonrası autoSelectCollectionId set ediyor
                  if (c.autoSelectCollectionId.value != null) {
                    newId = c.autoSelectCollectionId.value;
                    break;
                  }
                }

                if (newId == null) return; // güvenlik

                // 3) Seçilenleri yeni oluşturulan koleksiyona taşı
                await c.moveSelectedToCollection(newId);
              },
            ),

            const SizedBox(width: AppSpacing.sm),

            // -------- DELETE --------
            _ActionBtn(
              label: "Delete",
              color: Colors.red,
              onTap: () {
                c.deleteSelectedQuestions();
              },
            ),

            const SizedBox(width: AppSpacing.sm),

            // -------- CANCEL --------
            GestureDetector(
              onTap: c.stopSelecting,
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<String?> _openMultiCollectionPicker(
      BuildContext context, LibraryController c) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: SaveQuestionToCollectionSheet.multi(
            selectedIds: c.selectedQuestionIds.toSet(),
          ),
        );
      },
    );

    // Seçim modu burada kapanmaz → Move işlemi bitince kapanır
    return result; // seçilen collection ID
  }
}

// ============================================================
// ⬛ Small Action Buttons
// ============================================================
class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionBtn({
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color ?? AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
