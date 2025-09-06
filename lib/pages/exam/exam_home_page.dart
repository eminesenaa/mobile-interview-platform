import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/exam/exam_page.dart';
import 'package:interview_project/pages/exam/create_exam_sheet.dart';

// services
import 'package:interview_project/pages/exam/services/ai_duration_service.dart';
import 'package:interview_project/pages/exam/services/exam_factory.dart';

/// EXAM HOME
/// ---------
/// Exam sekmesine girince açılan basit landing ekranı.
/// Solda "Random Exam", sağda "Create Your Exam".
/// Random: soru havuzundan (şimdilik demo) sınav oluşturup ExamPage'e gider.
/// Create: filtre sayfasına götürür; oradan oluşturulan sınav ExamPage'de açılır.
class ExamHomePage extends StatelessWidget {
  const ExamHomePage({super.key});

  // Geçici soru havuzu (Firebase bağlayınca burayı değiştireceğiz)
  Future<List<Question>> _getPool() async {
    return [
      Question(
        id: 'q1',
        title: 'What is the time complexity of accessing an element in a HashMap?',
        difficulty: Difficulty.medium,
        type: QuestionType.mcq,
        topic: 'Data Structures',
        tags: ['hashmap', 'complexity'],
        options: [
          'O(1) - Constant time',
          'O(log n) - Logarithmic time',
          'O(n) - Linear time',
          'O(n log n)',
        ], description: '', status: Status.todo,
      ),
      Question(
        id: 'q2',
        title: 'Which sorting has the best average-case time complexity?',
        difficulty: Difficulty.easy,
        type: QuestionType.mcq,
        topic: 'Algorithms',
        tags: ['sorting'],
        options: ['Bubble Sort', 'Quick Sort', 'Selection Sort', 'Insertion Sort'], description: '', status: Status.todo,
      ),
      Question(
        id: 'q3',
        title: 'Pick the correct Big-O for binary search.',
        difficulty: Difficulty.easy_medium,
        type: QuestionType.mcq,
        topic: 'Algorithms',
        tags: ['binary-search'],
        options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'], description: '', status: Status.todo,
      ),
      Question(
        id: 'q4',
        title: 'Which DS is best for LRU cache?',
        difficulty: Difficulty.medium,
        type: QuestionType.mcq,
        topic: 'Data Structures',
        tags: ['cache', 'lru'],
        options: ['Stack + Array', 'DLL + HashMap', 'Queue only', 'BST only'], description: '', status: Status.todo,
      ),
    ];
  }

  ExamFactory _factory() =>
      ExamFactoryStub(AiDurationServiceStub(), getPool: _getPool);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Exam')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: IntrinsicHeight( // dikey çizgi tam ortada uzasın
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LEFT: Random Exam
                _TapArea(
                  title: 'RANDOM EXAM',
                  onTap: () async {
                    final exam = await _factory().fromRandom(count: 10);
                    Get.to(() => const ExamPage(), arguments: exam);
                  },
                ),
                // middle divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 220,
                  color: Theme.of(context).dividerColor.withValues(alpha: .4),
                ),
                // RIGHT: Create Your Exam
                _TapArea(
                  title: 'CREATE YOUR\nEXAM',
                  onTap: () => Get.to(() => const CreateExamSheet()),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      // arka planı hafif yumuşat (opsiyonel)
      backgroundColor: scheme.surface,
    );
  }
}

class _TapArea extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final TextAlign textAlign;
  const _TapArea({
    required this.title,
    required this.onTap,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme.titleMedium;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        child: Text(
          title,
          textAlign: textAlign,
          style: ts?.copyWith(letterSpacing: 0.5),
        ),
      ),
    );
  }
}
