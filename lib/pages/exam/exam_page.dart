// lib/pages/exam/exam_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/pages/exam/controllers/exam_controller.dart';
import 'package:interview_project/pages/exam/widgets/action_bar.dart';
import 'package:interview_project/pages/exam/widgets/progress_bar.dart';
import 'package:interview_project/pages/exam/widgets/timer_badge.dart';
import 'package:interview_project/pages/exam/widgets/mcq_view.dart';
import 'package:interview_project/pages/exam/widgets/stats_row.dart';
import 'package:interview_project/pages/exam/widgets/question_header.dart';

import '../../constants/colors.dart';
import '../../models/question.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args is! Exam) {
      return const _NoExamProvided();
    }

    final exam = args as Exam;
    final c = Get.put(ExamController(exam), tag: exam.id);

    return Obx(() {
      final st = c.state.value;
      final q = c.currentQuestion;

      return Scaffold(
        appBar: AppBar(
          title: Text(exam.title),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: TimerBadge(secondsLeft: st.secondsLeft)),
            ),
            IconButton(
              tooltip: 'Navigator',
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigator coming soon')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProgressBar(
                    total: exam.questions.length,
                    answered: st.answers.length,
                    current: c.currentNumber,
                  ),
                  StatsRow(
                    answered: c.answeredCount,
                    flagged: c.flaggedCount,
                    unanswered: c.unansweredCount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QuestionHeader(
                            current: c.currentNumber,
                            total: c.total,
                          ),
                          const SizedBox(height: 12),
                          if ((q.description ?? "").isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                q.description ?? "",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          McqView(
                            question: q,
                            onAnswer: c.answerCurrent,
                            onToggleFlag: c.toggleFlag,
                            embedded: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ActionBar(
              onPrev: c.prev,
              onNext: c.next,
              onSubmit: () => c.submit(),
              onNavigator: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigator coming soon')),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _NoExamProvided extends StatelessWidget {
  const _NoExamProvided();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No exam selected'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final demo = _mockExam();
                Get.to(() => const ExamPage(), arguments: demo);
              },
              child: const Text('Start demo exam'),
            ),
          ],
        ),
      ),
    );
  }
}

Exam _mockExam() {
  return Exam(
    id: 'demo1',
    title: 'Demo Exam',
    duration: const Duration(minutes: 30),
    questions: [
      Question(
        id: 'q1',
        title: 'HashMap Access',
        description: 'What is the time complexity of accessing an element in a HashMap?',
        difficulty: Difficulty.easy,
        status: Status.todo,
        type: QuestionType.mcq,
        topic: 'Data Structures',
        options: [
          'O(1)',
          'O(log n)',
          'O(n)',
          'O(n log n)',
        ],
        tags: [],
      ),
    ],
    createdAt: DateTime.now(),
  );
}
