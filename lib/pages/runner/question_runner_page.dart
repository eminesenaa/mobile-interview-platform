// lib/pages/runner/question_runner_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/runner/question_feed.dart';
import 'package:interview_project/pages/runner/widgets/runner_bottom_bar.dart';
import '../../models/question.dart';
import '../question_types/widgets/coding_editor_page.dart';
import '../question_types/widgets/coding_question_view.dart';
import '../question_types/widgets/fill_blank_view.dart';
import '../question_types/widgets/mcq_question_view.dart';
import '../question_types/widgets/short_answer_view.dart';
import 'controller/question_runner_controller.dart';

class QuestionRunnerPage extends StatelessWidget {
  final QuestionFeed feed;

  QuestionRunnerPage({super.key, required this.feed});

  final _pageCtrl = PageController();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(QuestionRunnerController(), permanent: false);
    // init only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.feed.value == null) {
        c.init(feed);
        // -------------
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
          leading: BackButton(),
          title: Text(
            titleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (q?.type == QuestionType.coding)
              IconButton(
                icon: const Icon(Icons.code),
                onPressed: () {
                  Get.to(() => CodingEditorPage(question: q!));
                },
              ),
          ],
        ),
        body: PageView.builder(
          controller: _pageCtrl,
          physics: const PageScrollPhysics(),
          onPageChanged: (page) async {
            // PageView sürüklenince state’i senkronla
            c.closeEditor();
            final delta = page - c.currentIndex.value;
            if (delta == 1) {
              await c.next();
            } else if (delta == -1) {
              await c.prev();
            } else {
              // rastgele atlama olursa:
              c.currentIndex.value = page;
              await c.loadQuestionAt(page);
            }
          },
          itemCount: c.feed.value?.length ?? 0,
          itemBuilder: (_, idx) {
            if (q == null) {
              return const Center(child: CircularProgressIndicator());
            }
            // Sadece current index render etmek için:
            if (idx != c.currentIndex.value) {
              return const SizedBox.shrink();
            }
            print(
                '[Runner] id=${c.currentQuestion.value!.id} type=${c.currentQuestion.value!.type}');
            return _buildQuestionBody(context, c);
          },
        ),

        // Bottom action bar
        bottomNavigationBar: Obx(() {
          final q = c.currentQuestion.value;
          final isCoding = (q?.type == QuestionType.coding);
          final submitBlocked = (isCoding == true) && c.isEditorOpen.value;

          //final c = Get.find<QuestionRunnerController>();
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
                curve: Curves.easeOut,
              );
            },
            onSubmit: c.submit,
            // mevcut submit metodun
            onNext: () {
              c.flushCodingDraftIfAny();
              _pageCtrl.nextPage(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            },
            onFinish: () {
              c.flushCodingDraftIfAny();
              Get.back(); // listeye dön
            },
          );
        }),
      );
    });
  }

  Widget _buildQuestionBody(BuildContext context, QuestionRunnerController c) {
    final q = c.currentQuestion.value!;
    // Tip-özgü widget fabrikası: Her tip kendi presentational widget’ını döndürür.
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
            onOpenEditor: () => c.openEditor(q), // <-- buradan geçiriyoruz
          ),
        ],
      ),
    );
  }
}

// ---- Basit tip seçici; kendi enum/type alanına göre güncelle ----
class _QuestionTypeFactory extends StatelessWidget {
  final Question question;
  final bool locked;
  final void Function(dynamic payload, bool valid) onAnswerChanged;
  final VoidCallback onOpenEditor; // <-- coding için editor açma callback'i

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
          onChanged: (int? selectedIndex) {
            onAnswerChanged(selectedIndex, selectedIndex != null);
          },
        );
      case QuestionType.shortAnswer:
        return ShortAnswerView(
          question: question,
          locked: locked,
          onChanged: (String text) {
            onAnswerChanged(text, text.trim().isNotEmpty);
          },
        );
      case QuestionType.fillBlank:
        return FillBlankView(
          question: question,
          locked: locked,
          onChanged: (answers, valid) {
            // answers: List<String>, valid: tümü dolu mu?
            onAnswerChanged(answers, valid);
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
