extension DisplayLabel on String {
  /// Convert a raw identifier like "binary-search" or "linked list"
  /// into a user-friendly label with capitalized words.
  ///
  /// Examples:
  ///   "binary-search"     -> "Binary-Search"
  ///   "linked list"       -> "Linked List"
  ///   "heap-sort algo"    -> "Heap-Sort Algo"
  String toDisplayLabel() {
    return split(' ').map((part) {
      return part.split('-').map((sub) {
        if (sub.isEmpty) return sub;
        return sub[0].toUpperCase() + sub.substring(1);
      }).join('-');
    }).join(' ');
  }
}
