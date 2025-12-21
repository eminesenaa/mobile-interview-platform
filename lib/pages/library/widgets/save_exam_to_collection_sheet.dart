import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SaveExamToCollectionSheet extends StatefulWidget {
  final String examId;

  const SaveExamToCollectionSheet({
    super.key,
    required this.examId,
  });

  @override
  State<SaveExamToCollectionSheet> createState() =>
      _SaveExamToCollectionSheetState();
}

class _SaveExamToCollectionSheetState extends State<SaveExamToCollectionSheet> {
  // NOTE: Şimdilik frontend-only; backend bağlanınca bunlar controller’dan gelecek.
  final List<_CollectionUi> _collections = [
    _CollectionUi(id: 'c1', name: 'network questions', itemCount: 2),
    _CollectionUi(id: 'c2', name: 'algorithms', itemCount: 5),
  ];

  final Set<String> _selected = {};

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _createCollection() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Collection name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );

    if (ok == true && controller.text.trim().isNotEmpty) {
      setState(() {
        _collections.add(_CollectionUi(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: controller.text.trim(),
          itemCount: 0,
        ));
      });
    }
  }

  void _save() {
    // Front-only: burada sadece snack gösteriyoruz.
    // Backend bağlanınca, _selected içindeki collectionId’lere widgets.examId ile kaydet.
    final count = _selected.length;
    Navigator.pop(context); // sheet’i kapat
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(count == 0
            ? 'No collection selected.'
            : 'Exam saved to $count collection${count > 1 ? "s" : ""} (frontend).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yüksek sheet görünümü
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // drag handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Save to…',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Create collection',
                      icon: const Icon(Icons.add),
                      onPressed: _createCollection,
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Collections list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _collections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final it = _collections[i];
                    final checked = _selected.contains(it.id);
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _toggle(it.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.12)),
                        ),
                        child: Row(
                          children: [
                            _DocThumb(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.name, style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 2),
                                  Text('${it.itemCount} item${it.itemCount == 1 ? "" : "s"}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.black54)),
                                ],
                              ),
                            ),
                            Checkbox(value: checked, onChanged: (_) => _toggle(it.id)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Save button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: Text('Save (${_selected.length})'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.library_books_outlined, size: 22),
    );
  }
}

class _CollectionUi {
  final String id;
  final String name;
  final int itemCount;

  _CollectionUi({
    required this.id,
    required this.name,
    required this.itemCount,
  });
}
