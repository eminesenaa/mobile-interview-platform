// ===================== File: lib/pages/library/widgets/save_question_to_collection_sheet.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

import '../controllers/library_controller.dart';
import '../services/library_service.dart';

import 'package:collection/collection.dart';

// Widgets
import '../widgets/collection_tile.dart';
import '../widgets/new_collection_dialog.dart';
import '../widgets/save_bottom_button.dart';

class SaveQuestionToCollectionSheet extends StatelessWidget {
  final String questionId;

  SaveQuestionToCollectionSheet({super.key, required this.questionId});

  final RxSet<String> selected = <String>{}.obs;

  // Pop-up açma fonksiyonu
  void _openNewCollectionDialog() {
    Get.dialog(NewCollectionDialog());
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Stack(
      children: [
        // ================================
        // ANA ARKA PLAN VE İÇERİK
        // ================================
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),

                // HANDLE
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.paleSlate.withOpacity(.8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Save to…",
                      style: AppTextStyles.headline.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        _addButton(() async {
                          final createdName =
                              await _showCreateCollectionDialog(c);

                          if (createdName == null) return;

                          c.search.value = "";

                          // Stream güncellendiğinde otomatik yakalamak için küçük delay
                          /// 🔥 Firestore stream’in güncellenmesi için küçük delay
                          await Future.delayed(
                              const Duration(milliseconds: 350));

                          final list = c.lastRawCollections;

                          final match = list.firstWhereOrNull(
                            (x) =>
                                x.name.trim().toLowerCase() ==
                                createdName.trim().toLowerCase(),
                          );

                          if (match != null) {
                            selected.add(match.id); // otomatik seç
                          }
                        }),
                        const SizedBox(width: 6),
                        _closeButton(),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // SEARCH FIELD
                TextField(
                  onChanged: (v) => c.search.value = v,
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: "Search collections",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.paleSlate.withOpacity(.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ================================
                // LİSTE
                // ================================
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: StreamBuilder<List<CollectionData>>(
                      stream: c.collectionsStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final rawList = snapshot.data!;
                        c.lastRawCollections = rawList;
                        return Obx(() {
                          final list = c.filteredCollections(rawList);

                          if (list.isEmpty) {
                            return Center(
                              child: Text(
                                "No collections yet.",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final item = list[index];
                              final autoId = c.autoSelectCollectionId.value;
                              if (autoId != null && item.id == autoId) {
                                // ✔ Önce seçim yap
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  selected.add(autoId);

                                  // ✔ Sonraki frame'de temizle (hiçbir şeyi bozmadan)
                                  Future.microtask(() {
                                    c.autoSelectCollectionId.value = null;
                                  });
                                });
                              }


                              return Obx(() {
                                final isSelected = selected.contains(item.id);

                                return CollectionTile(
                                  name: item.name,
                                  count: item.count,
                                  isSelected: isSelected,
                                  onTap: () {
                                    isSelected
                                        ? selected.remove(item.id)
                                        : selected.add(item.id);
                                  },
                                );
                              });
                            },
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ================================
        // SABİT "SAVE" BUTONU
        // ================================
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() {
              final enabled = selected.isNotEmpty;

              return SaveBottomButton(
                enabled: enabled,
                onPressed: enabled
                    ? () async {
                        for (final id in selected) {
                          await LibraryService.instance
                              .addToCollection(id, questionId);
                        }
                        Get.back();
                      }
                    : null,
              );
            }),
          ),
        ),
      ],
    );
  }

  // ================================
  // BUTTON WIDGETS
  // ================================

  Widget _addButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: AppColors.primary, size: 22),
      ),
    );
  }

  Widget _closeButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.paleSlate.withOpacity(.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.textPrimary,
          size: 21,
        ),
      ),
    );
  }
}

Future<String?> _showCreateCollectionDialog(LibraryController c) async {
  return await Get.dialog<String?>(
    NewCollectionDialog(),
    barrierDismissible: true,
  );
}
