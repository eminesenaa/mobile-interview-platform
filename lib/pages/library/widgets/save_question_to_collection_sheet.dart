// ===================== File: lib/pages/library/widgets/save_question_to_collection_sheet.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/library_service.dart';

/// SaveToCollectionSheet
/// Firestore'daki koleksiyonlara kaydetme/dinleme sheet'i
class SaveToCollectionSheet extends StatefulWidget {
  final String questionId;
  const SaveToCollectionSheet({super.key, required this.questionId});

  @override
  State<SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<SaveToCollectionSheet> {
  final TextEditingController _search = TextEditingController();
  Set<String> _selected = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialSelection(); // ✅ açıldığında mevcut koleksiyonları getir
  }

  Future<void> _loadInitialSelection() async {
    final lib = LibraryService.instance;
    final collections = await lib.getCollectionsOfQuestion(widget.questionId);
    setState(() {
      _selected = collections.toSet(); // ✅ zaten içinde olanlar tikli
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    setState(() => _isSaving = true);

    final lib = LibraryService.instance;

    // önce tüm koleksiyonlardan çıkar
    final cols = await lib.getCollections();
    for (final c in cols) {
      final isIn = await lib.isInCollection(c.id, widget.questionId);
      if (isIn && !_selected.contains(c.id)) {
        await lib.removeQuestionEverywhere(widget.questionId);
      }
    }

    // sonra seçili olanlara ekle
    for (final id in _selected) {
      await lib.addToCollection(id, widget.questionId);
    }

    setState(() => _isSaving = false);

    Get.back();
    Get.snackbar('Saved', 'Your selections have been updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        height: mq.size.height * 0.82,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Text('Save to…', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'New collection',
                  onPressed: () async {
                    final name = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _CreateDialog(),
                    );
                    if (name != null && name.trim().isNotEmpty) {
                      await LibraryService.instance.createCollection(name.trim());
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // StreamBuilder ile koleksiyonları dinle
            Expanded(
              child: StreamBuilder<List<CollectionData>>(
                stream: LibraryService.instance.collectionsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final collections = snapshot.data!;
                  final q = _search.text.trim().toLowerCase();
                  final filtered = q.isEmpty
                      ? collections
                      : collections
                          .where((c) => c.name.toLowerCase().contains(q))
                          .toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No collections yet.'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final col = filtered[i];
                      final selected = _selected.contains(col.id);
                      return _CollectionTile(
                        collection: col,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selected.remove(col.id);
                            } else {
                              _selected.add(col.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),

            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _apply,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Save (${_selected.length})'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---- Widgets ----

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.collection,
    required this.selected,
    required this.onTap,
  });

  final CollectionData collection;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
          ),
          color: selected
              ? theme.colorScheme.primary.withOpacity(.06)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            const Icon(Icons.collections_bookmark_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(collection.name,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text('${collection.count} items',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Checkbox(value: selected, onChanged: (_) => onTap()),
          ],
        ),
      ),
    );
  }
}

class _CreateDialog extends StatefulWidget {
  @override
  State<_CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<_CreateDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New collection'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Collection name',
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
