import 'package:flutter/material.dart';
import '../../../models/question.dart';

class TodaysQuestionCard extends StatelessWidget {
  /// Gösterilecek soru (title/description’dan metin alınır).
  final Question? question;

  /// "Solve" tıklandığında çağrılacak callback (opsiyonel).
  final VoidCallback? onSolve;

  /// Dıştan ek boşluk vermek istersen.
  final EdgeInsetsGeometry? margin;

  const TodaysQuestionCard({
    super.key,
    required this.question,
    this.onSolve,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    // Kart metni: description varsa onu, yoksa title'ı kullan
    final text = (question?.description?.isNotEmpty ?? false)
        ? question!.description!
        : (question?.title ?? 'No “Today’s Question”.');

    final isSolveEnabled = onSolve != null && question != null;

    return Center(
      child: Container(
        margin: margin,
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soru metni
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // "Solve" linki (opsiyonel aktif)
            GestureDetector(
              onTap: isSolveEnabled ? onSolve : null,
              child: Text(
                'Solve',
                style: TextStyle(
                  color: isSolveEnabled
                      ? Colors.blue.shade700
                      : Colors.blueGrey, // pasif görünüm
                  fontWeight: FontWeight.w600,
                  decoration:
                  isSolveEnabled ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
