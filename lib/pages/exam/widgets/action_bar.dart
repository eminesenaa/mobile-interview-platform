import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class ActionBar extends StatelessWidget {
  final VoidCallback onPrev, onNext, onSubmit, onNavigator; // onNavigator artık AppBar'da ama imza kalsın
  const ActionBar({super.key, required this.onPrev, required this.onNext, required this.onSubmit, required this.onNavigator});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst satır: Prev (sol) - Next (sağ), text-button görünümü
            Row(
              children: [
                TextButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  label: const Text('Previous'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  label: const Text('Next'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Alt: Submit (renkli ve ortalı)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
