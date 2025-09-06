import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/utils/string_extensions.dart';


class MultiSelectField extends StatelessWidget {
  final String title;                 // yalnızca sheet başlığı için (metinde gösterilmiyor)
  final RxList<String> optionsList;   // controller’dan: availableTopics / availableTags
  final RxSet<String> selectedSet;    // controller’dan: topics / tags
  final String buttonLabel;           // "Select Topics" / "Select Tags"

  const MultiSelectField({
    super.key,
    required this.title,
    required this.optionsList,
    required this.selectedSet,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const primary = primaryColor;
    const selectedBg = secondaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // seçili öğeleri chip olarak göster
        Obx(() {
          final items = selectedSet.toList()..sort();
          if (items.isEmpty) {
            return Text('No $title selected',
                style: Theme.of(context).textTheme.bodySmall);
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((e) {
              return InputChip(
                label: Text(
                  e.toDisplayLabel(),
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onDeleted: () => selectedSet.remove(e),
                backgroundColor: selectedBg,
                side: BorderSide(color: primary.withValues(alpha: .35)),
                deleteIconColor: primary,
                // köşeler senin tasarıma daha çok benzesin
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 8),

        OutlinedButton(
          onPressed: () => _openSelector(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_drop_down_rounded,
                color: primaryColor, // ikon rengi
              ),
              const SizedBox(width: 6),
              Text(
                buttonLabel,
                style: const TextStyle(
                  color: primaryColor,           // yazı rengi
                  fontWeight: FontWeight.w600,   // biraz daha belirgin
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openSelector(BuildContext context) {
    final controller = TextEditingController();
    final primary = primaryColor;

    final selectedBg = primary.withValues(alpha: .14);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                String q = controller.text.trim().toLowerCase();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search',
                        ),
                        onChanged: (_) => setState(() {}), // sadece arama metni için
                      ),
                      const SizedBox(height: 8),

                      // 🔧 Reaktif listeyi burada hesapla
                      Expanded(
                        child: Obx(() {
                          // Obx'in subscribe olmasını garanti etmek için
                          final _optLen = optionsList.length; // <-- dokunuyoruz
                          final _selLen = selectedSet.length;  // <-- dokunuyoruz

                          // tüm seçenekler ve filtre
                          final all = optionsList.toList();
                          final filtered = q.isEmpty
                              ? all
                              : all
                              .where((e) => e.toLowerCase().contains(q))
                              .toList();

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final item = filtered[i];
                              final checked = selectedSet.contains(item);
                              return CheckboxListTile(
                                value: checked,
                                onChanged: (_) =>
                                checked ? selectedSet.remove(item) : selectedSet.add(item),
                                title: Text(item.toDisplayLabel()),
                                // M3 için:
                                fillColor: MaterialStateProperty.resolveWith<Color?>(
                                      (states) => states.contains(MaterialState.selected) ? primary : null,
                                ),
                                // M2 geriye dönük:
                                activeColor: primary,
                                checkColor: Colors.white,
                                checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: BorderSide(color: primary.withOpacity(.5)),
                              );
                            },
                          );
                        }),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                            ),
                            onPressed: () => selectedSet.clear(),
                            child: const Text('Clear all'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Done'),
                          ),
                        ],
                      ),

                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }



}
