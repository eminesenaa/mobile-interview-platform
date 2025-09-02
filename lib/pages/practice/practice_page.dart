// ===================== File: lib/pages/practice_page.dart =====================
// Purpose: Kullanıcının soru çözme pratiği yapacağı ana sayfa.
//          Firestore’dan sorular yüklenir, filtrelenir ve listelenir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';

import 'package:interview_project/pages/practice/widgets/todays_question_card.dart';

import '../../navigation/question_navigator.dart';
import '../library/controllers/library_controller.dart';
import '../library/widgets/save_to_collection_sheet.dart';
import './controllers/practice_controller.dart';
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
                        final path =
                            'assets/images/get_started_${index + 1}.jpg';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
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
                          topics: controller.allTopics,
                          selectedTopic: controller.selectedTopic.value,
                          onTopicSelected: (topic) {
                            controller.updateFilters(topic: topic);
                          },
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
                              _openQuestion(random);
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

              // ========== (4) QUESTION LIST ==========
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
                        return QuestionCard(
                          question: q,
                          onTap: () => _openQuestion(q),
                          onSaveTap: () async {
                            // 1) Soru ID’sini çıkar
                            final questionId = _extractQuestionId(q);

                            // 2) (Varsa) LibraryController’dan ön-verileri çek
                            Set<String> initialSelected = {};
                            bool initialSavedToAll = false;

                            try {
                              final lib = Get.find<LibraryController>();
                              initialSelected = (await lib.getCollectionsOfQuestion(questionId)).toSet();
                              initialSavedToAll = await lib.isSaved(questionId);
                            } catch (_) {
                              // Controller yoksa sorun değil; sheet mock listeyle açılır
                            }

                            // 3) Sheet’i aç
                            final result = await Get.bottomSheet(
                              SaveToCollectionSheet(
                                questionId: questionId,
                                initialSelected: initialSelected,
                                initialSavedToAll: initialSavedToAll,
                              ),
                              isScrollControlled: true,
                              ignoreSafeArea: false,
                              backgroundColor: Colors.transparent,
                            );

                            // 4) (Opsiyonel) dönüşü kullan
                            if (result is Map) {
                              // örn. ikon durumunu tazelemek için setState / controller notify
                              // print(result); // {'selectedCollectionIds': Set<String>, 'saveToAll': bool}
                            }
                          },
                          isSaved: false,
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
String _extractQuestionId(Question q) {
  // Modelinde hangi alan varsa onu kullan.
  // Aşağıdaki sıralama en yaygın 3 senaryoyu kapsar:
  try {
    final dynamic v = (q as dynamic).id;
    if (v != null) return v.toString();
  } catch (_) {}

  try {
    final dynamic v = (q as dynamic).docId; // Firestore doc id kullanıyorsan
    if (v != null) return v.toString();
  } catch (_) {}

  // Geçici fallback: benzersiz değilse ileride kaldır
  return q.title.toString();
}


