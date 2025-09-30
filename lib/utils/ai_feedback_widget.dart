import 'package:flutter/material.dart';

/// Ortak AI Feedback widget'i
/// - Tüm soru tiplerinde aynı UI ile kullanılacak.
/// - Doğruluk, skor, açıklama ve kazanılan XP bilgisi gösterilir.
class AiFeedbackWidget extends StatelessWidget {
  final bool correct;
  final double? score; // 0–5 arası
  final String explanation;
  final int earnedXp;

  const AiFeedbackWidget({
    super.key,
    required this.correct,
    required this.explanation,
    required this.earnedXp,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final Color verdictColor = correct ? Colors.green.shade700 : Colors.red.shade700;
    final String verdictText = correct ? "Correct" : "Incorrect";
    final IconData verdictIcon = correct ? Icons.check_circle : Icons.cancel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Text(
          "AI Feedback:",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Doğru / Yanlış Satırı
        Row(
          children: [
            Icon(verdictIcon, color: verdictColor, size: 20),
            const SizedBox(width: 6),
            Text(
              verdictText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: verdictColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Açıklama
        if (explanation.isNotEmpty)
          Text(
            explanation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        if (explanation.isNotEmpty) const SizedBox(height: 12),

        // XP Satırı
        Row(
          children: [
            const Text("⭐"),
            const SizedBox(width: 4),
            Text("You earned: $earnedXp XP"),
          ],
        ),
        const SizedBox(height: 12),

        // Chip’ler (Correct / Incorrect + Score)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(verdictText),
              backgroundColor: correct ? Colors.green.shade50 : Colors.red.shade50,
              labelStyle: TextStyle(color: verdictColor),
            ),
            if (score != null)
              Chip(
                label: Text("Score: ${score!.toStringAsFixed(1)}/5"),
              ),
          ],
        ),
      ],
    );
  }
}
