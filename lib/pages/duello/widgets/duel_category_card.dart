import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../utils/duel_category_style.dart';

/// ===============================================================
/// DuelCategoryCard
/// ---------------------------------------------------------------
/// Config modal'daki kategori kartının reusable versiyonu.
///
/// - Her kategori kendi rengine sahiptir.
/// - Selected durumuna göre arka plan ve icon rengi değişir.
/// - Matchmaking ve diğer sayfalarda aynı görsel kullanılabilir.
/// ===============================================================
class DuelCategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;
  final double size;
  final VoidCallback? onTap;

  const DuelCategoryCard({
    super.key,
    required this.title,
    required this.color,
    required this.isSelected,
    this.size = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? color : color.withOpacity(0.18);

    final iconColor = isSelected ? Colors.white : color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: Icon(
          DuelCategoryStyle.getIcon(title),
          size: size * 0.33, // responsive icon
          color: iconColor,
        ),
      ),
    );
  }
}
