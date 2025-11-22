import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/exam/question_widgets/review_coding_editor_page.dart';
import 'package:interview_project/pages/exam/widgets/question_header.dart';
import 'controllers/exam_review_controller.dart';
import 'question_widgets/review_mcq_view.dart';
import 'question_widgets/review_short_answer_view.dart';
import 'question_widgets/review_fill_blank_view.dart';
import 'question_widgets/review_coding_view.dart';
import 'widgets/review_action_bar.dart';
import 'widgets/review_stats_row.dart';
import 'widgets/review_navigator_sheet.dart';
import 'exam_result_page.dart';

class ExamReviewPage extends StatelessWidget {
  const ExamReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args is! Exam) {
      return const _NoExamProvided();
    }

    final exam = args as Exam;
    final c = Get.put(ExamReviewController(exam), tag: exam.id);

    return Obx(() {
      final q = c.currentQuestion;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('${exam.title} Review'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.off(() => const ExamResultPage()),
          ),
          actions: [
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
                      ReviewNavigatorSheet(examId: exam.id),
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
            // ✅ Progress yerine statik sonuç barı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ReviewStatsRow(
                correct: c.correctCount,
                wrong: c.wrongCount,
                unanswered: c.unansweredCount,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.35),
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
                          // Header alanı (Coding için artık sağda icon YOK)
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
                                  tooltip: "Open Code Editor (Read-only)",
                                  icon: const Icon(Icons.code_rounded),
                                  color: AppColors.primary,
                                  onPressed: () {
                                    Get.to(
                                      () => ReviewCodingEditorPage(
                                        question: q,
                                        examId: c.exam.id,
                                      ),
                                      arguments: {
                                        'questionId': q.id,
                                      },
                                    );
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
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ReviewActionBar(
              onPrev: c.prev,
              onNext: c.next,
              onNavigator: () {
                showGeneralDialog(
                  context: context,
                  barrierLabel: "Navigator",
                  barrierDismissible: true,
                  barrierColor: Colors.black54,
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) =>
                      ReviewNavigatorSheet(examId: exam.id),
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
              examId: exam.id,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuestionHeader(ExamReviewController c, Question q) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Question ${c.currentNumber} of ${c.total}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildQuestionContent(
      ExamReviewController c, Question q, String examId) {
    switch (q.type) {
      case QuestionType.mcq:
        return ReviewMcqView(question: q, examId: examId);
      case QuestionType.shortAnswer:
        return ReviewShortAnswerView(question: q, examId: examId);
      case QuestionType.fillBlank:
        return ReviewFillBlankView(question: q, examId: examId);
      case QuestionType.coding:
        return ReviewCodingView(question: q, examId: examId);
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
      appBar: AppBar(title: const Text('Exam Review')),
      body: const Center(child: Text('No exam data provided.')),
    );
  }
}
