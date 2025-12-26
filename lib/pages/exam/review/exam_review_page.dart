// lib/pages/exam/exam_review_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/exam/review/widgets/review_action_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../models/exam.dart';
import '../../../models/question.dart';

import '../controllers/exam_review_controller.dart';

import '../question_widgets/review_mcq_view.dart';
import '../question_widgets/review_short_answer_view.dart';
import '../question_widgets/review_fill_blank_view.dart';
import '../question_widgets/review_coding_view.dart';
import '../question_widgets/review_coding_editor_page.dart';

import 'widgets/review_stats_row.dart';
import 'widgets/review_navigator_sheet.dart';

import '../review/widgets/review_question_header.dart';
import '../result/exam_result_page.dart';

class ExamReviewPage extends StatelessWidget {
  const ExamReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    // ---------------------------------------------------
    // SAFETY: Exam yoksa fallback
    // ---------------------------------------------------
    if (args is! Exam) {
      return const _NoExamProvided();
    }

    final exam = args;
    final c = Get.put(ExamReviewController(exam), tag: exam.id);

    return Obx(() {
      final q = c.currentQuestion;

      return Scaffold(
        backgroundColor: AppColors.background,

        // ===================================================
        // APP BAR
        // ===================================================
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          centerTitle: true,
          title: Text(
            'Exam Review',
            style: AppTextStyles.headline,
          ),
          leading: IconButton(
            tooltip: 'Back to Results',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.off(() => const ExamResultPage()),
          ),
          actions: [
            IconButton(
              tooltip: 'Question Navigator',
              icon: PhosphorIcon(
                PhosphorIcons.squaresFour(PhosphorIconsStyle.fill),
                size: AppIconSizes.lg,
                color: AppColors.textPrimary,
              ),
              onPressed: () => _openNavigator(context, exam.id),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),

        // ===================================================
        // BODY
        // ===================================================
        body: Column(
          children: [
            // -----------------------------------------------
            // TOP STATS (Correct / Wrong / Unanswered)
            // -----------------------------------------------
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, // 👈 exam ile aynı
              ),
              child: ReviewStatsRow(
                correct: c.correctCount,
                wrong: c.wrongCount,
                unanswered: c.unansweredCount,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // -----------------------------------------------
            // QUESTION CONTENT (NO CARD / NO BORDER)
            // -----------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------
                    // QUESTION HEADER (index / total)
                    // ---------------------------------------
                    ReviewQuestionHeader(
                      current: c.currentIndex.value + 1,
                      total: exam.questions.length,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ---------------------------------------
                    // QUESTION DESCRIPTION
                    // ---------------------------------------
                    // if ((q.description ?? '').isNotEmpty)
                    //   Text(
                    //     q.description!,
                    //     style: AppTextStyles.body.copyWith(
                    //       color: AppColors.textPrimary,
                    //     ),
                    //   ),


                    // ---------------------------------------
                    // QUESTION TYPE VIEW
                    // ---------------------------------------
                    _buildQuestionContent(c, q, exam.id),
                  ],
                ),
              ),
            ),

            // -----------------------------------------------
            // BOTTOM ACTION BAR
            // -----------------------------------------------
            ReviewActionBar(
              onPrev: c.prev,
              onNext: c.next,
              onNavigator: () => _openNavigator(context, exam.id),
              examId: exam.id,
            ),
          ],
        ),
      );
    });
  }

  // ===================================================
  // QUESTION TYPE SWITCH
  // ===================================================
  Widget _buildQuestionContent(
    ExamReviewController c,
    Question q,
    String examId,
  ) {
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

  // ===================================================
  // NAVIGATOR SHEET
  // ===================================================
  void _openNavigator(BuildContext context, String examId) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Navigator',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => ReviewNavigatorSheet(examId: examId),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

// ===================================================
// FALLBACK – NO EXAM PROVIDED
// ===================================================
class _NoExamProvided extends StatelessWidget {
  const _NoExamProvided();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Exam Review',
          style: AppTextStyles.headline,
        ),
      ),
      body: const Center(
        child: Text('No exam data provided.'),
      ),
    );
  }
}
