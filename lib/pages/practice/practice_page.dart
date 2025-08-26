// ===================== File: lib/pages/practice_page.dart =====================
// Purpose: Kullanıcının soru çözme pratiği yapacağı ana sayfa.
//          QuestionController üzerinden sorular çekilir, filtrelenir ve listelenir.
//
// Notlar:
// - GetX Obx kullanılarak reactive UI sağlanır (controller.filteredQuestions değiştikçe UI yenilenir).
// - ListView.builder ile dinamik soru kartları oluşturulur.
// - onTap: soru tipine göre ilgili sayfaya yönlendirilebilir.
// ==============================================================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';

import 'package:interview_project/pages/practice/widgets/todays_question_card.dart';

import '../../navigation/question_navigator.dart';
import '../question_types/fill_in_blank_page.dart';
import '../question_types/mcq_question_page.dart';
import '../question_types/short_answer_page.dart';
import 'controllers/practice_controller.dart';
import '../../models/question.dart';
import 'widgets/get_started_card.dart';
import '../../widgets/question_card.dart';
import 'widgets/topic_chip_scroll.dart';
import 'widgets/search_add_bar.dart';
import 'widgets/filter_popup.dart';
import '../../constants/constants.dart';

import 'package:sliver_tools/sliver_tools.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PracticeController());

    final bottomInset = MediaQuery.of(context).padding.bottom + 12;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: pastelBlue,
        elevation: 0,
        title: Text(
          'Practice',
          style: AppTextStyles.headline,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final questions = controller.filteredQuestions;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ========== (1) GET STARTED CAROUSEL ==========
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: SizedBox(
                    height: 150,
                    child: PageView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final path = 'assets/images/get_started_${index + 1}.jpg';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          child: GetStartedCard(
                            title: const [
                              'Warm-up • Quick Win',
                              'Today’s Challenge',
                              'Revise Core Topics',
                              'Mock Interview Prep',
                              'Tips & Tricks',
                            ][0],
                            imagePath: path,
                            onTap: () => Get.snackbar(
                              'Let’s go!',
                              'Scroll down and start solving 🚀',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ========== (2) TODAY'S QUESTION ==========
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TodaysQuestionCard(
                    question: controller.todaysQuestion,
                    // henüz yönlendirme bağlanmadıysa boş bırakılabilir
                    // onSolve: () => _openQuestion(controller.todaysQuestion!),
                  ),
                ),
              ),

              // ========== (3) PINNED FILTER BAR ==========
              SliverPinnedHeader(
                child: Material(
                  elevation: 2,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      children: [
                        TopicChipScroll(
                          topics: ['All', 'Data Structures', 'Algorithms'],
                          selectedTopic: controller.selectedTopic.value,
                          onTopicSelected: (topic) {
                            controller.updateFilters(topic: topic);
                          },
                        ),

                        const Divider(height: 24),

                        SearchAddBar(
                          searchText: controller.searchQuery.value,
                          onSearchChanged: (val) => controller.updateSearch(val),
                          onFilterPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) {
                                return FilterPopup(
                                  topics: ['All', 'Data Structures', 'Algorithms'],
                                  difficulties: [null, ...Difficulty.values],
                                  statuses: [null, ...Status.values],
                                  selectedTopic: controller.selectedTopic.value,
                                  selectedDifficulty:
                                  controller.selectedDifficulty.value,
                                  selectedStatus: controller.selectedStatus.value,
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
                          onAddPressed: () {},
                          onRandomPressed: () {
                            final random = controller.getRandomQuestion();
                            if (random != null) {
                              Get.snackbar("Random Question", random.title);
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

              // ========== (4) QUESTION LIST (SCROLLS UNDER PINNED) ==========
              if (questions.isEmpty)
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
                        // separated efekti: çift indeks item, tek indeks spacer
                        if (index.isOdd) return const SizedBox(height: 10);
                        final itemIndex = index ~/ 2;
                        final q = questions[itemIndex];
                        return QuestionCard(
                          question: q,
                          onTap: () => _openQuestion(q),
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

  // Tip bazlı yönlendirme
  void _openQuestion(Question q) => QuestionNavigator.open(q);
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