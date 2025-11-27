import 'package:flutter/material.dart';
import 'package:interview_project/constants/colors.dart';

class Section extends StatelessWidget {
  final String title;
  final Widget child;
  final String? note;

  const Section({
    super.key,
    required this.title,
    required this.child,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final noteStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.primary),
          ),
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(note!, style: noteStyle),
          ],
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
