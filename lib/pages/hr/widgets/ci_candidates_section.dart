// ===================== File: ci_candidates_section.dart =====================
// Purpose:
// Candidate selection UI (Modal handled in UI layer)
//
// IMPORTANT:
// - Modal UI is here (NOT in controller)
// - Controller only holds state
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../constants/constants.dart';
import '../controllers/create_interview_controller.dart';

class CICandidatesSection extends StatelessWidget {
  const CICandidatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateInterviewController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= LABEL =================
        Text(
          "ASSIGN CANDIDATES",
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // ================= INPUT BOX =================
        GestureDetector(
          onTap: () => _openCandidateModal(context, controller),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Search candidates...",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Icon(
                  PhosphorIcons.magnifyingGlass(),
                  size: AppIconSizes.sm,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ================= SELECTED CHIPS =================
        Obx(() {
          final list = controller.selectedCandidates;

          if (list.isEmpty) return const SizedBox();

          final visible = list.length > 3 ? list.take(3).toList() : list;

          return Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ...visible.map((name) => _CandidateChip(
                    name: name,
                    onRemove: () => controller.removeCandidate(name),
                  )),
              if (list.length > 3)
                GestureDetector(
                  onTap: () => _openCandidateModal(context, controller),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      "+${list.length - 3} more",
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // ===============================
  // MODAL (UI LAYER)
  // ===============================
  void _openCandidateModal(
      BuildContext context, CreateInterviewController controller) {
    final tempSelected = controller.selectedCandidates.toList().obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Text(
                "Select Candidates",
                style: AppTextStyles.headline,
              ),

              const SizedBox(height: AppSpacing.md),

              // LIST
              Expanded(
                child: Obx(() {
                  return ListView(
                    children: controller.allCandidates.map((name) {
                      final isSelected = tempSelected.contains(name);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (val) {
                          if (val == true) {
                            tempSelected.add(name);
                          } else {
                            tempSelected.remove(name);
                          }
                        },
                        title: Text(name),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  );
                }),
              ),

              // DONE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.selectedCandidates.value = tempSelected.toList();
                    Get.back();
                  },
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ===============================
/// CHIP
/// ===============================
class _CandidateChip extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const _CandidateChip({
    required this.name,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoftBackground,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: AppTextStyles.chip),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14),
          ),
        ],
      ),
    );
  }
}
