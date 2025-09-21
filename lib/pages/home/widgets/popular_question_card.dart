import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/question.dart';


class PopularQuestionCard extends StatelessWidget {
  final Question question;
  final double? width;
  final EdgeInsets padding;

  /// Dikey listelerde varsayılan kullanım
  const PopularQuestionCard({
    super.key,
    required this.question,
    this.width,
    this.padding = const EdgeInsets.all(14),
  });

  /// Yatay (horizontal) listeye uygun kısa yol
  const PopularQuestionCard.horizontal({
    super.key,
    required this.question,
    required double this.width,
  }) : padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 16);

  //void _openQuestion() => QuestionNavigator.open(question);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0.6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          //onTap: _openQuestion, // tüm karta tıklama
          child: Padding(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol renk şeridi KALDIRILDI

                // içerik
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        question.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Chip(
                            icon: Icons.category,
                            label: question.topic ?? '—',
                          ),
                          _DifficultyChip(difficulty: question.difficulty),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Zorluk etiketini soft renkle verir
class _DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;
  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final base = _difficultyColor(difficulty);
    final bg = base.withOpacity(.12);
    final fg = base.withOpacity(.90);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.leaderboard, size: 14),
        const SizedBox(width: 4),
        Text(
          _difficultyLabel(difficulty),
          style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }

  static Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.easy_medium:
        return Colors.teal;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.medium_hard:
        return Colors.deepOrange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  static String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.easy_medium:
        return 'Easy‑Med';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.medium_hard:
        return 'Med‑Hard';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
