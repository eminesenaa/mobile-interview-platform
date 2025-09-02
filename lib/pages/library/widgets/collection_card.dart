import 'package:flutter/material.dart';

import '../../../models/collection.dart';

class CollectionCard extends StatelessWidget {
  final String name;
  final int count;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const CollectionCard({
    super.key,
    required this.name,
    required this.count,
    required this.onTap,
    this.onLongPress,
    this.icon = Icons.collections_bookmark_outlined,
    this.padding = const EdgeInsets.all(14),
  });

  /// NEW: Model tabanlı named constructor
  CollectionCard.fromCollection({
    Key? key,
    required Collection collection,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    IconData icon = Icons.collections_bookmark_outlined,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) : this(
    key: key,
    name: collection.name,
    count: collection.itemCount,
    onTap: onTap ?? () {},
    onLongPress: onLongPress,
    icon: icon,
    padding: padding,
  );




  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Collection: $name, $count items',
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 0.5,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst görsel/ikon alanı – gridteki karo boyuna elastik uyar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceVariant.withOpacity(.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 28, color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$count items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
