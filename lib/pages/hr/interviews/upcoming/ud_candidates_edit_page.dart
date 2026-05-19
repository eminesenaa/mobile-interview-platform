import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../constants/constants.dart';
import '../../controllers/hr_upcoming_detail_controller.dart';

class UDCandidatesEditPage extends StatelessWidget {
  final RxList<Map<String, dynamic>> candidates;

  const UDCandidatesEditPage({
    super.key,
    required this.candidates,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HRUpcomingDetailController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Candidates"),
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: candidates.length,
                itemBuilder: (_, index) {
                  final c = candidates[index];

                  return _CandidateTile(
                    candidate: c,
                    onRemove: () => controller.removeCandidate(c),
                  );
                },
              ),
            ),

            // ================= ADD BUTTON =================
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [

                  // ================= ADD BUTTON =================
                  GestureDetector(
                    onTap: () => _openAddDialog(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.6),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Center(
                        child: Text(
                          "Add Candidate",
                          style: AppTextStyles.textButton,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ================= SAVE BUTTON =================
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  void _openAddDialog(BuildContext context) {
    Get.dialog(_AddCandidateDialog(candidates: candidates));
  }
}

class _CandidateTile extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final VoidCallback onRemove;

  const _CandidateTile({
    required this.candidate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final name = candidate["name"] ?? "";
    final email = candidate["email"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.low,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(name[0]),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyStrong),
                Text(email, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCandidateDialog extends StatefulWidget {
  final RxList<Map<String, dynamic>> candidates;

  const _AddCandidateDialog({
    required this.candidates,
  });

  @override
  State<_AddCandidateDialog> createState() => _AddCandidateDialogState();
}

class _AddCandidateDialogState extends State<_AddCandidateDialog> {
  final searchCtrl = TextEditingController();

  final mockUsers = [
    {"name": "Tom Rivera", "email": "tom@email.com"},
    {"name": "Emma Liu", "email": "emma@email.com"},
    {"name": "Daniel Wu", "email": "daniel@email.com"},
  ];

  final selected = <Map<String, dynamic>>[];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Candidates", style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                hintText: "Search candidate...",
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...mockUsers.map((u) {
              final isSelected = selected.contains(u);

              return CheckboxListTile(
                value: isSelected,
                title: Text(u["name"] ?? ""),
                subtitle: Text(u["email"] ?? ""),
                onChanged: (_) {
                  setState(() {
                    if (isSelected) {
                      selected.remove(u);
                    } else {
                      selected.add(u);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onPressed: () {
                    widget.candidates.addAll(selected);
                    Get.back();
                  },
                  child: const Text("Add"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
