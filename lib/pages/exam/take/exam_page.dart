import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/exam/take/widgets/question_progress_indicator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../models/exam.dart';
import '../../../models/question.dart';

import '../controllers/exam_controller.dart';

import '../question_widgets/exam_mcq_view.dart';
import '../question_widgets/exam_fill_blank_view.dart';
import '../question_widgets/exam_short_answer_view.dart';
import '../question_widgets/exam_coding_view.dart';

import 'widgets/action_bar.dart';
import 'widgets/confirm_finish_dialog.dart';
import 'widgets/exam_navigator_sheet.dart';
import 'widgets/question_header.dart';
import 'widgets/timer_badge.dart';

import '../result_loading_page.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args is! Exam) {
      return const _NoExamProvided();
    }

    final exam = args;
    final c = Get.put(ExamController(exam), tag: exam.id);

    return Obx(() {
      final st = c.state.value;
      final q = c.currentQuestion;

      return Scaffold(
        backgroundColor: AppColors.background,

        // ───────────────── AppBar ─────────────────
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          centerTitle: false,
          // TODO (Interview):
          // - For interview flow, exam.title will be "Interview"
          // - Later backend should provide dynamic session title
          title: Text(
            exam.title,
            style: AppTextStyles.headline,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: TimerBadge(
                secondsLeft: c.state.value.secondsLeft,
              ),
            ),
            IconButton(
              onPressed: () => _openNavigator(context, c),
              icon: PhosphorIcon(
                PhosphorIcons.squaresFour(PhosphorIconsStyle.fill),
                size: AppIconSizes.lg,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),

        // ───────────────── Body ─────────────────
        body: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  QuestionProgressIndicator(
                    total: exam.questions.length,
                    current: c.currentNumber,
                    answered: c.answeredCount,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ───────────── Question Content ─────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, // progress bar ile hizalı
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 QUESTION HEADER
                    QuestionHeader(
                      current: c.currentNumber,
                      total: c.total,
                      isFlagged: c.isFlagged(q.id),
                      onToggleFlag: () => c.toggleFlag(q.id),
                      onClear: () => c.clearAnswer(q.id),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 🔹 QUESTION VIEW (MCQ / FILL / SHORT / CODING)
                    _buildQuestionContent(c, q, exam.id),
                  ],
                ),
              ),
            ),

            // ───────────── Bottom Action Bar ─────────────
            ActionBar(
              onPrev: c.prev,
              onNext: c.next,
              onSubmit: () async {
                c.pauseTimer();
                final ok = await ConfirmFinishDialog.show();
                if (ok) {
                  Get.to(
                    () => ResultLoadingPage(
                      controllerTag: c.exam.id,
                      autoSubmit: true,
                    ),
                  );
                } else {
                  c.resumeTimer();
                }
              },
              onNavigator: () => _openNavigator(context, c),
            ),
          ],
        ),
      );
    });
  }

  void _openNavigator(BuildContext context, ExamController c) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Navigator",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => ExamNavigatorSheet(examId: c.exam.id),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildQuestionContent(
    ExamController c,
    Question q,
    String examId,
  ) {
    switch (q.type) {
      case QuestionType.mcq:
        return Obx(() => ExamMcqView(
              key: ValueKey(
                '${q.id}-${c.clearTick.value}', // 🔥 RESET ANAHTARI
              ),
              question: q,
              examId: examId,
              onAnswer: c.answerCurrent,
              onToggleFlag: () => c.toggleFlag(q.id),
            ));
      case QuestionType.fillBlank:
        return Obx(() => ExamFillBlankView(
              // 🔑 clearTick ile key-reset (olmazsa olmaz)
              key: ValueKey('fill-${q.id}-${c.clearTick.value}'),

              question: q,
              examId: examId,

              onAnswerChanged: (answers) {
                if (answers == null || answers.isEmpty) {
                  c.clearAnswer(q.id);
                } else {
                  c.saveAnswer(q.id, answers);
                }
              },
            ));
      case QuestionType.shortAnswer:
        return ExamShortAnswerView(
          key: ValueKey(
            'short-${q.id}-${c.clearTick.value}',
          ),
          question: q,
          examId: examId,
          onAnswerChanged: (answer) {
            c.saveAnswer(q.id, answer);
          },
        );
      case QuestionType.coding:
        return ExamCodingView(
          key: ValueKey(
            'coding-${q.id}-${c.clearTick.value}', // 🔑 clear sonrası reset
          ),
          question: q,
          examId: examId,
          onAnswerChanged: (code) {
            if (code == null || code.isEmpty) {
              c.clearAnswer(q.id);
            } else {
              c.saveAnswer(q.id, code);
            }
          },
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
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIcons.warningCircle(PhosphorIconsStyle.regular),
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Exam not found',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Please go back and start an exam again.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
