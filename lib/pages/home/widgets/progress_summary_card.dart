import 'package:flutter/material.dart';

class ProgressSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;     // örn: "Accuracy"
  final String value;     // örn: "75%"
  final String? caption;  // örn: "of 120 Qs"
  final VoidCallback? onTap;

  const ProgressSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 180,
      child: Card(
        elevation: 0.6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(icon, color: cs.primary, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600)),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(caption!,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Theme.of(context).hintColor)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
