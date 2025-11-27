// lib/pages/library/widgets/new_collection_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';
import '../controllers/library_controller.dart';

class NewCollectionDialog extends StatelessWidget {
  NewCollectionDialog({super.key});

  final TextEditingController ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: Get.width * 0.80,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "New Collection",
                style: AppTextStyles.headline.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: ctrl,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: "Collection name",
                  filled: true,
                  fillColor: AppColors.paleSlate.withOpacity(.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: Get.back,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: AppColors.paleSlate.withOpacity(.5),
                        ),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: AppTextStyles.button
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),

                  const SizedBox(width: 14),

                  ElevatedButton(
                    onPressed: () async {
                      final name = ctrl.text.trim();
                      if (name.isEmpty) return;

                      await c.createCollection(name);
                      Get.back(result: name);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Create",
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
