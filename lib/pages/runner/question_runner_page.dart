// ===================== File: lib/pages/runner/question_runner_page.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import '../../models/question.dart';
import 'controller/question_runner_controller.dart';
import '../question_types/widgets/mcq_question_view.dart';
import '../question_types/widgets/fill_blank_view.dart';
import '../question_types/widgets/short_answer_view.dart';
import '../question_types/widgets/coding_question_view.dart';
import '../question_types/widgets/coding_editor_page.dart';
import 'package:interview_project/pages/runner/widgets/runner_bottom_bar.dart';
import 'package:interview_project/pages/library/services/library_service.dart';
import 'package:interview_project/pages/library/widgets/save_question_to_collection_sheet.dart';
import 'package:interview_project/pages/runner/question_feed.dart';

class QuestionRunnerPage extends StatelessWidget {
  final QuestionFeed feed;

  QuestionRunnerPage({super.key, required this.feed});

  final _pageCtrl = PageController();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(QuestionRunnerController(), permanent: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.feed.value == null) {
        c.init(feed);
        _pageCtrl.jumpToPage(feed.startIndex);
      }
    });

    return Obx(() {
      final q = c.currentQuestion.value;
      final titleText = (q?.title?.trim().isNotEmpty ?? false)
          ? q!.title!.trim()
          : (q?.description?.trim().split('\n').first ?? 'Question');

      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          backgroundColor: AppColors.primary,
          title: Text(
            titleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            if (q != null && q.type == QuestionType.coding) ...[
              IconButton(
                icon: const Icon(Icons.code, color: Colors.white),
                tooltip: "Open Editor",
                onPressed: () async {
                  final rc = Get.find<QuestionRunnerController>();
                  rc.openEditor(q);
                  await Get.to(() => CodingEditorPage(question: q));
                  rc.closeEditor();
                },
              ),
              _RunnerSaveButton(question: q),
            ] else if (q != null) ...[
              _RunnerSaveButton(question: q),
            ],
          ],
        ),

        // --- BODY ---
        body: PageView.builder(
          controller: _pageCtrl,
          physics: const PageScrollPhysics(),
          onPageChanged: (page) async {
            c.closeEditor();
            final delta = page - c.currentIndex.value;
            if (delta == 1) {
              await c.next();
            } else if (delta == -1) {
              await c.prev();
            } else {
              c.currentIndex.value = page;
              await c.loadQuestionAt(page);
            }
          },
          itemCount: c.feed.value?.length ?? 0,
          itemBuilder: (_, idx) {
            if (q == null)
              return const Center(child: CircularProgressIndicator());
            if (idx != c.currentIndex.value) return const SizedBox.shrink();
            return _buildQuestionBody(context, c);
          },
        ),

        // --- BOTTOM BAR ---
        bottomNavigationBar: Obx(() {
          final q = c.currentQuestion.value;
          final isCoding = (q?.type == QuestionType.coding);
          final submitBlocked = (isCoding == true) && c.isEditorOpen.value;
          return RunnerBottomBar(
            hasPrev: c.hasPrev,
            hasNext: c.hasNext,
            isSubmitting: c.isSubmitting.value,
            canSubmit: c.canSubmit.value,
            submitBlocked: submitBlocked,
            onPrev: () {
              c.flushCodingDraftIfAny();
              _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut);
            },
            onSubmit: c.submit,
            onNext: () {
              c.flushCodingDraftIfAny();
              _pageCtrl.nextPage(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut);
            },
            onFinish: () {
              c.flushCodingDraftIfAny();
              Get.back();
            },
          );
        }),
      );
    });
  }

  Widget _buildQuestionBody(BuildContext context, QuestionRunnerController c) {
    final q = c.currentQuestion.value!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuestionTypeFactory(
            question: q,
            locked: c.isLocked.value,
            onAnswerChanged: (payload, valid) =>
                c.onAnswerChanged(payload, valid: valid),
            onOpenEditor: () => c.openEditor(q),
          ),
        ],
      ),
    );
  }
}

// ===================== Soru Tipleri =====================
class _QuestionTypeFactory extends StatelessWidget {
  final Question question;
  final bool locked;
  final void Function(dynamic payload, bool valid) onAnswerChanged;
  final VoidCallback onOpenEditor;

  const _QuestionTypeFactory({
    required this.question,
    required this.locked,
    required this.onAnswerChanged,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.mcq:
        return McqQuestionView(
          question: question,
          locked: locked,
          onChanged: (Map<String, dynamic>? answer) {
            // {"index": i} bekliyoruz
            final int? selectedIndex = answer?['index'] as int?;
            onAnswerChanged(answer, selectedIndex != null);
          },
        );
      case QuestionType.shortAnswer:
        return ShortAnswerView(
          question: question,
          locked: locked,
          onChanged: (String text) {
            final payload = <String, dynamic>{'text': text};
            onAnswerChanged(payload, text.trim().isNotEmpty);
          },
        );
      case QuestionType.fillBlank:
        return FillBlankView(
          question: question,
          locked: locked,
          onChanged: (answers, valid) {
            final payload = <String, dynamic>{
              'answers': answers,
            };
            onAnswerChanged(payload, valid);
          },
        );
      case QuestionType.coding:
        return CodingQuestionView(
          question: question,
          locked: locked,
          onOpenEditor: onOpenEditor,
        );
      default:
        return const Text('This question type is not supported yet.');
    }
  }
}

// ===================== Bookmark Stream =====================
class _RunnerSaveButton extends StatelessWidget {
  final Question question;

  const _RunnerSaveButton({required this.question});

  @override
  Widget build(BuildContext context) {
    final lib = LibraryService.instance;
    final qId = _extractQuestionId(question);

    return StreamBuilder<bool>(
      stream: lib.isSavedStream(qId), // 🔹 Firestore'dan gerçek durum
      builder: (_, snap) {
        final isSaved = snap.data ?? false;
        return IconButton(
          tooltip: "Save to Collection",
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => SaveToCollectionSheet(questionId: qId),
            );
            if (result == true) {
              await lib.saveToAll(qId);
            } else if (result == false) {
              await lib.removeQuestionEverywhere(qId);
            }
          },
        );
      },
    );
  }
}

// 🔹 Tutarlı ID extraction
String _extractQuestionId(Question q) {
  try {
    final dynamic v = (q as dynamic).id;
    if (v != null) return v.toString();
  } catch (_) {}
  try {
    final dynamic v = (q as dynamic).docId;
    if (v != null) return v.toString();
  } catch (_) {}
  return q.title.toString();
}
