// ===================== File: lib/pages/practice_page.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/practice/training_module_detail_page.dart';
import 'package:interview_project/pages/practice/widgets/training_module_card.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';

import 'package:interview_project/pages/practice/widgets/todays_question_card.dart';
import 'package:interview_project/pages/practice/controllers/practice_controller.dart';
import 'package:interview_project/pages/practice/widgets/topic_chip_scroll.dart';
import 'package:interview_project/pages/practice/widgets/search_add_bar.dart';
import 'package:interview_project/pages/practice/widgets/filter_popup.dart';

import 'package:interview_project/widgets/question_card.dart';
import 'package:interview_project/pages/library/widgets/save_question_to_collection_sheet.dart';
import 'package:interview_project/pages/library/services/library_service.dart';

import '../../models/question.dart';
import '../../models/training_module.dart';
import '../runner/question_feed.dart';
import '../runner/question_runner_page.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PracticeController());
    final lib = LibraryService.instance; // ✅ Tek referans

    final bottomInset = MediaQuery.of(context).padding.bottom + 12;
    // Training modules slider için: kartın ucu gözüksün diye viewportFraction < 1
    final trainingPageController = PageController(viewportFraction: 0.9);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Practice',
          style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final questions = controller.filteredQuestions;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // (1) TRAINING MODULES
              SliverToBoxAdapter(
                child: Obx(() {
                  final modules = controller.trainingModules;
                  // Henüz module yoksa bu alanı gizle (veya istersen placeholder koy).
                  if (modules.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: SizedBox(
                      height: 170,
                      // ⭐️ EN KRİTİK KISIM — PageView’in yüksekliğini belirledik
                      child: PageView.builder(
                        controller: trainingPageController,
                        padEnds: false,
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          final module = modules[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            child: TrainingModuleCard(
                              module: module,
                              progress: controller.moduleProgressById[module.id], // ileride user progress gelecek
                              onTap: () {
                                // TEMP: Front’u test etmek için mock section + questionRef kullan
                                final detailSections =
                                    controller.buildMockSectionsFor(module);
                                final detailRefs =
                                    controller.buildMockQuestionRefsFor(
                                        module, detailSections);

                                Get.to(
                                  () => TrainingModuleDetailPage(
                                    module: module,
                                    sections: detailSections,
                                    questionRefs: detailRefs,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),

              // (2) TODAY'S QUESTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TodaysQuestionCard(
                    question: controller.todaysQuestion,
                  ),
                ),
              ),

              // (3) FILTER BAR
              SliverPinnedHeader(
                child: Material(
                  elevation: 2,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      children: [
                        TopicChipScroll(
                          topics: controller.allTopics,
                          selectedTopic: controller.selectedTopic.value,
                          onTopicSelected: (topic) =>
                              controller.updateFilters(topic: topic),
                        ),
                        const Divider(height: 24),
                        SearchAddBar(
                          searchText: controller.searchQuery.value,
                          onSearchChanged: (val) =>
                              controller.updateSearch(val),
                          onFilterPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (_) {
                                return FilterPopup(
                                  topics: controller.allTopics,
                                  difficulties: [null, ...Difficulty.values],
                                  statuses: [null, ...Status.values],
                                  selectedTopic: controller.selectedTopic.value,
                                  selectedDifficulty:
                                      controller.selectedDifficulty.value,
                                  selectedStatus:
                                      controller.selectedStatus.value,
                                  onApply: ({
                                    required topic,
                                    required difficulty,
                                    required status,
                                  }) {
                                    controller.updateFilters(
                                      topic: topic,
                                      difficulty: difficulty,
                                      status: status,
                                    );
                                  },
                                );
                              },
                            );
                          },
                          onAddPressed: () => controller.onAddQuestion(),
                          onRandomPressed: () {
                            final random = controller.getRandomQuestion();
                            if (random != null) {
                              final idx = questions.indexWhere(
                                (qq) =>
                                    _extractQuestionId(qq) ==
                                    _extractQuestionId(random),
                              );
                              if (idx >= 0) {
                                _openRunner(questions, idx);
                              }
                            }
                          },
                          canAdd: controller.filteredQuestions.isNotEmpty,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),

              // (4) QUESTION LIST
              if (questions.isEmpty && controller.allQuestions.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (questions.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, bottomInset),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) return const SizedBox(height: 10);
                        final itemIndex = index ~/ 2;
                        final q = questions[itemIndex];
                        final qId = _extractQuestionId(q); // ✅ tutarlı id

                        return StreamBuilder<bool>(
                          stream: lib.isSavedStream(qId), // ✅ artık qId
                          builder: (context, snapshot) {
                            final isSaved = snapshot.data ?? false;
                            return QuestionCard(
                              question: q,
                              onTap: () => _openRunner(questions, itemIndex),
                              onSaveTap: () async {
                                final result = await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) =>
                                      SaveToCollectionSheet(questionId: qId),
                                );

                                if (result == true) {
                                  await lib.saveToAll(qId);
                                } else if (result == false) {
                                  await lib.removeQuestionEverywhere(qId);
                                }
                              },
                              isSaved: isSaved,
                            );
                          },
                        );
                      },
                      childCount: questions.length * 2 - 1,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _openRunner(List<Question> questions, int startIndex) {
    final controller = Get.find<PracticeController>();
    final selected = controller.selectedTopic.value;
    final isAll = selected == null || selected == 'All';

    final feed = QuestionFeed(
      questionIds: questions.map((q) => _extractQuestionId(q)).toList(),
      questions: questions,
      startIndex: startIndex,
      source: QuestionSourceContext(
        kind: isAll
            ? QuestionSourceKind.practiceAll
            : QuestionSourceKind.practiceFilter,
        label: isAll ? 'Practice • All' : 'Practice • $selected',
      ),
    );

    Get.to(() => QuestionRunnerPage(feed: feed));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No questions found.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }
}

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
