import 'package:flutter/material.dart';

class SearchAddBar extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onAddPressed;
  final VoidCallback onRandomPressed;
  final bool canAdd;

  const SearchAddBar({
    super.key,
    required this.searchText,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onAddPressed,
    required this.onRandomPressed,
    this.canAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // 🔍 Search Box
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by title...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ⚙️ Filter
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilterPressed,
            tooltip: 'Filter',
          ),

          // ➕ Add to Library
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: canAdd ? onAddPressed : null,
            tooltip: 'Add to Library',
            color: canAdd ? Colors.blue : Colors.grey,
          ),

          // 🎲 Random
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: onRandomPressed,
            tooltip: 'Random Question',
          ),
        ],
      ),
    );
  }
}
