import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Basit koleksiyon tipi (UI için yeterli)
class CollectionLite {
  final String id;
  final String name;
  final int itemCount;
  CollectionLite({required this.id, required this.name, this.itemCount = 0});
}

/// SaveToCollectionSheet
/// - Pinterest vari "panoya kaydet" alt sayfası
/// - Controller yokken de kendi içinde mock listeyle çalışır
class SaveToCollectionSheet extends StatefulWidget {
  const SaveToCollectionSheet({
    super.key,
    required this.questionId,

    /// Başlangıçta seçili gelecek koleksiyon id'leri
    this.initialSelected = const {},

    /// All (genel liste) işaretli mi
    this.initialSavedToAll = false,

    /// Dışarıdan koleksiyonları verirsen controller'sız çalışır
    this.initialCollections,
  });

  final String questionId;
  final Set<String> initialSelected;
  final bool initialSavedToAll;
  final List<CollectionLite>? initialCollections;

  @override
  State<SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<SaveToCollectionSheet> {
  final TextEditingController _search = TextEditingController();

  /// UI state
  late Set<String> _selected;
  late bool _saveToAll;
  bool _isSaving = false;

  /// Koleksiyon listesi
  List<CollectionLite> _collections = [];
  List<CollectionLite> _filtered = [];

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    _saveToAll = widget.initialSavedToAll;

    _bootstrap();
    _search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // 1) Dışarıdan liste geldiyse onu kullan
    if (widget.initialCollections != null) {
      _collections = [...widget.initialCollections!];
      _filtered = [..._collections];
      setState(() {});
      return;
    }

    // 2) GetX controller varsa oradan yükle (opsiyonel)
    try {
      final hasCtrl = Get.isRegistered<dynamic>(tag: 'LibraryController') ||
          Get.isRegistered<dynamic>(); // gevşek kontrol
      if (hasCtrl) {
        // final c = Get.find<LibraryController>(); // gerçek tip bağlayınca aç
        // final data = await c.loadCollections();
        // _collections = data.map((e) => CollectionLite(
        //   id: e.id, name: e.name, itemCount: e.itemCount,
        // )).toList();
      } else {
        // 3) Mock (UI test için)
        _collections = [
          CollectionLite(id: 'ds', name: 'Data Structures', itemCount: 12),
          CollectionLite(id: 'algo', name: 'Algorithms', itemCount: 8),
          CollectionLite(id: 'sys', name: 'System Design', itemCount: 5),
          CollectionLite(id: 'str', name: 'Strings', itemCount: 7),
          CollectionLite(id: 'arr', name: 'Arrays', itemCount: 9),
        ];
      }
    } catch (_) {
      // fallback mock
      _collections = [
        CollectionLite(id: 'misc', name: 'My Collection', itemCount: 1),
      ];
    }
    _filtered = [..._collections];
    setState(() {});
  }

  void _onSearchChanged() {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) {
      _filtered = [..._collections];
    } else {
      _filtered = _collections
          .where((c) => c.name.toLowerCase().contains(q))
          .toList(growable: false);
    }
    setState(() {});
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _createCollection(String name) async {
    if (name.isEmpty) return;
    // Controller varsa burada çağıracağız:
    // final newCol = await c.createCollection(name);
    // Şimdilik local mock:
    final newCol = CollectionLite(id: name.toLowerCase(), name: name, itemCount: 0);
    setState(() {
      _collections.insert(0, newCol);
      _filtered = [..._collections];
      _selected.add(newCol.id);
      _search.clear();
    });
  }

  Future<void> _apply() async {
    setState(() => _isSaving = true);

    // Controller’a geçtiğimizde burada diff uygulayacağız:
    // await c.applySelection(widget.questionId, _selected, saveToAll: _saveToAll);

    await Future.delayed(const Duration(milliseconds: 350)); // küçük bekleme hissi
    setState(() => _isSaving = false);

    // Sonuçları geri döndür (isteğe bağlı)
    Get.back(result: {
      'selectedCollectionIds': _selected,
      'saveToAll': _saveToAll,
    });
    Get.snackbar('Saved', 'Your selections have been updated',
        snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
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
            // Grabber
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor, borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
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
                    if (name != null) _createCollection(name);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Quick row: Save to All toggle
            _QuickAllToggle(
              value: _saveToAll,
              onChanged: (v) => setState(() => _saveToAll = v),
            ),

            const SizedBox(height: 12),

            // Search
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search collections…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            // Create-from-search
            if (_search.text.trim().isNotEmpty &&
                !_collections.any((c) =>
                c.name.toLowerCase() == _search.text.trim().toLowerCase()))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _CreateFromSearchTile(
                  query: _search.text.trim(),
                  onCreate: () => _createCollection(_search.text.trim()),
                ),
              ),

            const SizedBox(height: 8),

            // List
            Expanded(
              child: _filtered.isEmpty
                  ? _EmptyState(onCreate: () async {
                final name = await showDialog<String>(
                  context: context,
                  builder: (ctx) => _CreateDialog(),
                );
                if (name != null) _createCollection(name);
              })
                  : ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final col = _filtered[i];
                  final selected = _selected.contains(col.id);
                  return _CollectionTile(
                    collection: col,
                    selected: selected,
                    onTap: () => _toggle(col.id),
                  );
                },
              ),
            ),

            // Bottom bar
            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _apply,
                  child: _isSaving
                      ? const SizedBox(
                    height: 20, width: 20,
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

class _QuickAllToggle extends StatelessWidget {
  const _QuickAllToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_add_outlined),
          const SizedBox(width: 8),
          const Expanded(child: Text('Save to All')),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.collection,
    required this.selected,
    required this.onTap,
  });

  final CollectionLite collection;
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
                  Text('${collection.itemCount} items',
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

class _CreateFromSearchTile extends StatelessWidget {
  const _CreateFromSearchTile({required this.query, required this.onCreate});
  final String query;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.add),
      title: Text('Create “$query”'),
      onTap: onCreate,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 10),
          Text('No collections yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Create your first collection to organize questions.',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create collection'),
            onPressed: onCreate,
          ),
        ],
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
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
