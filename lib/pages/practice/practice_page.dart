// ===================== File: lib/pages/practice_page.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/practice/training_module_detail_page.dart';
import 'package:interview_project/pages/practice/widgets/daily_challenge_card.dart';
import 'package:interview_project/pages/practice/widgets/training_module_card.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';

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
      // Practice sayfası da Home / Leaderboard ile aynı arkaplanı kullanıyor.
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
                  final modules = controller.trainingModules;
                  // Henüz module yoksa bu alanı gizle (veya istersen placeholder koy).
                  if (modules.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
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
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.sm,
                            ),
                            child: TrainingModuleCard(
                              module: module,
                              progress: controller.moduleProgressById[
                                  module.id], // ileride user progress gelecek
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

              // (2) DAILY CHALLENGE
              SliverToBoxAdapter(
                child: Obx(() {
                  final q =
                      controller.todaysQuestion; // şimdilik bunu kullanıyoruz
                  if (q == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: DailyChallengeCard(
                      question: q,
                      onSolveTap: () {
                        // Burada direkt runner'a götürebilirsin
                        final questions = [q];
                        _openRunner(questions, 0);
                      },
                    ),
                  );
                }),
              ),

              // (3) FILTER BAR
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
                          onSearchChanged: (val) =>
                              controller.updateSearch(val),
                          onFilterPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => FilterPopup(
                                // "All" olanı çoklu seçim listesine sokmuyoruz
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
                          // onAddPressed: () => controller.onAddQuestion(),
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
                          // canAdd: controller.filteredQuestions.isNotEmpty,
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
