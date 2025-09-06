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
import 'package:interview_project/pages/exam/widgets/mcq_view.dart';


import '../../constants/colors.dart';
import '../../models/question.dart';

// lib/pages/exam/exam_page.dart
class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    // Argüman gelmediyse: uyarı + “Mock Exam ile başlat” butonu
    if (args is! Exam) {
      return const _NoExamProvided();
    }

    final exam = args as Exam;
    final c = Get.put(ExamController(exam), tag: exam.id);

    return Obx(() {
      final st = c.state.value;
      final q  = c.currentQuestion;
      return Scaffold(
        appBar: AppBar(
          title: Text(exam.title),
          actions: [
            // Sayaç önce (solda), Navigator en sağda
            Padding(
              //PROGRESS BAR
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: TimerBadge(secondsLeft: st.secondsLeft)),
            ),
            IconButton(
              tooltip: 'Navigator',
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: () {
                // TODO: question navigator sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigator coming soon')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar zaten var
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProgressBar(total: exam.questions.length, answered: st.answers.length, current: c.currentNumber),
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
                    // ⬇️ TEK BÜYÜK KART: border yok, soft mavi back
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: 0.35), // 💡 çok açık mavi
                        borderRadius: BorderRadius.circular(16),
                        // border: yok
                        boxShadow: [
                          // çok hafif derinlik
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
                          QuestionHeader(current: c.currentNumber, total: c.total),
                          const SizedBox(height: 12),
                          McqView(
                            question: q,
                            onAnswer: c.answerCurrent,
                            onToggleFlag: c.toggleFlag,
                            embedded: true, // dış kapsayıcı bizde, içte ekstra border yok
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
                final demo = _mockExam(); // geçici demo
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

// küçük bir mock (geçici)
Exam _mockExam() {
  return Exam(
    id: 'demo1',
    title: 'Demo Exam',
    duration: const Duration(minutes: 30),
    questions: [
    Question(
    id: 'q1',
    title: 'What is the time complexity of accessing an element in a HashMap?',
    difficulty: Difficulty.easy,
    status: Status.todo,
    type: QuestionType.mcq,
    topic: 'Data Structures',
    options: [
      'O(1) - Constant time',
      'O(log n) - Logarithmic time',
      'O(n) - Linear time',
      'O(n log n)',
    ], description: '', tags: [],
  ),
      Question(
        id: 'q2',
        title: 'Which of the following sorting algorithms has the best average-case time complexity?',
        difficulty: Difficulty.medium,
        status: Status.todo,
        type: QuestionType.mcq,
        topic: 'Algorithms',
        options: [
          'Bubble Sort',
          'Quick Sort',
          'Selection Sort',
          'Insertion Sort',
        ],
        description: '',
        tags: [],
      ),

      Question(
        id: 'q3',
        title: 'In an Operating System, what does a context switch involve?',
        difficulty: Difficulty.medium,
        status: Status.todo,
        type: QuestionType.mcq,
        topic: 'Operating Systems',
        options: [
          'Switching between kernel mode and user mode',
          'Saving the state of a process and loading another',
          'Terminating a process',
          'Changing the scheduling algorithm',
        ],
        description: '',
        tags: [],
      ),

      Question(
        id: 'q4',
        title: 'Which layer of the OSI model is responsible for logical addressing (IP addresses)?',
        difficulty: Difficulty.easy,
        status: Status.todo,
        type: QuestionType.mcq,
        topic: 'Computer Networks',
        options: [
          'Data Link Layer',
          'Transport Layer',
          'Network Layer',
          'Application Layer',
        ],
        description: '',
        tags: [],
      ),


    ],
    createdAt: DateTime.now(),
  );
}

