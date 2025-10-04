import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class ReviewActionBar extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSave;
  final VoidCallback onNavigator;

  const ReviewActionBar({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onSave,
    required this.onNavigator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous
          TextButton.icon(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            label: const Text("Previous"),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
          ),

          // Save to Library
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 12,
              ),
            ),
            child: const Text(
              "Save to Library",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          // Next
          TextButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            label: const Text("Next"),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
