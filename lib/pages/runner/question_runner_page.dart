// lib/pages/runner/question_runner_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/runner/question_feed.dart';
import 'package:interview_project/pages/runner/widgets/runner_bottom_bar.dart';
import '../../models/question.dart';
import '../question_types/widgets/fill_blank_view.dart';
import '../question_types/widgets/mcq_question_view.dart';
import '../question_types/widgets/short_answer_view.dart';
import 'controller/question_runner_controller.dart';

// import your tip widgets & model
// import 'package:.../question_types/widgets/mcq_question_view.dart' gibi

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                  child: Text(
                    c.positionLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  )),
            ),
          ],
        ),
        body: PageView.builder(
          controller: _pageCtrl,
          physics: const PageScrollPhysics(),
          onPageChanged: (page) async {
            // PageView sürüklenince state’i senkronla
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
            return _buildQuestionBody(context, c);
          },
        ),

        // Bottom action bar
        bottomNavigationBar: Obx(() {
          final c = Get.find<QuestionRunnerController>();
          return RunnerBottomBar(
            hasPrev: c.hasPrev,
            hasNext: c.hasNext,
            isSubmitting: c.isSubmitting.value,
            canSubmit: c.canSubmit.value,
            onPrev: () {
              _pageCtrl.previousPage(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            },
            onSubmit: c.submit, // mevcut submit metodun
            onNext: () {
              _pageCtrl.nextPage(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            },
            onFinish: () {
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
            // onSubmitRequested: c.submit, // istersen child’dan da tetikleyebilirsin
          ),
          // Feedback bölgesi: c.isLocked veya AI sonucuna göre görünür
          // (mevcut tip sayfalarındaki feedback UI’nı buraya/child’a taşırsın)
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

  const _QuestionTypeFactory({
    required this.question,
    required this.locked,
    required this.onAnswerChanged,
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
      default:
        return const Text('This question type is not supported yet.');
    }
  }
}
