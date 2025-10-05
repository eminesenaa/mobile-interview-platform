// lib/pages/exam/widgets/review_action_bar.dart
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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: onPrev,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Previous'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                label: const Text('Next'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Alt: Submit (renkli ve ortalı)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text('Save to Library'),
            ),
          ),
        ],
      ),
    );

  }
}
