// lib/widgets/question_card.dart

import 'package:flutter/material.dart';
import '../models/question.dart';

/// Soru kartı widget'ı.
/// - Kartın tamamına basınca [onTap] tetiklenir.
/// - Sağ üst köşedeki kaydetme ikonuna basınca [onSaveTap] tetiklenir.
/// - [isSaved] true olduğunda ikon dolu görünür.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
    this.onSaveTap,
    this.isSaved = false,
  });

  final Question question;
  final VoidCallback? onTap;
  final VoidCallback? onSaveTap;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Stack(
      children: [
        // --- Ana Kart ---
        Material(
          color: Theme.of(context).cardColor,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _CardBody(question: question),
            ),
          ),
        ),

        // --- Sağ üst köşe ikon ---
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: onSaveTap,
            tooltip: isSaved ? 'Saved' : 'Save',
            splashRadius: 18,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartın içerik kısmı.
/// Başlık, zorluk etiketi, kategori vs. burada çiziliyor.
class _CardBody extends StatelessWidget {
  const _CardBody({required this.question});
  final Question question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Text(
          question.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Zorluk etiketi
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _difficultyColor(question.difficulty, context)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.difficulty.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _difficultyColor(question.difficulty, context),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Dil / kategori
            Text(
              question.topic,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Color _difficultyColor(Difficulty difficulty, BuildContext context) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.easy_medium:
        return Colors.lightGreen;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.medium_hard:
        return Colors.deepOrange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}
