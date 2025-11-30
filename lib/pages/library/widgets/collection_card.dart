import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class CollectionCard extends StatelessWidget {
  final String name;
  final int count;

  final bool isSelected;
  final bool selectionMode;
  final VoidCallback? onSelect;
  final VoidCallback onTap;

  final IconData icon;
  final EdgeInsetsGeometry padding;

  const CollectionCard({
    super.key,
    required this.name,
    required this.count,
    this.isSelected = false,
    this.selectionMode = false,
    this.onSelect,
    required this.onTap,
    this.icon = Icons.collections_bookmark_outlined,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bool showBorder = selectionMode;
    final Color borderColor = isSelected ? AppColors.primary : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showBorder ? borderColor : AppColors.border,
          width: showBorder ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: selectionMode ? onSelect : onTap,
          child: Padding(
            padding: padding,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // CONTENT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoftBackground,
                            // ⭐ pastel mavi
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // NAME
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    // COUNT
                    Text(
                      "$count items",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),

                // ✓ SELECTION ICON
                if (selectionMode)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
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
