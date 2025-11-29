// ===================== File: lib/pages/library/widgets/move_to_collection_sheet.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

import '../controllers/library_controller.dart';
import '../services/library_service.dart';
import '../widgets/collection_tile.dart';
import '../widgets/new_collection_dialog.dart';

class MoveToCollectionSheet extends StatelessWidget {
  final List<String> questionIds; // move edilecek sorular
  final RxString selectedCollection = ''.obs;

  MoveToCollectionSheet({
    super.key,
    required this.questionIds,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Stack(
      children: [
        // ================================
        // MAIN CONTAINER
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // HANDLE
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.paleSlate.withOpacity(.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Move to Collection",
                      style: AppTextStyles.headline.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _closeButton(),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // CREATE NEW BUTTON
                GestureDetector(
                  onTap: () async {
                    final createdName = await _showCreateCollectionDialog(c);

                    if (createdName == null) return;

                    // stream güncellenmesi için küçük delay
                    await Future.delayed(const Duration(milliseconds: 350));

                    final match = c.lastRawCollections.firstWhereOrNull(
                          (x) =>
                      x.name.trim().toLowerCase() ==
                          createdName.trim().toLowerCase(),
                    );

                    if (match != null) {
                      selectedCollection.value = match.id;
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Create New Collection",
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),


                // COLLECTIONS LABEL
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
                  child: Text(
                    "Collections",
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),


                // LIST
                Expanded(
                  child: StreamBuilder<List<CollectionData>>(
                    stream: c.collectionsStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final collections = snapshot.data!;
                      c.lastRawCollections = collections;

                      if (collections.isEmpty) {
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
                        itemCount: collections.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = collections[index];

                          return Obx(() {
                            final isSelected = selectedCollection.value == item.id;

                            return CollectionTile(
                              name: item.name,
                              count: item.count,
                              isSelected: isSelected,
                              onTap: () {
                                selectedCollection.value = item.id;
                              },
                            );
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // ================================
        // FIXED "MOVE" BUTTON
        // ================================
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Obx(
                () {
              final enabled = selectedCollection.value.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: enabled
                      ? () => Get.back(result: selectedCollection.value)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    enabled ? AppColors.primary : AppColors.paleSlate,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Move"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Close button
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
