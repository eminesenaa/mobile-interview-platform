import 'package:flutter/material.dart';
import 'package:interview_project/services/ai/ai_service.dart';
import 'package:interview_project/models/exam.dart';

class ExamResultPage extends StatelessWidget {
  final ExamEvaluateResult result;
  final Exam exam;
  const ExamResultPage({super.key, required this.result, required this.exam});

  @override
  Widget build(BuildContext context) {
    final pct = (result.correctCount / result.total * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${result.correctCount}/${result.total} correct ($pct%)',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...result.items.map((it) {
            final q = exam.questions.firstWhere((x) => x.id == it.questionId);
            return Card(
              child: ListTile(
                title: Text(q.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(it.correct ? 'True' : 'False',
                        style: TextStyle(
                          color: it.correct ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        )),
                    if (it.expected.isNotEmpty)
                      Text('Expected: ${it.expected}'),
                    if (it.explanation.isNotEmpty)
                      Text('Explanation: ${it.explanation}'),
                    if (it.score != null)
                      Text('Score: ${it.score!.toStringAsFixed(1)} / 5'),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
