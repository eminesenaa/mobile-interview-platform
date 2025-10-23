// lib/pages/exam/exam_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/pages/exam/controllers/exam_controller.dart';
import 'package:interview_project/pages/exam/question_widgets/exam_coding_editor_page.dart';
import 'package:interview_project/pages/exam/question_widgets/exam_coding_view.dart';
import 'package:interview_project/pages/exam/question_widgets/exam_fill_blank_view.dart';
import 'package:interview_project/pages/exam/question_widgets/exam_short_answer_view.dart';
import 'package:interview_project/pages/exam/result_loading_page.dart';
import 'package:interview_project/pages/exam/widgets/action_bar.dart';
import 'package:interview_project/pages/exam/widgets/confirm_finish_dialog.dart';
import 'package:interview_project/pages/exam/widgets/exam_navigator_sheet.dart';
import 'package:interview_project/pages/exam/widgets/progress_bar.dart';
import 'package:interview_project/pages/exam/widgets/timer_badge.dart';
import 'package:interview_project/pages/exam/question_widgets/exam_mcq_view.dart';
import 'package:interview_project/pages/exam/widgets/stats_row.dart';
import 'package:interview_project/pages/exam/widgets/question_header.dart';

import '../../constants/colors.dart';
import '../../models/question.dart';
import 'controllers/exam_coding_controller.dart';

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
                showGeneralDialog(
                  context: context,
                  barrierLabel: "Navigator",
                  barrierDismissible: true,
                  barrierColor: Colors.black54,
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) =>
                      ExamNavigatorSheet(examId: c.exam.id),
                  transitionBuilder: (_, anim, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
                      child: child,
                    );
                  },
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
                          // Header alanı (Coding için sağda code icon)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              QuestionHeader(
                                current: c.currentNumber,
                                total: c.total,
                              ),
                              if (q.type == QuestionType.coding)
                                IconButton(
                                  tooltip: "Open Code Editor",
                                  icon: const Icon(Icons.code_rounded),
                                  color: primaryColor,
                                  onPressed: () {
                                    final codingCtrl = Get.put(
                                      ExamCodingController(),
                                      tag: q.id,
                                      permanent: false,
                                    );
                                    codingCtrl.isEditorOpen.value = true;
                                    Get.to(
                                      () => ExamCodingEditorPage(question: q),
                                      arguments: {
                                        'examId': c.exam.id,
                                        // ExamPage’deki controller’dan alıyoruz
                                        'questionId': q.id,
                                      },
                                    )!
                                        .then((_) {
                                      codingCtrl.isEditorOpen.value = false;
                                    });
                                  },
                                ),
                            ],
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
                          _buildQuestionContent(c, q, exam.id),
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
              // ✅ Submit → (pause timer) → Confirm → Yes: Loading, No: resume
              onSubmit: () async {
                c.pauseTimer(); // ⏸️ diyalog açıkken süre dursun
                final ok = await ConfirmFinishDialog.show();
                if (ok) {
                  // Loading screen: controller.submit(...) bu sayfa içinde çalışacak
                  Get.to(() => ResultLoadingPage(
                        controllerTag: c.exam.id,
                        autoSubmit: true,
                      ));
                } else {
                  // Kullanıcı vazgeçti → süre kaldığı yerden devam etsin
                  c.resumeTimer(); // ▶️
                }
                // ok == false → dialog kapanır, ExamPage’de kalınır (timer akmaya devam)
              },

              onNavigator: () {
                showGeneralDialog(
                  context: context,
                  barrierLabel: "Navigator",
                  barrierDismissible: true,
                  barrierColor: Colors.black54,
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) =>
                      ExamNavigatorSheet(examId: c.exam.id),
                  transitionBuilder: (_, anim, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                            parent: anim, curve: Curves.easeOutCubic),
                      ),
                      child: child,
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuestionContent(ExamController c, Question q, String examId) {
    switch (q.type) {
      case QuestionType.mcq:
        return ExamMcqView(
          question: q,
          onAnswer: c.answerCurrent,
          onToggleFlag: () => c.toggleFlag(q.id),
          embedded: true,
          examId: examId,
        );
      case QuestionType.fillBlank:
        return ExamFillBlankView(
          key: ValueKey('fill-${q.id}'),
          question: q,
          examId: examId,
          onAnswerChanged: (answers) {
            // int key -> string key normalizasyonu
            final normalized = {
              for (final e in answers.entries) e.key.toString(): e.value,
            };
            c.saveAnswer(q.id, normalized);
          },
        );
      case QuestionType.shortAnswer:
        return ExamShortAnswerView(
          question: q,
          onAnswerChanged: (answer) {
            c.saveAnswer(q.id, answer);
          },
          examId: examId,
        );
      case QuestionType.coding:
        return ExamCodingView(
          question: q,
          onAnswerChanged: (code) => c.saveAnswer(q.id, code),
          onToggleFlag: () => c.toggleFlag(q.id),
          examId: examId,
        );
      default:
        return const SizedBox.shrink();
    }
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
        description:
            'What is the time complexity of accessing an element in a HashMap?',
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
