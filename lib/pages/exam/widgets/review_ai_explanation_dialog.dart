// lib/widgets/review_ai_explanation_dialog.dart
import 'package:flutter/material.dart';

class ReviewAiExplanationDialog extends StatelessWidget {
  final Future<String> explanationFuture;
  final Future<String?>?
      correctAnswerFuture; // 🔹 yeni: doğru cevap (isteğe bağlı)
  final String? title;

  const ReviewAiExplanationDialog({
    super.key,
    required this.explanationFuture,
    this.correctAnswerFuture,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520, // tablet/desktop’ta fazla büyümesin
          maxHeight: 480, // içerik taşarsa scroll
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'AI Explanation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(height: 1),
              const SizedBox(height: 8),
// 🔹 Correct Answer (varsa)
              if (correctAnswerFuture != null)
                FutureBuilder<String?>(
                  future: correctAnswerFuture,
                  builder: (context, snap) {
                    final txt = (snap.data ?? '').toString().trim();
                    if (txt.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct Answer',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(txt, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),

              Expanded(
                child: FutureBuilder<String>(
                  future: explanationFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: cs.primary),
                      );
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Failed to load explanation. Please try again.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.error,
                          ),
                        ),
                      );
                    }
                    final text = (snap.data ?? '').trim();
                    if (text.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No explanation available for this question.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.outline,
                          ),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        text,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
