import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:interview_project/constants/constants.dart';

import 'package:interview_project/pages/practice/controllers/practice_controller.dart';
import 'package:interview_project/pages/practice/training_module_detail_page.dart';
import 'package:interview_project/pages/practice/widgets/training_module_card.dart';
import 'package:interview_project/pages/practice/widgets/topic_chip_scroll.dart';
import 'package:interview_project/pages/practice/widgets/search_add_bar.dart';
import 'package:interview_project/pages/practice/widgets/filter_popup.dart';

import 'package:interview_project/widgets/question_card.dart';
import 'package:interview_project/pages/library/widgets/save_question_to_collection_sheet.dart';
import 'package:interview_project/pages/library/services/library_service.dart';

import '../../models/question.dart';
import '../runner/question_feed.dart';
import '../runner/question_runner_page.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PracticeController());
    final lib = LibraryService.instance;

    final bottomInset = MediaQuery.of(context).padding.bottom + 12;
    final trainingPageController = PageController(viewportFraction: 0.9);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Practice',
          style: AppTextStyles.headline,
        ),
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
                  final modules = controller.trainingModules.toList();

                  if (modules.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                    ),
                    child: SizedBox(
                      height: 170,
                      child: PageView.builder(
                        controller: trainingPageController,
                        padEnds: false,
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          final module = modules[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.sm,
                            ),
                            child: TrainingModuleCard(
                              module: module,
                              progress:
                                  controller.moduleProgressById[module.id] ??
                                      0.0,
                              onTap: () {
                                final sections =
                                    controller.sectionsByModule[module.id] ??
                                        [];
                                final refs =
                                    controller.refsByModule[module.id] ?? [];

                                Get.to(
                                  () => TrainingModuleDetailPage(
                                    module: module,
                                    sections: sections,
                                    questionRefs: refs,
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

              // (2) FILTER BAR
              SliverPinnedHeader(
                child: Material(
                  elevation: 3,
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
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
                          onSearchChanged: controller.updateSearch,
                          onFilterPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => FilterPopup(
                                topics: controller.allTopics
                                    .where((t) => t != 'All')
                                    .toList(),
                                difficulties: Difficulty.values,
                                statuses: Status.values,
                                questionTypes: QuestionType.values,
                                selectedTopics:
                                    controller.selectedTopicsMulti.toList(),
                                selectedDifficulties: controller
                                    .selectedDifficultiesMulti
                                    .toList(),
                                selectedQuestionTypes: controller
                                    .selectedQuestionTypesMulti
                                    .toList(),
                                selectedStatus: controller.selectedStatus.value,
                                onApply: ({
                                  required List<String> topics,
                                  required List<Difficulty> difficulties,
                                  required List<QuestionType> questionTypes,
                                  required Status? status,
                                }) {
                                  controller.updateFiltersMulti(
                                    topics: topics,
                                    difficulties: difficulties,
                                    questionTypes: questionTypes,
                                    status: status,
                                  );
                                },
                              ),
                            );
                          },
                          onRandomPressed: () {
                            final random = controller.getRandomQuestion();
                            if (random == null) return;

                            final idx = questions.indexWhere(
                              (q) =>
                                  _extractQuestionId(q) ==
                                  _extractQuestionId(random),
                            );
                            if (idx >= 0) {
                              _openRunner(questions, idx);
                            }
                          },
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
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    bottomInset,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) {
                          return const SizedBox(height: 10);
                        }

                        final itemIndex = index ~/ 2;
                        final q = questions[itemIndex];
                        final qId = _extractQuestionId(q);

                        return StreamBuilder<bool>(
                          stream: lib.isSavedStream(qId),
                          builder: (context, snapshot) {
                            final isSaved = snapshot.data ?? false;
                            return QuestionCard(
                              question: q,
                              onTap: () => _openRunner(questions, itemIndex),
                              isSaved: isSaved,
                              onSaveTap: () async {
                                final result = await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => SaveQuestionToCollectionSheet(
                                    questionId: qId,
                                  ),
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
    final isAll = selected == 'All';

    final feed = QuestionFeed(
      questionIds: questions.map(_extractQuestionId).toList(),
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
