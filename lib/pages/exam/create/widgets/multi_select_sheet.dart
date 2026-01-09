import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';

class MultiSelectSheet extends StatefulWidget {
  final String title;
  final RxList<String> options;
  final RxSet<String> selected;

  const MultiSelectSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
  });

  @override
  State<MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<MultiSelectSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where(
          (e) => e.toLowerCase().contains(_search.toLowerCase().trim()),
        )
        .toList()
      ..sort();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              widget.title,
              style: AppTextStyles.title,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Search
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),

            const SizedBox(height: AppSpacing.md),

            // Options
            Expanded(
              child: Obx(() {
                final _ = widget.selected.length;

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    final selected = widget.selected.contains(item);

                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: selected,
                      onChanged: (_) => selected
                          ? widget.selected.remove(item)
                          : widget.selected.add(item),
                      title: Text(
                        item,
                        style: AppTextStyles.body.copyWith(
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        width: 1.4,
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: AppSpacing.md),

            // Done
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
